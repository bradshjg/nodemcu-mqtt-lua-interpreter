mqtthost = "192.168.0.108"
interpretername = "lua-interpreter"
interpretertopic = "/" .. interpretername

function interpret(client, topic, data)
    print("message on " .. topic .. " with body " .. data)
    if topic == interpretertopic and data ~= nil then
        print("interpreting message")
        local req_t = sjson.decode(data)
        local status, val = pcall(loadstring(req_t["chunk"]))
        if status then
            print("interpreting successful")
        end
        local replyto = req_t["reply-to"]
        if replyto ~= nil then
            resp_t = {success=status, message=val}
            resp_json = sjson.encode(resp_t)
            print("publishing to " .. replyto .. " with " .. resp_json)
            client:publish(replyto, resp_json, 0, 0, function () print("publish success") end)
        end
    end
end

function onconnect(client)
    client:subscribe(interpretertopic, 0, function () print("subscribe success") end)
end

function mqttsetup()
    local client = mqtt.Client(interpretername, 120)
    client:on("message", interpret)
    client:connect(mqtthost, 1883, false, function ()
        print("connect success")
        onconnect(client)
    end,
    function (_, reason)
        print('connect failed reason: ' .. reason)
    end
    )
end

function wificheck(timer)
    if wifi.sta.status() == wifi.STA_GOTIP then
        print('wifi connected')
        timer:unregister()
        mqttsetup()
    else
        print('wifi not connected...')
        timer:start()
    end
end

function init()
    inittimer = tmr.create()
    inittimer:alarm(1000, tmr.ALARM_SEMI, wificheck)
end

init()

config = {
    host="192.168.0.108",
    clientid="lua-interpreter",
    topic="/lua-interpreter"
}

function interpret(client, topic, data)
    print("message on " .. topic .. " with body " .. data)
    if topic == config["topic"] and data ~= nil then
        print("interpreting message")
        local req_t = sjson.decode(data)
        local status, val = pcall(loadstring(req_t["chunk"]))
        if status then
            print("interpreting successful")
        end
        local replyto = req_t["reply-to"]
        if replyto ~= nil then
            local resp_t = {success=status, message=val}
            local resp_json = sjson.encode(resp_t)
            print("publishing to " .. replyto .. " with " .. resp_json)
            client:publish(replyto, resp_json, 0, 0, function () print("publish success") end)
        end
    end
end

function onconnect(client)
    client:subscribe(config["topic"], 0, function () print("subscribe success") end)
end

function mqttsetup()
    local client = mqtt.Client(config["clientid"], 120)
    client:on("message", interpret)
    client:connect(config["host"], 1883, false, function ()
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
    local inittimer = tmr.create()
    inittimer:alarm(1000, tmr.ALARM_SEMI, wificheck)
end

init()

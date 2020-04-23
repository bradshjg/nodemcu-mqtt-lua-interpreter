# nodemcu-mqtt-lua-interpreter

Use mqtt to publish chunks to be interpreted (and optionally publish return value on another topic).

## Getting Started

### Setup

Requires [esptool](https://github.com/espressif/esptool) and [nodemcu-tool](https://github.com/andidittrich/NodeMCU-Tool).

Modify `Makefile` with your serial port

Modify `init.lua` with your MQTT host.

`make flash` to flash nodemcu

`make init` to upload the lua init script

`make term` to start a lua terminal

### Usage

Send a mqtt message to be interpreted, e.g.

`mosquitto_pub -h <host> -t /lua-interpreter -m '{"chunk": "gpio.mode(1, gpio.OUTPUT) gpio.write(1, gpio.HIGH)"}'`

which will configure pin 1 in output mode and set it high.

If a reply is desired, you can pass a "reply-to" key in the JSON payload, e.g.

`mosquitto_sub -h <host> -t /reply`

and then in another shell

`mosquitto_pub -h <host> -t /lua-interpreter -m '{"chunk": "return gpio.read(1)", "reply-to": "/reply"}'`

which will read pin 1 (should be 1 now) and we receive that response on the /reply topic.

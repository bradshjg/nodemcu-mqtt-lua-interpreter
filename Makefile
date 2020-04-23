NAME := lua-interpreter
PORT := /dev/cu.SLAB_USBtoUART
NODEMCU_BIN := nodemcu-master-11-modules-2020-04-22-14-23-50-integer.bin

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: flash
flash: ## flash nodemcu
	esptool.py --port $(PORT) erase_flash
	esptool.py --port $(PORT) write_flash --flash_mode dio 0x00000 $(NODEMCU_BIN)
	sleep 5
	nodemcu-tool -p $(PORT)  mkfs --noninteractive

.PHONY: init
init: ## upload init file
	nodemcu-tool -p $(PORT) upload init.lua

.PHONY: term
term: ## start terminal
	nodemcu-tool -p $(PORT) terminal

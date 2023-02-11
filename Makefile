SHELL := /bin/bash
PWD := $(shell pwd)

HDL := $(shell find -name "*.vhd")
TB_HDL := $(shell find -name "*.vhd")

SSHALIAS := "vbox2"
SSHPATH := "~/Documents/libero_projects/ProjectV2"
SSHGIT := "~/Documents/prj"

.PHONY: run test test-ssh test-local \
			debug debug-ssh debug-local \
			screen screen-ssh screen-local \
			update update-sw update-hw \
			pull pull-sw pull-hw \
			zip

pull-sw:
	@scp -r ${SSHALIAS}:${SSHPATH}/SoftConsole/ ./
	@rm -rf microsemi/softconsole/drivers; mv SoftConsole/drivers/ microsemi/softconsole/
	@rm -rf microsemi/softconsole/drivers_config; mv SoftConsole/drivers_config/ microsemi/softconsole/
	@rm -rf microsemi/softconsole/CMSIS; mv SoftConsole/CMSIS/ microsemi/softconsole/
	@rm -rf microsemi/softconsole/hal; mv SoftConsole/hal/ microsemi/softconsole/
	@cp -v ./SoftConsole/*.? microsemi/softconsole/
	@rm -rf  SoftConsole

pull-hw:
	@scp -r ${SSHALIAS}:${SSHPATH}/hdl/*.vhd ./microsemi/libero/
	@scp -r ${SSHALIAS}:${SSHPATH}/stimulus/*.vhd ./microsemi/libero/test/

pull: pull-sw

update-hw:
	@#scp microsemi/libero/*.vhd ${SSHALIAS}:${SSHPATH}/hdl/
	@#scp microsemi/libero/test/*.vhd ${SSHALIAS}:${SSHPATH}/stimulus/
	@#scp microsemi/libero/FSM.vhd ${SSHALIAS}:${SSHPATH}/hdl/
	@#scp microsemi/libero/apb_slave.vhd ${SSHALIAS}:${SSHPATH}/hdl/

update-sw:
	@scp microsemi/softconsole/*.? ${SSHALIAS}:${SSHPATH}/SoftConsole/

update: update-hw update-sw

zip:
	@scp -r ${SSHALIAS}:${SSHPATH} ./project
	@zip -r Project.zip project
	@mv Project.zip microsemi/Project.zip
	@[ -d project ] && rm -rf project

screen-ssh:
	@ssh -t ${SSHALIAS} \
		"screen /dev/ttyUSB0 57600"

screen-local:
	@screen /dev/ttyUSB0 57600

screen: $(if $(shell whoami | grep 'duclos'), screen-ssh, screen-local)

test-ssh:
	@ssh -t ${SSHALIAS} \
		"cd ${SSHGIT} && stty -F /dev/ttyUSB0 57600 && ./run.sh test"

test-local:
	@./run.sh test

test: $(if $(shell whoami | grep 'duclos'), test-ssh, test-local)

debug-ssh:
	@ssh -t ${SSHALIAS} \
		"cd ${SSHGIT} && stty -F /dev/ttyUSB0 57600 && ./run.sh debug"

debug-local:
	@stty -F /dev/ttyUSB0 57600
	@./run.sh debug

debug: $(if $(shell whoami | grep 'duclos'), debug-ssh, debug-local)

run:
	@./run.sh demo



.PHONY: build

QT_BASE = /usr/local/Cellar/qt/$(shell ls /usr/local/Cellar/qt|sort -rn|head -n1)
QT_BASE_ESCAPED = $(shell echo $(QT_BASE)|sed 's/\//\\\//g')

export PATH := $(QT_BASE)/bin:$(PATH)

FRAMEWORKS = QtCore.framework QtGui.framework QtNetwork.framework QtPrintSupport.framework QtRepParser.framework QtSvg.framework QtUiPlugin.framework QtWidgets.framework
SDKVER = $(shell sw_vers|grep 'ProductVersion'|awk '{print $$2}'|awk -F'.' '{print $$1"."$$2}')

all: checkout deps patch qt_symlinks config clean build dist

checkout:
	@if [ -d synergy ]; then \
		cd synergy; git pull; \
	else \
		git clone https://github.com/symless/synergy; \
	fi

deps:
	@brew install qt
	@brew install cmake

patch:
	@cd synergy; cat ../patches/commands1.diff| sed "s/##REPLACE##/$(QT_BASE_ESCAPED)/g" > commands1.diff
	@cd synergy; patch -f ext/toolchain/commands1.py < commands1.diff


qt_symlinks:
	@for framework in $(FRAMEWORKS); do cd $(QT_BASE)/lib/$$framework; if [ ! -d Contents ]; then mkdir Contents; ln -s ./Resources/Info.plist Contents/Info.plist; fi; done

config:
	@cd synergy; ./hm.sh conf -g2 --mac-sdk $(SDKVER) --mac-identity test

clean:
	@cd synergy; ./hm.sh clean

build:
	@cd synergy; ./hm.sh build

dist:
	@cd synergy; ./hm.sh dist mac
	@mv synergy/bin/Release/*.dmg ./

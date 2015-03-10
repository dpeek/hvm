#!/bin/sh
source $HVM/config.sh
exec haxe -cp $HAXELIBPATH --run tools.haxelib.Main "$@"

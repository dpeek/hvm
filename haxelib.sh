#!/bin/bash
source ~/.hvm/config.sh
if [[ $HAXE == 2* ]]; then
	exec $HAXEPATH/haxelib "$@"
else
	exec haxe -cp $HAXELIB_PATH --run tools.haxelib.Main "$@"
fi

#!/bin/bash
source ~/.hvm/config.sh
if [[ $HAXE == 2* ]]; then
	exec $HAXEPATH/haxelib "$@"
elif [ -e $HAXELIBPATH/tools ]; then
	exec haxe -cp $HAXELIBPATH --run tools.haxelib.Main "$@"
else
	exec haxe -cp $HAXELIBPATH --run haxelib.client.Main "$@"
fi

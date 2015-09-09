#!/bin/bash

export HVM=~/.hvm

# source default versions
source $HVM/versions.sh

# source current versions if they exist
if [ -e $HVM/current.sh ]; then
	source $HVM/current.sh
fi

# source local versions if they exist
if [ -e .hvmrc ]; then
	source .hvmrc
fi

# source the current platform
source $HVM/platform.sh

# configure paths
HAXEPATH=$HVM/versions/haxe/$HAXE
export HAXE_STD_PATH=$HAXEPATH/std
export HAXE_LIBRARY_PATH=$HAXEPATH/std
export HAXELIBPATH=$HVM/versions/haxelib/$HAXELIB
export NEKOPATH=$HVM/versions/neko/$NEKO
export DYLD_FALLBACK_LIBRARY_PATH=$NEKOPATH
export LD_LIBRARY_PATH=$NEKOPATH

# install haxe if needed

if [ ! -d "$HAXEPATH" ]; then
	mkdir -p "$HVM/versions/haxe"

	ARCHIVE="$HAXEPATH.tar.gz"

	case $PLATFORM in
		'OSX') URL="http://old.haxe.org/file/haxe-$HAXE-osx.tar.gz" ;;
		'LINUX32') URL="http://old.haxe.org/file/haxe-$HAXE-linux32.tar.gz" ;;
		'LINUX64') URL="http://old.haxe.org/file/haxe-$HAXE-linux64.tar.gz" ;;
	esac


	if [ "$HAXE" == "dev" ]; then
		case $PLATFORM in
			'OSX') URL="http://hxbuilds.s3-website-us-east-1.amazonaws.com/builds/haxe/mac/haxe_latest.tar.gz" ;;
			'LINUX32') URL="http://hxbuilds.s3-website-us-east-1.amazonaws.com/builds/haxe/linux32/haxe_latest.tar.gz" ;;
			'LINUX64') URL="http://hxbuilds.s3-website-us-east-1.amazonaws.com/builds/haxe/linux64/haxe_latest.tar.gz" ;;
		esac

	fi

	echo "downloading $URL"
	curl "$URL" -o "$ARCHIVE" -#
	mkdir -p "$HAXEPATH"

	tar -xzf "$ARCHIVE" -C "$HAXEPATH" --strip-components=1
	rm "$ARCHIVE"
fi

# install neko if needed
if [ ! -d "$NEKOPATH" ]; then
	mkdir -p "$HVM/versions/neko"

	ARCHIVE="$NEKOPATH.tar.gz"

	case $PLATFORM in
		'OSX') URL="http://nekovm.org/_media/neko-$NEKO-osx64.tar.gz?id=download&cache=cache" ;;
		'LINUX32') URL="http://nekovm.org/_media/neko-$NEKO-linux.tar.gz?id=download&cache=cache" ;;
		'LINUX64') URL="http://nekovm.org/_media/neko-$NEKO-linux64.tar.gz?id=download&cache=cache" ;;
	esac

	if [ "$NEKO" == "dev" ]; then
		case $PLATFORM in
			'OSX') URL="http://hxbuilds.s3-website-us-east-1.amazonaws.com/builds/neko/mac/neko_latest.tar.gz" ;;
			'LINUX32') URL="http://hxbuilds.s3-website-us-east-1.amazonaws.com/builds/neko/linux32/neko_latest.tar.gz" ;;
			'LINUX64') URL="http://hxbuilds.s3-website-us-east-1.amazonaws.com/builds/neko/linux64/neko_latest.tar.gz" ;;
		esac
	fi

	echo "downloading $URL"
	curl "$URL" -o "$ARCHIVE" -#
	mkdir -p "$NEKOPATH"

	if [ "$NEKO" == "dev" ]; then
		tar -xzf "$ARCHIVE" -C "$NEKOPATH" --strip-components=2
	else
		tar -xzf "$ARCHIVE" -C "$NEKOPATH" --strip-components=1
	fi
	rm "$ARCHIVE"
fi

# install haxelib if needed
if [ ! -d "$HAXELIBPATH" ]; then
	mkdir -p "$HVM/versions/haxelib"

	VERSION=$( echo "$HAXELIB" | tr "." "," )
	URL="http://lib.haxe.org/files/3.0/haxelib_client-$VERSION.zip"
	ARCHIVE="$HAXELIBPATH.zip"

	if [ "$HAXELIB" == "dev" ]; then
		URL="https://github.com/HaxeFoundation/haxelib/archive/master.zip"
	fi

	echo "downloading $URL"
	curl "$URL" -o "$ARCHIVE" -# -L

	unzip -qq "$ARCHIVE" -d "$HAXELIBPATH"
	rm "$ARCHIVE"

	if [ -d $HAXELIBPATH/package ]; then
		mv $HAXELIBPATH/package/* $HAXELIBPATH
		rmdir $HAXELIBPATH/package
	fi

	if [ -d $HAXELIBPATH/haxelib-master/src ]; then
		mv $HAXELIBPATH/haxelib-master/src/* $HAXELIBPATH
		rm -rf $HAXELIBPATH/haxelib-master
	fi

	if [ -d $HAXELIBPATH/src ]; then
		mv $HAXELIBPATH/src/* $HAXELIBPATH
		rm -rf $HAXELIBPATH/src
	fi
fi

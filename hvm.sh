#!/bin/bash

PREFIX=/usr/local/bin
VERSION=1.1.0

export HVM=~/.hvm

# determine platform
source $HVM/platform.sh

# TODO (dpeek): can we just source config for the following three directives?

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

hvm_get_haxe_versions() {
	HAXE_VERSIONS=()
	local VERSIONS=`curl --silent http://haxe.org/download/list 2>&1 | grep -oE 'version\/[^/]+' | cut -d / -f 2 | awk '!a[$0]++'`
	for VERSION in $VERSIONS; do
		HAXE_VERSIONS+=($VERSION)
	done
}

hvm_get_haxelib_versions() {
	local VERSIONS=()
	local REGEX=">([0-9\.rc\-]*)<"
	# https://www.youtube.com/watch?v=w3PoTnkLfxE
	local HREFS=$( curl --silent http://lib.haxe.org/p/haxelib_client/versions/ 2>&1 | grep "/\" class=\"text" )
	for HREF in $HREFS; do
		if [[ $HREF =~ $REGEX ]]; then
			VERSIONS+=("${BASH_REMATCH[1]}")
		fi
	done
	HAXELIB_VERSIONS=()
	for (( idx=${#VERSIONS[@]}-1 ; idx>=0 ; idx-- )) ; do
		HAXELIB_VERSIONS+=("${VERSIONS[idx]}")
	done
}

hvm_get_neko_versions() {
	NEKO_VERSIONS=("1.8.1" "1.8.2" "2.0.0")
}

hvm_valid_version() {
	if [ "$1" == "dev" ]; then
		return 0
	fi
	local e
	for e in "${@:2}"; do [[ "$e" == "$1" ]] && return 0; done
	echo "version $1 was not one of ${@:2}"
	return 1
}

hvm_save_current() {
	rm -f $HVM/current.sh
	echo "export NEKO=$NEKO" >> $HVM/current.sh
	echo "export HAXE=$HAXE" >> $HVM/current.sh
	echo "export HAXELIB=$HAXELIB" >> $HVM/current.sh
}

hvm() {
	case $1 in
	"use" )
		case $2 in
		"haxe" )
			HAXE=$3
			if [ "$HAXE" == "latest" ]; then
				rm -rf $HVM/versions/haxe/dev
				HAXE="dev"
			fi
			hvm_get_haxe_versions
			hvm_valid_version $HAXE ${HAXE_VERSIONS[@]} && hvm_save_current
			source $HVM/config.sh
		;;
		"haxelib" )
			HAXELIB=$3
			if [ "$HAXELIB" == "latest" ]; then
				rm -rf $HVM/versions/haxelib/dev
				HAXELIB="dev"
			fi
			hvm_get_haxelib_versions
			hvm_valid_version $HAXELIB ${HAXELIB_VERSIONS[@]} && hvm_save_current
			source $HVM/config.sh
		;;
		"neko" )
			NEKO=$3
			if [ "$NEKO" == "latest" ]; then
				rm -rf $HVM/versions/neko/dev
				NEKO="dev"
			fi
			hvm_get_neko_versions
			hvm_valid_version $NEKO ${NEKO_VERSIONS[@]} && hvm_save_current
			source $HVM/config.sh
		;;
		* )
			echo "binary \"$2\" was not one of (neko haxe haxelib)"
			return
		;;
		esac
	;;
	"install" )
		sudo ln -sf $HVM/haxe.sh $PREFIX/haxe
		sudo ln -sf $HVM/haxelib.sh $PREFIX/haxelib
		sudo ln -sf $HVM/neko.sh $PREFIX/neko
		sudo ln -sf $HVM/nekotools.sh $PREFIX/nekotools
		sudo ln -sf $HVM/nekoc.sh $PREFIX/nekoc
		sudo ln -sf $HVM/nekoml.sh $PREFIX/nekoml
		source $HVM/config.sh
	;;
	"versions" )
		case $2 in
		"haxe" )
			hvm_get_haxe_versions
			for VERSION in "${HAXE_VERSIONS[@]}"; do
				echo "$VERSION"
			done
		;;
		"haxelib" )
			hvm_get_haxelib_versions
			for VERSION in "${HAXELIB_VERSIONS[@]}"; do
				echo "$VERSION"
			done
		;;
		"neko" )
			hvm_get_neko_versions
			for VERSION in "${NEKO_VERSIONS[@]}"; do
				echo "$VERSION"
			done
		;;
		* )
			echo "binary \"$2\" was not one of (neko haxe haxelib)"
			return
		;;
		esac
	;;
	"help" | * )
		echo "Haxe Version Manager $VERSION"
		echo "Usage: hvm use (neko|haxe|haxelib) (latest|dev|1.2.3)"
		echo "Usage: hvm versions (neko|haxe|haxelib)"
	;;
	esac
}

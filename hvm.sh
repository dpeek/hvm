export HVM=$HOME/.hvm

source $HVM/versions.sh
source $HVM/platform.sh

hvm_get_haxe_versions() {
	HAXE_VERSIONS=(dev)
	case $PLATFORM in
		'OSX') local REGEX=">haxe-([0-9]\.[0-9][0-9]*[.0-9]*)-osx\.tar\.gz<" ;;
		'LINUX32') local REGEX=">haxe-([0-9]\.[0-9][0-9]*[.0-9]*)-linux32\.tar\.gz<" ;;
		'LINUX64') local REGEX=">haxe-([0-9]\.[0-9][0-9]*[.0-9]*)-linux64\.tar\.gz<" ;;
	esac
	local HREFS=$( curl --silent http://old.haxe.org/file/ 2>&1 | grep href )
	for HREF in $HREFS; do
		 if [[ $HREF =~ $REGEX ]]; then
		 	HAXE_VERSIONS+=("${BASH_REMATCH[1]}")
		 fi
	done
}

hvm_get_haxelib_versions() {
	HAXELIB_VERSIONS=(dev)
	local REGEX="\"name\">([0-9\.rc\-]*)"
	local HREFS=$( curl --silent http://lib.haxe.org/p/haxelib_client 2>&1 | grep name )
	for HREF in $HREFS; do
		 if [[ $HREF =~ $REGEX ]]; then
		 	HAXELIB_VERSIONS+=("${BASH_REMATCH[1]}")
		 fi
	done
}

hvm_get_neko_versions() {
	NEKO_VERSIONS=(dev 1.8.1 1.8.2 2.0.0)
}

hvm_valid_version() {
  local e
  for e in "${@:2}"; do [[ "$e" == "$1" ]] && return 0; done
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
			hvm_get_haxe_versions
			hvm_valid_version $3 ${HAXE_VERSIONS[@]} && hvm_save_current || echo "version \"$3\" was not one of (${HAXE_VERSIONS[@]})"
			if [ "$HAXE" == "dev" ]; then
				rm -rf $HVM/versions/haxe/dev
			fi
		;;
		"haxelib" )
			HAXELIB=$3
			hvm_get_haxelib_versions
			hvm_valid_version $3 ${HAXELIB_VERSIONS[@]} && hvm_save_current || echo "version \"$3\" was not one of (${HAXELIB_VERSIONS[@]})"
			if [ "$HAXELIB" == "dev" ]; then
				rm -rf $HVM/versions/haxelib/dev
			fi
		;;
		"neko" )
			NEKO=$3
			hvm_get_neko_versions
			hvm_valid_version $3 ${NEKO_VERSIONS[@]} && hvm_save_current || echo "version \"$3\" was not one of (${NEKO_VERSIONS[@]})"
			if [ "$NEKO" == "dev" ]; then
				rm -rf $HVM/versions/neko/dev
			fi
		;;
		* )
			echo "binary \"$2\" was not one of (neko haxe haxelib)"
			return
		;;
		esac
	;;
	"install" )
		sudo ln -sf $HVM/haxe.sh /usr/bin/haxe
		sudo ln -sf $HVM/haxelib.sh /usr/bin/haxelib
		sudo ln -sf $HVM/neko.sh /usr/bin/neko
		sudo ln -sf $HVM/nekotools.sh /usr/bin/nekotools
		sudo ln -sf $HVM/nekoc.sh /usr/bin/nekoc
		sudo ln -sf $HVM/nekoml.sh /usr/bin/nekoml
	;;
	"help" | * )
		echo "Haxe Version Manager 1.0"
		echo "Usage: hvm use (neko|haxe|haxelib) (dev|1.2.3)"
	;;
	esac
}

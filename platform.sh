PLATFORM='unknown'
case "$OSTYPE" in
	linux*)
		MACHINE_TYPE=`uname -m`
		if [ ${MACHINE_TYPE} == 'x86_64' ]; then
			PLATFORM="LINUX64"
		else
			PLATFORM="LINUX32"
		fi
	;;
	darwin*)  PLATFORM="OSX" ;;
	*) echo "No support for OS: $OSTYPE" ;;
esac

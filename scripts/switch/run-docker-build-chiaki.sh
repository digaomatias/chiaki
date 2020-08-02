#!/bin/bash

cd "`dirname $(readlink -f ${0})`/../.."

docker run \
	-v "`pwd`:/build/chiaki" \
	-w "/build/chiaki" \
	-t \
	chiaki-switch \
	-c "scripts/switch/build.sh"


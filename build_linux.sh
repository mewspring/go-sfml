#!/usr/bin/env bash

## [Requires 'sfml.sh' & 'swig.sh' to have been run successfully]
## Builds the cgo bindings and install the final go packages

set -e

SFML="SFML"
CSFML="CSFML"
SFML_MODULES=(Audio Graphics System Window)

for m in "${SFML_MODULES[@]}"; do
	mm=$(echo $m | tr '[:upper:]' '[:lower:]')

	mkdir -p "$PWD/$mm"
	mkdir -p "$PWD/work/$mm"
	echo -n "building bindings for SFML's $m module..."
	cp "$PWD/interfaces/$m.i" "$PWD/work/$mm/$m.i"
	./swig/bin/swig -go -cgo -intgosize 64 -I"/usr/include"  "$PWD/work/$mm/$m.i"
	cp "$PWD/work/$mm/$mm.go" "$PWD/work/$mm/${m}_wrap.c" "$PWD/$mm"
	sed -i "/import \"C\"/i \/\/ #cgo LDFLAGS: -lcsfml-$mm" "$PWD/$mm/$mm.go"
	echo " OK."

	echo -n "compiling go package for SFML's $m module..."
	CGO_LDFLAGS="-L$PWD/CSFML/lib -lcsfml-$mm" CGO_CFLAGS="-I$PWD/$CSFML/include" go install "./$mm"
	echo " OK."
done

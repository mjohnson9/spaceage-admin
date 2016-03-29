#!/bin/sh

set -e

find lua -type f -iname '*.lua' | while read filepath; do
	luac5.1 -p -- "${filepath}"
done

#!/bin/bash

# Strip private data from conkyrc before commiting changes to git

RULES="$(pwd)/conky-private.sed"

cat $(pwd)/conkyrc | sed -f "$RULES" > conkyrc.clean

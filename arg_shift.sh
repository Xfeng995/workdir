#!/bin/bash

while [ "$#" -gt 0 ]; do
    echo "$#"
    echo "Current parameter: $1"
    shift
done

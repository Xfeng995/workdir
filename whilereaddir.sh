#!/bin/bash

find . -type f | while read file;
do
	echo $file
done

#!/bin/bash
date=$(date +%Y-%m-%d)
chage -d ${date} root
chage -d ${date} ns5000

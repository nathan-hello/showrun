#!/bin/bash

this_dir="$(dirname "$(realpath "$0")")"

cp ./grub.conf /etc/default/grub

update-grub

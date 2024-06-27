#!/bin/bash

install() {
        apt-get install openntpd 
}

ntpd -s
NTPD_PID=$!
sleep 5
kill $NTPD_PID

hwclock -w

#!/bin/bash
nohup ss-server -c "/etc/shadowsocks-libev/config.json" > /dev/null &

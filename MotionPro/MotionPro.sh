#!/bin/sh
appname=MotionPro
dirname=/opt/MotionPro
cmdname=vpn_cmdline

LD_LIBRARY_PATH=$dirname
export LD_LIBRARY_PATH

var=`runlevel | awk '{print $2}'`

if [ $# -eq 0 ]; then
    $dirname/$appname $*
else
    $dirname/$cmdname $*
fi

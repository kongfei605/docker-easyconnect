#!/bin/bash
fake-hwaddr-run() { "$@" ; }
[ -n "$FAKE_HWADDR" ] && fake-hwaddr-run() { LD_PRELOAD=/usr/local/lib/fake-hwaddr.so "$@" ; }
while true
do
	#fake-hwaddr-run /opt/HillstoneVPN/start_scvpn.sh /opt/HillstoneVPN
	fake-hwaddr-run /opt/HillstoneVPN/bin/SCVPN

	[ -n "$MAX_RETRY" ] && ((MAX_RETRY--))

	# 自动重连
	((MAX_RETRY<0)) && exit

	# 清除的残余进程，它们可能会妨碍下次的启动。
	killall -9 SCVPN 2> /dev/null
	sleep 4
done

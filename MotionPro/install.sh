#!/bin/sh

prefix=/opt/MotionPro
target_dir=/usr/bin
prg=MotionPro
prg_script=$prg.sh
prg_link=$target_dir/$prg
cmd=vpn_cmdline
hwidclient=hardwareid_client
daemon_dir=daemon
daemon_name=vpnd
daemon_prg=$daemon_dir/$daemon_name
root_name=root
hardware="/usr/local/motionpro"
hardware_id="$hardware/hardwareid_value"
generate_id=clientid_linux64
help=help
qm=*.qm
start_script=
# auto start script path in centos
start_script_path1="/etc/rc.d/rc.local"
# auto start script path in ubuntu
start_script_path2="/etc/rc.local"
resources=res
install_script=$0

# just for ubuntu14.04/centos7 gnome
desktop_target=/usr/share/applications
desktop_profile=$resources/$prg.desktop


if [ "$USER" != "root" -a "`whoami`" != "root" -a "$UID" != "0" ]
then
    echo "Please run the installation script as root or using sudo!"
    exit 1  
fi

if [ -f $start_script_path1 ]; then
    start_script=$start_script_path1
elif [ -f $start_script_path2 ]; then
    start_script=$start_script_path2
else
   mkdir /etc/rc.d
   touch $start_script_path1
   start_script=$start_script_path1
fi

if [ $# -eq 0 ]; then  # install
    # install vpnd
    echo "installing $daemon_name..."
    /bin/cp $daemon_prg $target_dir
    /bin/chown root $target_dir/$daemon_name 
    /bin/chgrp root $target_dir/$daemon_name  
    /bin/chmod 4755 $target_dir/$daemon_name  
    if [ ! -x $start_script ]; then
        /bin/chmod +x $start_script
    fi

    # add into '/etc/rc.local'
    sed -i '$i\/usr/bin/vpnd 2>&1' $start_script
    # run vpnd immediately
    daemon_pid=`ps -ef|grep $daemon_name|grep -v grep|awk '{print $2}'`
    if [ "$daemon_pid" = "" ]; then
        echo "starting $daemon_name..."
        $target_dir/$daemon_name 2>&1
    fi

    # install root permission of file
    /bin/cp $root_name $target_dir
    /bin/chown root:root $target_dir/$root_name
    /bin/chmod 4755 $target_dir/$root_name

    # install MotionPro and runtime libraries
    echo "installing $prg..."
    /bin/mkdir -p $prefix
    /bin/chmod 777 $prefix
    /bin/cp -p ./$prg $prefix
	/bin/cp -p ./arraydnsproxy $prefix
	/bin/chmod 777 $prefix/arraydnsproxy
    /bin/cp -p ./ArrayWGClient $prefix
    /bin/chmod +x $prefix/ArrayWGClient
    /bin/cp -p ./$prg_script $prefix
    /bin/cp -p -R ./libs/* $prefix
    /bin/ln -s $prefix/$prg_script $prg_link
    /bin/cp -p ./$cmd $prefix
    /bin/cp -p ./$hwidclient $prefix

    # create desktop shortcut
    echo "creating desktop shortcut for MotionPro..."
    /bin/cp -p ./$desktop_profile $desktop_target

    # copy resources to installed directory
    /bin/cp -p -R $resources $prefix

    # copy install script to installed directory
    /bin/cp -p $install_script $prefix

    # copy help files to installed directory
    /bin/cp -p -R $help $prefix

    # copy qm files to installed directory
    /bin/cp ./$qm $prefix
    
    # write hardware id to file
    if [ ! -e $hardware ]; then
        /bin/mkdir -p $hardware
        /bin/chmod 755 $hardware
    fi

    if [ ! -e $hardware_id ]; then
        /bin/touch $hardware_id
        /bin/chmod 644 $hardware_id
    fi
    
    cat /dev/null > $hardware_id
    ./$generate_id > $hardware_id

    echo "install $prg successfully."
    exit 0
elif [ $# -eq 1 -a "$1" = "-u" ]; then # uninstall
    # close application and service first.
    prg_pid=`ps -ef|grep $prg|grep -v grep|awk '{print $2}'`
    if [ "$prg_pid" != "" ]; then
        echo "$prg (pid: $prg_pid) will be closed..."
        /bin/kill $prg_pid
    fi
    daemon_pid=`ps -ef|grep $daemon_name|grep -v grep|awk '{print $2}'`
    if [ "$daemon_pid" != "" ]; then
        echo "vpnd (pid: $daemon_pid) will be closed..."
        /bin/kill $daemon_pid
    fi
 
    # delete desktop shortcut
    if [ -e $desktop_target/$prg.desktop ]; then
        echo "removing $desktop_target/$prg.desktop"
        /bin/rm -f $desktop_target/$prg.desktop
    fi
   
    # remove executable file and runtime libraries.
    if [ -e $target_dir/$daemon_name ]; then
        echo "removing $target_dir/$daemon_name..."
        /bin/rm -f $target_dir/$daemon_name
    fi
    if [ -e $prg_link ]; then
        echo "removing $prg_link..."
        /bin/rm -f $prg_link
    fi
    if [ -e $prefix ]; then
        echo "removing $prefix..."
        /bin/rm -rf $prefix
    fi

    if [ -e $target_dir/$root_name ]; then
        /bin/rm -f $target_dir/$root_name
    fi

    # delete auto-start from '/etc/rc.local'
    sed -i -e '/usr\/bin\/vpnd/d' $start_script

    #delete hardware id file
    if [ -e $hardware ]; then
        /bin/rm -rf $hardware
    fi

    echo "uninstall $prg finished."
    exit 0
else
    echo "invalid parameters."
    exit 2
fi

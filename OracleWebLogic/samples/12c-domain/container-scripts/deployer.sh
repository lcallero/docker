#!/bin/bash
#weblogic domain
workdir=/u01/oracle/weblogic/user_projects/domains/base_domain/bin
file=nohup.out

function waitForRunningServer() {
    # 60 second timeout.
    sleep 60 &
    timerPid=$!
    tail -n0 -F --pid=$timerPid $workdir/$file | while read line                                             
						 do
						     echo "$(date +"%T")" $timerPid $line
						     if  echo $line | grep -q 'Server state changed to RUNNING'; then
							 echo 'Server Started'                                           
							 # stop the timer..                                              
							 kill $timerPid                                                  
						     fi                                              
						 done &
    wait %sleep
}


function waitForServer(){
    CLASSPATH="/u01/oracle/weblogic/wlserver/server/lib/weblogic.jar${CLASSPATH}"
    export CLASSPATH

    status=`java weblogic.Admin -adminurl t3://localhost:8001 -username weblogic -password welcome1 GETSTATE AdminServer`

    echo "Admin Server is starting... "

    count=1
    until [[ $status =~ "RUNNING" ]]
    do
	status=`java weblogic.Admin -adminurl t3://localhost:8001 -username weblogic -password welcome1 GETSTATE AdminServer`
	echo $status
    done

    if [[ $status == *"RUNNING"* ]];
    then
	echo "Admin Server is running "
	echo "May proceed with deployment..."
    fi
}


function startServer(){
    # Clear the nohup file that is existing
    echo $workdir
    cd $workdir
    if [ `pwd` == $workdir ]
    then
	if [ -f $file ]
	then
            rm -f $file
	fi
    fi

    # Start the Weblogic Admin Server.
    echo " Starting Weblogic Admin Server "
    echo "$(pwd)"
    nohup ./startWebLogic.sh > $file &
    #    sleep 10
}

function deployApplication(){
    echo "deploying..."
    /u01/oracle/weblogic/wlserver/common/bin/wlst.sh /u01/oracle/connect.py
}

function stopServer(){
    ./stopWebLogic.sh
}

startServer
waitForRunningServer
waitForServer
deployApplication
stopServer

#!/bin/bash
#weblogic domain
workdir=/u01/oracle/weblogic/user_projects/domains/base_domain/bin
file=nohup.out
echo $workdir
cd $workdir
echo "false" > isServerRunning.tmp 

function waitForRunningServer() {
    # 60 second timeout.
    sleep 60 &
    timerPid=$!
    tail -n0 -F --pid=$timerPid $workdir/$file | while read line                                             
						 do
						     echo "$(date +"%T")" $timerPid $line
						     if  echo $line | grep -q 'Server state changed to RUNNING'; then
							 echo 'Server Started'							
							 echo "true" > isServerRunning.tmp 
							 # stop the timer..                                              
							 kill $timerPid                                                  
						     fi                                              
						 done &
    wait %sleep
}

#esta funcao funciona mas não tem timeout!
function waitForServer(){
    CLASSPATH="/u01/oracle/weblogic/wlserver/server/lib/weblogic.jar${CLASSPATH}"
    export CLASSPATH

    status=`java weblogic.Admin -adminurl t3://localhost:8001 -username weblogic -password welcome1 GETSTATE AdminServer`

    echo "Admin Server is starting... "

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
    if [ `pwd` == $workdir ]
    then
	if [ -f $file ]
	then
            rm -f $file
	fi
    fi

    # Start the Weblogic Admin Server.
    echo " Starting Weblogic Admin Server "
    nohup ./startWebLogic.sh > $file &
}

function deployApplication(){
    if [[ "$(cat isServerRunning.tmp)" = true ]]; then
	echo "deploying..."
	/u01/oracle/weblogic/wlserver/common/bin/wlst.sh /u01/oracle/deployer.py
    else
	echo "Time out 60s, server is not running ):"
	exit 1
    fi   
} 

function clearFiles(){
    rm isServerRunning.tmp
    #apagar demais arquivos
}

startServer
waitForRunningServer
#waitForServer
deployApplication

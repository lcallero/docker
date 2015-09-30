#!/bin/bash
domain=/u01/oracle/weblogic/user_projects/domains/base_domain
# Clear the nohup file that is existing
echo ${domain}/bin
cd ${domain}/bin
if [ `pwd` == ${domain}/bin ]
then
    echo "ALGO NO IF THEN"
    if [ -f nohup.out ]
    then
	rm -f nohup.out
    fi
fi

# Start the Weblogic Admin Server.
echo " Starting Weblogic Admin Server "
nohup ./startWebLogic.sh &
echo "$(ls -la)"

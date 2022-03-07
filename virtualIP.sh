#!/bin/bash

while [ 1 ];
do
   active_postgres=$(systemctl is-active postgresql-12.service)
   if [ "$database_postgres" = "active" ]
   then
	active_node_1=$(psql -At -d repmgr -U repmgr -c "select active from nodes where node_id = 1;")
	active_node_2=$(psql -At -d repmgr -U repmgr -c "select active from nodes where node_id = 2;")
	database_role=$(psql -At -d repmgr -U repmgr -c "select type from nodes where node_id = 2;")
	ip_primary=$(/sbin/ip address show dev enp0s3 | grep 192.168.1.100 | wc -l)
	ip_standby=$(/sbin/ip address show dev enp0s3 | grep 192.168.1.101 | wc -l)

	if [ "$active_node_2" = "t" ]
	then
		if [ "$database_role" = "primary" ]
		then
			if [ $ip_primary -eq 0 ]
			then
                        	ifup enp0s3:0
                	fi
			if [ "$active_node_1" = "f" ]
			then
				ifup enp0s3:1
			else
				if [ $ip_standby -eq 1 ]
				then
					ifdown enp0s3:1
				fi
			fi
		else
			if [ $ip_standby -eq 0 ]
			then
				ifup enp0s3:1
			fi
		fi
	else
		if [ $ip_primary -eq 1 ]
		then
			ifdown enp0s3:0
		fi
		if [ $ip_standby -eq 1 ]
		then
                	ifdown enp0s3:1
	        fi
	fi
   fi
   sleep 10
done


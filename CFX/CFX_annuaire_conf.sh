#!/bin/bash
#########################################################################
# THIS IS PROVIDED "AS IS", WITHOUT ANY WARRANTY, AND WITHOUT ANY SUPPORT. 
# LICENSE : CC-BY-SA 3.0 - http://creativecommons.org/licenses/by-sa/3.0/ 
# CFX Central File eXchange
# Test with CentOS 6 / Centreon 2.6 / Nagios 3.5.1
# Scripts to tranfert Nagios configuration in FTP
#########################################################################
# CFX_annuaire_conf.sh
# Central File eXchange - 17 juin 2016 - Matthieu PERRIN

centreon_config=/etc/centreon/conf.pm

CentreonDir=$(cat ${centreon_config} | grep CentreonDir | cut -d'=' -f 2 |  cut -d '"' -f 2)
nagiosCFG=${CentreonDir}/filesGeneration/nagiosCFG
brokerCFG=${CentreonDir}/filesGeneration/broker
correspondance=${nagiosCFG}/correspondance

 max=$(ls ${nagiosCFG} | grep -o '[0-9]*' |sort -n | tail -n 1)
rm -f $correspondance

for i in `seq 1 $max`
do
        name=""
        if [ -f ${nagiosCFG}/${i}/ndomod.cfg ]; then
                name=$(cat ${nagiosCFG}/$i/ndomod.cfg | grep 'instance_name' | cut -d"=" -f2)
        fi
        # Ajout 30-03-17
        if [ -f  ${brokerCFG}/$i/poller-module.xml  ]; then
                name=$(cat ${brokerCFG}/${i}/poller-module.xml | grep instance_name | sed 's,<instance_name>,,g; s,</instance_name>,,g; s,CDATA,,g' | sed 's/[^a-z -_A-Z 0-9]//g' | tr -d  ' ')
        fi
        echo $name >> $correspondance

done

date +%s >> $correspondance


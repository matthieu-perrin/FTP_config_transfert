#!/bin/bash
#########################################################################
# THIS IS PROVIDED "AS IS", WITHOUT ANY WARRANTY, AND WITHOUT ANY SUPPORT. 
# LICENSE : CC-BY-SA 3.0 - http://creativecommons.org/licenses/by-sa/3.0/ 
# CFX Central File eXchange
# Test with CentOS 6 / Centreon 2.6 / Nagios 3.5.1
# Scripts to tranfert Nagios configuration in FTP
#########################################################################
###################################################
# CFX_get_local_cmd.sh                            #
# Auteur :   Matthieu PERRIN (OBS)                #
# Fonction : envoi les commande a nagios central  #
###################################################

centreon_config=/etc/centreon/conf.pm

CentreonDir=$(cat ${centreon_config} | grep CentreonDir | cut -d'=' -f 2 |  cut -d '"' -f 2)
cfgdir=${CentreonDir}/filesGeneration/nagiosCFG
brokerCFG=${CentreonDir}/filesGeneration/broker
eMaintCFG=${CentreonDir}/filesGeneration/eMaintCFG
#PATH_VAR=$(cat ${cfgdir}/1/nagios.cfg | grep "service_perfdata_file=" | cut -d "=" -f 2 | sed "s,/service-perfdata,,g")
PATH_VAR=/usr/local/nagios/var

moduleXML=poller-module.xml

nom=Central
cmdfile=${PATH_VAR}/nagios.cmd
delai=10

###################################################
# Recupere les variables
get_var()
{

#Pour chaque poller dans nagiosCFG
for FILEB in $(ls -1 $cfgdir/ | grep ^[0-9] | grep -v '[[:alpha:]]')
  do

	if [ -f $cfgdir/$FILEB/ndomod.cfg ]; then
        central=$(grep 127.0.0.1 $cfgdir/$FILEB/ndomod.cfg | wc -l)

        #test Si c'est le poller local
        if [ $central -gt 0 ]
        then
                        # recupere le nome du poller et l'emplcaement de nagios.cmd
                        nom=$(grep instance_name $cfgdir/$FILEB/ndomod.cfg | cut -d"=" -f2)
                        cmdfile=$(grep command_file $cfgdir/$FILEB/nagios.cfg | cut -d"=" -f 2)
        fi
	fi
	
	#Ajout avril 2017
	#moduleXML=$( cat $cfgdir/$FILEB/centengine.cfg | grep cbmod | rev | cut -d"/" -f1 | rev)
	if [ -f ${brokerCFG}/$FILEB/${moduleXML} ]; then
		central=$(grep 127.0.0.1 ${brokerCFG}/$FILEB/${moduleXML} | wc -l)
		
        #test Si c'est le poller local
        if [ $central -gt 0 ]
        then
                        # recupere le nome du poller et l'emplcaement de nagios.cmd
						nom=$(cat ${brokerCFG}/${numpoller}/${moduleXML} | grep instance_name | sed 's,<instance_name>,,g; s,</instance_name>,,g; s,CDATA,,g' | sed 's/[^a-zA-Z0-9_\-]//g' | tr -d  ' ')
                        cmdfile=$(grep command_file $cfgdir/$FILEB/centengine.cfg | cut -d"=" -f 2)						
		
		fi
	fi
  done
}

###################################################
# Recharge ou redemmare nagios si commandes
traite_cmd()
{
        echo "rechargement Nagios"
        if [ $(grep "RELOAD" $cfgdir/transfert/$nom.cmd.tmp | wc -l) -ge "1" ]; then
                /etc/init.d/nagios reload
        elif [ $(grep "RESTART" $cfgdir/transfert/$nom.cmd.tmp | wc -l) -ge "1" ]; then
                /etc/init.d/nagios restart
        fi
}


###################################################
# copie les commandes dans nagios.Cmd
transfert_cmd()
{
        # si un fichier de commande existe
        if [ -f $cfgdir/transfert/$nom.cmd ]
        then
                # deplace les commande de Central.cmd dans nagios.cmd
                mv $cfgdir/transfert/$nom.cmd $cfgdir/transfert/$nom.cmd.tmp
                traite_cmd
                cat $cfgdir/transfert/$nom.cmd.tmp >> $cmdfile
                rm -f $cfgdir/transfert/$nom.cmd.tmp
        fi
}

###################################################
# PROGRAMME

echo "["`date +%s`"]Demarrage de $0"

echo "["`date +%s`"]Rotation des logs $0.log"
mv -f $0.log $0.log.1

# recupere le nom du poller et l'emplacement de nagios.cmd
get_var

# boucle infini
while true
do
        # copie les commandes
        transfert_cmd
        # attend avant de recommencer la boucle
        sleep $delai
done

exit 0

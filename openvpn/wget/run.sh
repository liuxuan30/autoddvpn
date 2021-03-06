#!/bin/sh

VPNUP='vpnup.sh'
VPNDOWN='vpndown.sh'
VPNLOG='/tmp/autoddvpn.log'
#PPTPSRVSUB=$(nvram get pptpd_client_srvsub)
DLDIR='http://autoddvpn.googlecode.com/svn/trunk/'
#CRONJOBS="* * * * * root /bin/sh /tmp/check.sh >> /tmp/last_check.log"
PID=$$
INFO="[INFO#${PID}]"
DEBUG="[DEBUG#${PID}]"
IPUP="/tmp/openvpncl/route-up.sh"
IPDOWN="/tmp/openvpncl/route-down.sh"


echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") log starts" >> $VPNLOG
echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") openvpn+wget mode" >> $VPNLOG

cd /tmp;
echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") wgetting vpnup.sh" >> $VPNLOG
wget "${DLDIR}vpnup.sh" && chmod a+x vpnup.sh
echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") wgetting vpndown.sh" >> $VPNLOG
wget "${DLDIR}vpndown.sh" && chmod a+x vpndown.sh

echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") modifying $IPUP" >> $VPNLOG

for i in 1 2 3 4 5 6 7 8 9 10 11 12
do
	if [ -e $IPUP ]; then
		#sed -ie 's#exit 0#/jffs/vpnup.sh\nexit 0#g' $IPUP
		echo '/tmp/vpnup.sh openvpn' >> $IPUP
		echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") $IPUP modified" >> $VPNLOG
		break
	else
		echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") $IPUP not exists, sleep 10sec." >> $VPNLOG
		sleep 10
	fi
done

echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") modifying $IPDOWN" >> $VPNLOG
if [ -e $IPDOWN ]; then
	#sed -ie 's#exit 0#/jffs/vpndown.sh\nexit 0#g' $IPDOWN
	echo '/tmp/vpndown.sh openvpn' >> $IPDOWN
	echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") $IPDOWN modified" >> $VPNLOG
else
	echo "$IPDOWN not exists" >> $VPNLOG
fi
	
echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") ALL DONE. Let's wait for VPN being connected." >> $VPNLOG



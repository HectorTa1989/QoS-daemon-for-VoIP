# Starts and stops QOS based on VoIP activity

# Threshold at which to switch QOS on or off
export THRESHOLD=1000
# Number of time steps for which VoIP bandwidth needs
# to be above threshold (VoIP periodically pings server, 
# so going over once does not imply a connection)
export THRESHOLDCOUNT=3
# IP of VoIP device
export IP=192.168.2.30
# Time between steps. 1 second. In sleep format. 
export TIMESTEP=1

export NEW_VALUE=0
export PACKET_CNT=0
export TICKS_OVER_THRESHOLD=0
export TICKS_UNDER_THRESHOLD=0
export QOS_STATE=stopped
do_qos_stop() {
  date > /tmp/qos-state
  echo qos off >> /tmp/qos-state
  qos-stop
  export QOS_STATE=stopped
}
do_qos_start() {
  date > /tmp/qos-state
  echo qos on >> /tmp/qos-state
  qos-start
  export QOS_STATE=started
}

qos_start() {
  if [ $QOS_STATE == "stopped" ] ; then
    do_qos_start
  fi
}

qos_stop() {
  if [ $QOS_STATE == "started" ] ; then
    do_qos_stop
  fi
}
                            
export QOS_STOP_CNT=0
do_qos_stop
while [ "1" != "2" ] ; do 
  sleep $TIMESTEP
  export OLD_VALUE=$NEW_VALUE
  cat /proc/net/ip_conntrack |grep $IP|cut -d= -f 12 > /tmp/tmp
  export NEW_VALUE=`cat /tmp/tmp |xargs echo expr 0 |sed -e 's/ / + /g'|sed -e 's/r +/r/g'|ash` 
  export PACKET_CNT=`expr $NEW_VALUE - $OLD_VALUE`
#  echo $PACKET_CNT
  if [ $THRESHOLD -le $PACKET_CNT ] ; then
    export TICKS_OVER_THRESHOLD=`expr $TICKS_OVER_THRESHOLD + 1`
    export TICKS_UNDER_THRESHOLD=0
  else
    export TICKS_OVER_THRESHOLD=0
    export TICKS_UNDER_THRESHOLD=`expr $TICKS_UNDER_THRESHOLD + 1`
  fi 
  if [ $THRESHOLDCOUNT -le $TICKS_OVER_THRESHOLD ] ; then
    qos_start
  fi
  if [ $THRESHOLDCOUNT -le $TICKS_UNDER_THRESHOLD ] ; then
    qos_stop                
  fi

done

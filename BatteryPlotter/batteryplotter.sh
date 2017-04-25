# GNU GPLv3 - Grim Kriegor <grimkriegor@krutt.org> (2017)
# A simple script to graphically inspect battery health

#!/bin/bash

#Config
BATTERY_FILE="/sys/class/power_supply/BAT0/capacity"
LOG_FILE="battery.log"
DEFAULT_INTERVAL=5

PLOT_SCRIPT="\
set title \"Battery capacity over time\"
set xlabel \"Time (s)\"
set ylabel \"Capacity (%)\"
set terminal png size 600,500 enhanced font \"Liberation Sans,9\"
set output \"battery-graph.png\"
plot \"battery.table\" using 1:2 with lines\
"

if [ "$1" == "" ]; then
  INTERVAL=$DEFAULT_INTERVAL

elif [ "$1" == "plot" ]; then
  if [ ! -f battery.table ]; then
    bash $0 clean
  fi

  echo -e "$PLOT_SCRIPT" > plot.script
  gnuplot plot.script

  rm plot.script
  rm battery.table
  exit 0

elif [ "$1" == "clean" ]; then
  awk 'NR % 2 == 0' "$LOG_FILE" > battery.table
  exit 0

else
  INTERVAL=$1

fi

COUNT=0
while true; do 
  uptime | tee -a "$LOG_FILE"
  echo $COUNT	$(cat "$BATTERY_FILE") | tee -a "$LOG_FILE"
  COUNT=$(($COUNT+$INTERVAL))
  sleep $INTERVAL
done

exit 0

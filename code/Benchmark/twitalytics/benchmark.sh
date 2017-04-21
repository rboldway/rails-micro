#!/usr/bin/env bash
#---
# Excerpted from "Deploying with JRuby 9k",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit http://www.pragmaticprogrammer.com/titles/jkdepj2 for more book information.
#---

JRUBY_GC=${1:-""}
JRUBY_HEAP=${2:-""}
FHB_OPTS=${3:-""}
SAVE_OPT=${4:-"10"}

output() {
  local logfile="$1"
  local prefix="$2"
  local c="s/^/[$prefix] /"

  case $(uname) in
    Darwin) tee -a "$logfile" | sed -l "$c";; # mac/bsd sed: -l buffers on line boundaries
    *)      tee -a "$logfile" | sed -u "$c";; # unix/gnu sed: -u unbuffered chunks of data
  esac
}


if [ -n "$HEROKU_APP_NAME" ]; then
  appHost="${HEROKU_APP_NAME}.herokuapp.com"
else
  appHost="localhost:3000"
fi
benchUrl="http://${appHost}/bench/index?save=${SAVE_OPT}"
fhbLogFile="log/fhb.log"
fhbTmpDir="tmp/${HEROKU_APP_NAME:-localhost}/fhb"

if [ -z "$HEROKU_APP_NAME" ]; then
  echo "Running: ruby ${JRUBY_GC} ${JRUBY_HEAP} -S bin/puma"
  eval "ruby ${JRUBY_GC} ${JRUBY_HEAP} -S bin/puma &"
  pid_jruby=$!

  trap "kill -9 $pid_jruby; exit" SIGKILL
  trap "kill -9 $pid_jruby; exit" SIGINT
  trap "kill -9 $pid_jruby; exit" SIGTERM
else
  heroku config:set JRUBY_OPTS="${JRUBY_GC} ${JRUBY_HEAP}" -a ${HEROKU_APP_NAME}
  #heroku ps:restart -a ${HEROKU_APP_NAME}
fi

sleep 20

echo "" > $fhbLogFile
echo "\nRunning: fhb -D ${fhbTmpDir} ${FHB_OPTS} ${benchUrl}"
eval "fhb -D ${fhbTmpDir} ${FHB_OPTS} ${benchUrl} 2>&1 | output $fhbLogFile fhb &"

sleep 5

pid_fhb=$(jps | grep FabanHTTPBench | cut -d " " -f1)

trap "kill -9 $pid_jruby; kill -9 $pid_fhb; exit" SIGKILL
trap "kill -9 $pid_jruby; kill -9 $pid_fhb; exit" SIGINT
trap "kill -9 $pid_jruby; kill -9 $pid_fhb; exit" SIGTERM

sleep 15

echo "\nRun: ${JRUBY_GC} ${JRUBY_HEAP} ${FHB_OPTS} save=${SAVE_OPT}" >> ${fhbTmpDir}/cpu.log
echo "\nRun: ${JRUBY_GC} ${JRUBY_HEAP} ${FHB_OPTS} save=${SAVE_OPT}" >> ${fhbTmpDir}/jstat.log

until grep -qi "INFO: Detail finished" "$fhbLogFile"; do
  sleep 5
  if [ -z "$HEROKU_APP_NAME" ]; then
    ps -p$pid_jruby -opid -opcpu -ocomm -c | grep $pid_jruby >> ${fhbTmpDir}/cpu.log
  fi
done

kill -9 $pid_fhb

if [ -z "$HEROKU_APP_NAME" ]; then
  jstat -gcutil $pid_jruby >> ${fhbTmpDir}/jstat.log
  kill -9 $pid_jruby
fi

echo "done"

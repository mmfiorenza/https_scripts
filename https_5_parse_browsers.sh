#!/bin/bash

[ $1 ] || { echo "Uso: $0 <logs_dir>"; exit; }

IN_DIR="$1"
OUT_DIR=outputs

[ -d $OUT_DIR ] || { mkdir -p $OUT_DIR; }

BROWSERS=('Android 4.4.2' 'Android 5.0.0' 'Android 6.0' 'Android 7.0' 'Android 8.1' 'Android 9.0' 'Android 10.0' 'Chrome 74' 'Chrome 79' 'Firefox 66' 'Firefox 71' 'IE 6 XP' 'IE 8 Win 7' 'IE 8 XP' 'IE 11 Win 7' 'IE 11 Win 8.1' 'IE 11 Win Phone 8.1' 'IE 11 Win 10' 'Edge 15 Win 10' 'Edge 17 (Win 10)' 'Opera 66 (Win 10)' 'Safari 9 iOS 9' 'Safari 9 OS X 10.11' 'Safari 10 OS X 10.12' 'Safari 12.1 (iOS 12.2)' 'Safari 13.0 (macOS 10.14.6)' 'Apple ATS 9 iOS 9' 'Java 6u45' 'Java 7u25' 'Java 8u161' 'Java 11.0.2' 'Java 12.0.1' 'OpenSSL 1.0.2e' 'OpenSSL 1.1.0l' 'OpenSSL 1.1.1d' 'Thunderbird')

TMP_FILE=$(mktemp)
TS=$(date +%Y%m%d%H%M%S)

for ((x=0; x < ${#BROWSERS[*]}; x++))
do
    OUT_FILE="$OUT_DIR/"`echo ${BROWSERS[$x]} | sed 's/ /_/g;s/-/_/g' | tr [[:upper:]] [[:lower:]]`".txt"
    [ ! -f $OUT_FILE ] || { mv $OUT_FILE $OUT_FILE.bak.$TS; }
	echo -n "collecting stats for browser/system ${BROWSERS[$x]} ... "
	echo "${BROWSERS[$x]}" > $OUT_FILE
	echo "No connection" > $TMP_FILE
	grep "${BROWSERS[$x]}" "$IN_DIR/"*.log | sed -n 's/^.*SSLv\(.*\)No.*$/\1/p' | sed 's/^/SSLv/' | sort -u >> $TMP_FILE
	grep "${BROWSERS[$x]}" "$IN_DIR/"*.log | sed -n 's/^.*TLSv\(.*\)bit.*$/\1/p' | sed 's/^/TLSv/' | sort -u >> $TMP_FILE
	while read PROTOCOL
	do
  		RESULT=`grep "${BROWSERS[$x]}" "$IN_DIR/"*.log | grep "$PROTOCOL" | sort -u | wc -l`
  		echo "$PROTOCOL"";""$RESULT" >> $OUT_FILE
	done < $TMP_FILE
    echo "done."
done


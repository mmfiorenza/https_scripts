#!/bin/bash

[ $1 ] && [ -f $1 ] || { echo "Uso: $0 <arquivo.csv>"; exit; }

sed '/^#.*$/d' $1 > .t; mv .t $1

NCOL=$(head -n1 $1 | grep -o ";" | wc -l)

for i in `seq 2 $NCOL`
do
    COLNAME=$(head -n1 $1 | cut -d";" -f$i | sed 's/\///g;s/(//g;s/)//g;s/\[//g;s/\]//g;s/\?//g;s/\+//g;s/ *//g;s/-//g;s/,//g;s/://g')
    grep -v ^FileName $1 | cut -d";" -f$i > values.tmp
    sort values.tmp | uniq > uniq.tmp
    while read VALUE
    do
        COUNTER=$(grep -w "$VALUE" values.tmp | wc -l)
        echo -n "$COLNAME "
        echo "$COUNTER $VALUE" | sed 's/^ *//'
    done < uniq.tmp
done

[ ! -f values.tmp ] || { rm -f values.tmp; }
[ ! -f uniq.tmp ] || { rm -f uniq.tmp; }


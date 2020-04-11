#!/bin/bash

[ $1 ] && [ -f $1 ] || { echo "Uso: $0 <lista_de_sites.txt>"; exit; }

TSSL_DIR=testssl

[ -d $TSSL_DIR ] || {
    mkdir $TSSL_DIR
    pushd $TSSL_DIR
    wget -o /dev/null --output-document=testssl-3.0.tar.gz https://testssl.sh/testssl-3.0.tar.gz
    tar xzf testssl-3.0.tar.gz
    mkdir outputs
    popd
}

while read URL
do
    URL=$(echo $URL | sed 's/^htt.*:\/\///')
    (cd $TSSL_DIR; ./testssl.sh --color 0 "$URL" &> outputs/$URL.log; cd ..)
done < $1


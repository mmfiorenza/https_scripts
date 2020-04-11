#!/bin/bash

[ $1 ] && [ -f $1 ] || { echo "Uso: $0 <arq1.log> <arq2.log> <arq3.log> ..."; exit; }

echo "FileName;SSLv2;SSLv3;TLS1;TLS1.1;TLS1.2;TLS1.3;NPN/SPDY;ALPN/HTTP2;NULL ciphers;Anonymous NULL Ciphers;Export ciphers (w/o ADH+NULL);Triple DES Ciphers / IDEA;Obsolete: SEED + 128+256 Bit CBC cipher;Strong encryption (AEAD ciphers);LOW: 64 Bit + DES, RC[2,4] (w/o export);PFS is offered (OK);Elliptic curves offered;Has server cipher order?;Negotiated protocol;Negotiated cipher;Session Resumption;TLS clock skew;Signature Algorithm;Server key size;Server key usage;Server extended key usage;Issuer;Trust (hostname);Chain of trust;EV cert (experimental);Certificate Validity;DNS CAA RR (experimental);Certificate Transparency;Heartbleed (CVE-2014-0160);CCS (CVE-2014-0224);Ticketbleed (CVE-2016-9244);Secure Client-Initiated Renegotiation;CRIME, TLS (CVE-2012-4929);POODLE, SSL (CVE-2014-3566);SWEET32 (CVE-2016-2183, CVE-2016-6329);FREAK (CVE-2015-0204);DROWN (CVE-2016-0800, CVE-2016-0703);LOGJAM (CVE-2015-4000);BEAST (CVE-2011-3389);LUCKY13 (CVE-2013-0169);RC4 (CVE-2013-2566, CVE-2015-2808);TLS_FALLBACK_SCSV (RFC 7507);BREACH (CVE-2013-3587);Secure Renegotiation (RFC 5746);"

check_if_not_string() {
    RESULT=$(grep -w "$2" $1 | head -n 1 | grep -w "$3")
    if [ "$RESULT" = "" ]
    then
        echo -n true
    else
        echo -n false
    fi
}
check_if_string() {
    RESULT=$(grep -w "$2" $1 | head -n 1 | grep -w "$3")
    if [ "$RESULT" != "" ]
    then
        echo -n true
    else
        echo -n false
    fi
}

NOTLS_COUNTER=0
NOTLS_LIST=""
FERROR_COUNTER=0
FERROR_LIST=""
while [ $# -gt 0 ]
do
    RESULT=$(grep -w "Make sure a firewall is not between you and your scanning target" $1)
    if [ "$RESULT" != "" ]
    then
        FERROR_COUNTER=$((FERROR_COUNTER+1))
        FERROR_LIST="$FERROR_LIST $1"
        shift
        continue
    fi
    RESULT=$(grep -w "seem to be a TLS/SSL enabled server" $1)
    if [ "$RESULT" != "" ]
    then
        NOTLS_COUNTER=$((NOTLS_COUNTER+1))
        NOTLS_LIST="$NOTLS_LIST $1"
        shift
        continue
    fi
    FNAME=$(echo $1 | sed 's/^.*\///')
    echo -n "$FNAME;"
    for string in SSLv2 SSLv3 "TLS 1" "TLS 1.1" "TLS 1.2" "TLS 1.3"
    do
        check_if_not_string $1 "$string" "not offered"
        echo -n ";"
    done
    for string in "NPN/SPDY" "ALPN/HTTP2"
    do
        check_if_not_string $1 "$string" "not offered"
        echo -n ";"
    done
    for string in "NULL ciphers" "Anonymous NULL Ciphers" "Export ciphers (w/o ADH+NULL)" "Triple DES Ciphers / IDEA" "Obsolete: SEED + 128+256 Bit CBC cipher" "Strong encryption (AEAD ciphers)"
    do
        check_if_not_string $1 "$string" "not offered"
        echo -n ";"
    done
    for string in "LOW: 64 Bit + DES, RC[2,4] (w/o export)"
    do
        check_if_string $1 "$string" "not offered"
        echo -n ";"
    done
    
    RESULT=$(grep -w "PFS is offered (OK)" $1 | head -n 1)
    if [ "$RESULT" != "" ]
    then
        echo -n "true;"
    else
        echo -n "false;"
    fi
    RESULT=$(grep -w "Elliptic curves offered" $1 | head -n 1 | sed 's/^.*Elliptic curves offered: *//')
    echo -n "$RESULT;"
    
    RESULT=$(grep -w "Has server cipher order?" $1 | head -n 1 | grep -w "yes (OK)")
    if [ "$RESULT" != "" ]
    then
        #RESULT=$(echo $RESULT | sed 's/^.*-- //')
        #echo -n "true $RESULT;"
        echo -n "true;"
    else
        echo -n "false;"
    fi
    RESULT=$(grep -w "Negotiated protocol" $1 | head -n 1 | sed 's/^.*Negotiated protocol *//')
    echo -n "$RESULT;"
    RESULT=$(grep -w "Negotiated cipher" $1 | head -n 1 | sed 's/^.*Negotiated cipher *//')
    echo -n "$RESULT;"
    RESULT=$(grep -w "Session Resumption" $1 | head -n 1 | sed 's/^.*Session Resumption *//')
    echo -n "$RESULT;"
    RESULT=$(grep -w "TLS clock skew" $1 | head -n 1 | sed 's/^.*TLS clock skew *//')
    echo -n "$RESULT;"
    RESULT=$(grep -w "Signature Algorithm" $1 | head -n 1 | sed 's/^.*Signature Algorithm *//')
    echo -n "$RESULT;"
    RESULT=$(grep -w "Server key size" $1 | head -n 1 | sed 's/^.*Server key size *//')
    echo -n "$RESULT;"
    RESULT=$(grep -w "Server key usage" $1 | head -n 1 | sed 's/^.*Server key usage *//')
    echo -n "$RESULT;"
    RESULT=$(grep -w "Server extended key usage" $1 | head -n 1 | sed 's/^.*Server extended key usage *//')
    echo -n "$RESULT;"
    RESULT=$(grep -w "Issuer" $1 | head -n 1 | sed 's/^.*Issuer *//')
    echo -n "$RESULT;"
    RESULT=$(grep -w "Trust (hostname)" $1 | head -n 1 | sed 's/^.*Trust (hostname) *//')
    echo -n "$RESULT;"
    RESULT=$(grep -w "Chain of trust" $1 | head -n 1 | sed 's/^.*Chain of trust *//')
    echo -n "$RESULT;"
    RESULT=$(grep -w "EV cert (experimental)" $1 | head -n 1 | sed 's/^.*EV cert (experimental) *//')
    echo -n "$RESULT;"
    RESULT=$(grep -w "Certificate Validity" $1 | head -n 1 | sed 's/^.*Certificate Validity *//')
    echo -n "$RESULT;"
    RESULT=$(grep -w "DNS CAA RR (experimental)" $1 | head -n 1 | sed 's/^.*DNS CAA RR (experimental) *//')
    echo -n "$RESULT;"
    RESULT=$(grep -w "Certificate Transparency" $1 | head -n 1 | sed 's/^.*Certificate Transparency *//')
    echo -n "$RESULT;"
    for string in "Heartbleed (CVE-2014-0160)" "CCS (CVE-2014-0224)" "Ticketbleed (CVE-2016-9244)" "Secure Client-Initiated Renegotiation" "CRIME, TLS (CVE-2012-4929)" "POODLE, SSL (CVE-2014-3566)" "SWEET32 (CVE-2016-2183, CVE-2016-6329)" "FREAK (CVE-2015-0204)" "DROWN (CVE-2016-0800, CVE-2016-0703)" "LOGJAM (CVE-2015-4000)" "BEAST (CVE-2011-3389)" "LUCKY13 (CVE-2013-0169)" 
    do
        check_if_not_string $1 "$string" "not vulnerable"
        echo -n ";"
    done
    for string in "RC4 (CVE-2013-2566, CVE-2015-2808)"
    do
        check_if_not_string $1 "$string" "no RC4 ciphers detected"
        echo -n ";"
    done
    for string in "TLS_FALLBACK_SCSV (RFC 7507)"
    do
        RESULT=$(grep -w "$string" $1 | head -n 1 | grep -w -E "(Downgrade attack prevention supported|No fallback possible)")
        if [ "$RESULT" != "" ]
        then
            echo -n true
        else
            echo -n false
        fi
        echo -n ";"
    done
    for string in "BREACH (CVE-2013-3587)"
    do
        check_if_not_string $1 "$string" "no HTTP compression"
        echo -n ";"
    done
    for string in "Secure Renegotiation (RFC 5746)"
    do
        check_if_not_string $1 "$string" "OpenSSL handshake didn"
        echo -n ";"
    done
    echo ""
    shift
done

echo "# List of hosts with firewall ERROR: $FERROR_LIST"
echo "# Number of hosts with firewall ERROR: $FERROR_COUNTER"
echo "# List doesn't seem to be a TLS/SSL enabled server: $NOTLS_LIST"
echo "# Number doesn't seem to be a TLS/SSL enabled server: $NOTLS_COUNTER"


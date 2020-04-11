#!/bin/bash

[ $1 ] && [ -f $1 ] || { echo "Uso: $0 <arquivo.csv>"; exit; }

TMPFILE=$(mktemp)
sed 's/true/T/g;s/false/F/g;/^\([^ ]*\) \([0-9]*\) *$/d' $1 > $TMPFILE

grafico_versoes_ssl_tls() {
    sed 's/TLS1.1/TLS11/g;s/TLS1.2/TLS12/g;s/TLS1.3/TLS13/g' $TMPFILE > .t
    mv .t $TMPFILE
    for i in SSLv2 SSLv3 TLS1 TLS11 TLS12 TLS13
    do
        grep -w -E "(^$i)" $TMPFILE | sed 's/\(.*\) \([0-9]*\) \([TF]\) *$/\1\3 \2/'
    done
}

grafico_ciphers() {
    for i in NULLciphers AnonymousNULLCiphers ExportcipherswoADHNULL TripleDESCiphersIDEA ObsoleteSEED128256BitCBCcipher StrongencryptionAEADciphers LOW64BitDESRC24woexport
    do
        grep -w -E "(^$i)" $TMPFILE | grep -w T | sed 's/ T$//'
    done
}

grafico_pfs(){
    grep -w -E "(^PFSisofferedOK)" $TMPFILE | sed 's/\(.*\) \([0-9]*\) \([TF]\) *$/\1\3 \2/'
}

clear_issuer(){
    grep -w -E "(^Issuer)" $TMPFILE | sed 's/^Issuer \([0-9]*\) .*CloudFlare.*$/\1 CloudFlare/g' | grep -w "CloudFlare"
    grep -w -E "(^Issuer)" $TMPFILE | sed 's/^Issuer \([0-9]*\) .*COMODO CA.*$/\1 COMODO CA/g' | grep -w "COMODO CA"
    grep -w -E "(^Issuer)" $TMPFILE | sed 's/^Issuer \([0-9]*\) .*DigiCert.*$/\1 DigiCert/g' | grep -w "DigiCert"
    grep -w -E "(^Issuer)" $TMPFILE | sed 's/^Issuer \([0-9]*\) .*Entrust.*$/\1 Entrust/g' | grep -w "Entrust"
    grep -w -E "(^Issuer)" $TMPFILE | sed 's/^Issuer \([0-9]*\) .*Google Trust Services.*$/\1 Google Trust Services/g' | grep -w "Google Trust Services"
    grep -w -E "(^Issuer)" $TMPFILE | sed 's/^Issuer \([0-9]*\) .*GlobalSign.*$/\1 GlobalSign/g' | grep -w "GlobalSign"
    grep -w -E "(^Issuer)" $TMPFILE | sed 's/^Issuer \([0-9]*\) .*Globe Hosting.*$/\1 Globe Hosting/g' | grep -w "Globe Hosting"
    grep -w -E "(^Issuer)" $TMPFILE | sed 's/^Issuer \([0-9]*\) .*Amazon.*$/\1 Amazon/g' | grep -w "Amazon"
    grep -w -E "(^Issuer)" $TMPFILE | sed 's/^Issuer \([0-9]*\) .*GoDaddy.com.*$/\1 GoDaddy.com/g' | grep -w "GoDaddy.com"
    grep -w -E "(^Issuer)" $TMPFILE | sed 's/^Issuer \([0-9]*\) .*Network Solutions.*$/\1 Network Solutions/g' | grep -w "Network Solutions"
    grep -w -E "(^Issuer)" $TMPFILE | sed 's/^Issuer \([0-9]*\) .*Parallels.*$/\1 Parallels/g' | grep -w "Parallels"
    grep -w -E "(^Issuer)" $TMPFILE | sed 's/^Issuer \([0-9]*\) .*Let.s Encrypt.*$/\1 Lets Encrypt/g' | grep -w "Lets Encrypt"
    grep -w -E "(^Issuer)" $TMPFILE | sed 's/^Issuer \([0-9]*\) .*Plesk.*$/\1 Plesk/g' | grep -w "Plesk"
    grep -w -E "(^Issuer)" $TMPFILE | sed 's/^Issuer \([0-9]*\) .*GeoTrust.*$/\1 GeoTrust/g' | grep -w "GeoTrust"
    grep -w -E "(^Issuer)" $TMPFILE | sed 's/^Issuer \([0-9]*\) .*Site Blindado.*$/\1 Site Blindado/g' | grep -w "Site Blindado"
    grep -w -E "(^Issuer)" $TMPFILE | sed 's/^Issuer \([0-9]*\) .*Sectigo Limited.*$/\1 Sectigo Limited/g' | grep -w "Sectigo Limited"
    grep -w -E "(^Issuer)" $TMPFILE | sed 's/^Issuer \([0-9]*\) .*Starfield Technologies.*$/\1 Starfield Technologies/g' | grep -w "Starfield Technologies"
    grep -w -E "(^Issuer)" $TMPFILE | sed 's/^Issuer \([0-9]*\) .*TrustSign Certificadora.*$/\1 TrustSign Certificadora/g' | grep -w "TrustSign Certificadora"
    grep -w -E "(^Issuer)" $TMPFILE | sed 's/^Issuer \([0-9]*\) .*cPanel.*$/\1 cPanel/g' | grep -w "cPanel"
    grep -w -E "(^Issuer)" $TMPFILE | sed 's/^Issuer \([0-9]*\) .*thawte.*$/\1 thawte/g' | grep -w "thawte"
    grep -w -E "(^Issuer)" $TMPFILE | sed 's/^Issuer \([0-9]*\) .*DreamHost.*$/\1 DreamHost/g' | grep -w "DreamHost"
}

grafico_issuer(){
    clear_issuer > .issuer.log
    cut -d" " -f2- .issuer.log | sort -u > .issuer.uniq
    COUNTER=0
    while read ISSUER
    do
        SUM=$(grep -w "$ISSUER" .issuer.log | cut -d" " -f1)
        SUM=$(echo $SUM | sed 's/ /+/g' | bc)
        if [ $SUM -gt 1 ]
        then
            echo $SUM $ISSUER
            COUNTER=$((COUNTER+SUM))
        fi
    done < .issuer.uniq
    TOTAL=$(grep -w -E "(^Issuer)" $TMPFILE | cut -d" " -f2)
    TOTAL=$(echo $TOTAL | sed 's/ /+/g' | bc)
    DIFF=$((TOTAL-COUNTER))
    echo "$DIFF Outras ACs"
    rm -f .issuer.log .issuer.uniq
}

grafico_trust_host(){
    TOTAL=$(grep -w -E "(^Trusthostname)" $TMPFILE | cut -d" " -f2)
    TOTAL=$(echo $TOTAL | sed 's/ /+/g' | bc)
    NOMATCH=$(grep -w -E "(^Trusthostname)" $TMPFILE | grep -w "certificate does not match supplied URI" | cut -d" " -f2)
    TOTAL=$((TOTAL-NOMATCH))
    echo "TrusthostnameOK $TOTAL"
    echo "TrusthostnameFAIL $NOMATCH"
}

grafico_chain_of_trust(){
    echo -n "ChainoftrustChainIncomplete "
    grep -w -E "(^Chainoftrust)" $TMPFILE | grep -w "chain incomplete" | cut -d" " -f2
    echo -n "ChainoftrustExpired "
    grep -w -E "(^Chainoftrust)" $TMPFILE | grep -w "expired" | cut -d" " -f2
    echo -n "ChainoftrustSelfSignedCA "
    grep -w -E "(^Chainoftrust)" $TMPFILE | grep -w "self signed CA in chain" | cut -d" " -f2
    echo -n "ChainoftrustSelfSigned "
    grep -w -E "(^Chainoftrust)" $TMPFILE | grep -w "(self signed)" | cut -d" " -f2
    echo -n "ChainoftrustOk "
    grep -w -E "(^Chainoftrust)" $TMPFILE | grep -w "Ok" | cut -d" " -f2
}

grafico_signature_algorithm(){
    echo -n "ECDSAwithSHA256 "
    grep -w -E "(^SignatureAlgorithm)" $TMPFILE | grep -w "ECDSA with SHA256" | cut -d" " -f2
    echo -n "MD5 "
    grep -w -E "(^SignatureAlgorithm)" $TMPFILE | grep -w "MD5" | cut -d" " -f2
    echo -n "SHA1withRSA "
    grep -w -E "(^SignatureAlgorithm)" $TMPFILE | grep -w "SHA1 with RSA" | cut -d" " -f2
    echo -n "SHA256withRSA "
    grep -w -E "(^SignatureAlgorithm)" $TMPFILE | grep -w "SHA256 with RSA" | cut -d" " -f2
}

grafico_certificate_validity(){
    echo -n "expired "
    SUM=$(grep -w -E "(^CertificateValidity)" $TMPFILE | grep -w "expired" | cut -d" " -f2)
    echo $SUM | sed 's/ /+/g' | bc
    echo -n "expires "
    SUM=$(grep -w -E "(^CertificateValidity)" $TMPFILE | grep -w "expires" | cut -d" " -f2)
    echo $SUM | sed 's/ /+/g' | bc
    echo -n ">=60days "
    SUM=$(grep -w -E "(^CertificateValidity)" $TMPFILE | grep -v -w -E "(expires|expired)" | cut -d" " -f2)
    echo $SUM | sed 's/ /+/g' | bc

}

grafico_vulnerabilities(){
    for i in HeartbleedCVE20140160 CCSCVE20140224 TicketbleedCVE20169244 SecureClientInitiatedRenegotiation CRIMETLSCVE20124929 POODLESSLCVE20143566 SWEET32CVE20162183CVE20166329 FREAKCVE20150204 DROWNCVE20160800CVE20160703 LOGJAMCVE20154000 BEASTCVE20113389 LUCKY13CVE20130169 RC4CVE20132566CVE20152808 TLS_FALLBACK_SCSVRFC7507 BREACHCVE20133587 SecureRenegotiationRFC5746
    do
        N=$(echo $i | sed 's/CVE.*$//g')
        echo -n "$N "
        grep -w "$i" $TMPFILE | grep -w -E "(T$)" | cut -d" " -f2
    done
}

grafico_keysize(){
    for i in "EC 256 bits" "EC 384 bits" "RSA 1024 bits" "RSA 2048 bits" "RSA 3072 bits" "RSA 4096 bits"
    do
        N=$(echo $i | sed 's/ //g')
        echo -n "$N "
        grep -w "Serverkeysize" $TMPFILE | grep -w -E "($i)" | cut -d" " -f2
    done
}

grafico_versoes_ssl_tls > grafico_versoes_ssl_tls.txt
grafico_ciphers > grafico_ciphers.txt
grafico_pfs > grafico_pfs.txt
grafico_issuer > grafico_issuer.txt
grafico_trust_host > grafico_trusthost.txt
grafico_chain_of_trust > grafico_chainoftrust.txt
grafico_signature_algorithm > grafico_signature_algorithm.txt
grafico_certificate_validity > grafico_certificate_validity.txt
grafico_vulnerabilities > grafico_vulnerabilities.txt
grafico_keysize > grafico_keysize.txt

rm -f $TMPFILE

#!/bin/bash

function one_line_pem {
    echo "`awk 'NF {sub(/\\n/, ""); printf "%s\\\\\\\n",$0;}' $1`"
}

function json_ccp {
    local PP=$(one_line_pem $4)
    local CP=$(one_line_pem $5)
    sed -e "s/\${ORG}/$1/" \
        -e "s/\${P0PORT}/$2/" \
        -e "s/\${CAPORT}/$3/" \
        -e "s#\${PEERPEM}#$PP#" \
        -e "s#\${CAPEM}#$CP#" \
        organizations/ccp-template.json
}

function yaml_ccp {
    local PP=$(one_line_pem $4)
    local CP=$(one_line_pem $5)
    sed -e "s/\${ORG}/$1/" \
        -e "s/\${P0PORT}/$2/" \
        -e "s/\${CAPORT}/$3/" \
        -e "s#\${PEERPEM}#$PP#" \
        -e "s#\${CAPEM}#$CP#" \
        organizations/ccp-template.yaml | sed -e $'s/\\\\n/\\\n          /g'
}

ORG="pharmacy"
P0PORT=7051
CAPORT=7054
PEERPEM=organizations/peerOrganizations/pharmacy.moh.gov.om/tlsca/tlsca.pharmacy.moh.gov.om-cert.pem
CAPEM=organizations/peerOrganizations/pharmacy.moh.gov.om/ca/ca.pharmacy.moh.gov.om-cert.pem

echo "$(json_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/pharmacy.moh.gov.om/connection-pharmacy.json
echo "$(yaml_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/pharmacy.moh.gov.om/connection-pharmacy.yaml

ORG="manufacturer"
P0PORT=9051
CAPORT=8054
PEERPEM=organizations/peerOrganizations/manufacturer.moh.gov.om/tlsca/tlsca.manufacturer.moh.gov.om-cert.pem
CAPEM=organizations/peerOrganizations/manufacturer.moh.gov.om/ca/ca.manufacturer.moh.gov.om-cert.pem

echo "$(json_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/manufacturer.moh.gov.om/connection-manufacturer.json
echo "$(yaml_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/manufacturer.moh.gov.om/connection-manufacturer.yaml

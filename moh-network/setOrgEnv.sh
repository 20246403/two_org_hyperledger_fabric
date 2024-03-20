#!/bin/bash
#
# SPDX-License-Identifier: Apache-2.0




# default to using Pharmacy
ORG=${1:-Pharmacy}

# Exit on first error, print all commands.
set -e
set -o pipefail

# Where am I?
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"

ORDERER_CA=${DIR}/moh-network/organizations/ordererOrganizations/moh.gov.om/tlsca/tlsca.moh.gov.om-cert.pem
PEER0_PHARMACY_CA=${DIR}/moh-network/organizations/peerOrganizations/pharmacy.moh.gov.om/tlsca/tlsca.pharmacy.moh.gov.om-cert.pem
PEER0_MANUFACTURER_CA=${DIR}/moh-network/organizations/peerOrganizations/manufacturer.moh.gov.om/tlsca/tlsca.manufacturer.moh.gov.om-cert.pem
PEER0_ORG3_CA=${DIR}/moh-network/organizations/peerOrganizations/org3.moh.gov.om/tlsca/tlsca.org3.moh.gov.om-cert.pem


if [[ ${ORG,,} == "pharmacy" || ${ORG,,} == "1" ]]; then
	echo "********* pharmacy"
   CORE_PEER_LOCALMSPID=PharmacyMSP
   CORE_PEER_MSPCONFIGPATH=${DIR}/moh-network/organizations/peerOrganizations/pharmacy.moh.gov.om/users/Admin@pharmacy.moh.gov.om/msp
   CORE_PEER_ADDRESS=localhost:7051
   CORE_PEER_TLS_ROOTCERT_FILE=${DIR}/moh-network/organizations/peerOrganizations/pharmacy.moh.gov.om/tlsca/tlsca.pharmacy.moh.gov.om-cert.pem

elif [[ ${ORG,,} == "manufacturer" || ${ORG,,} == "2" ]]; then
   echo "********* manufacturer"
   CORE_PEER_LOCALMSPID=ManufacturerMSP
   CORE_PEER_MSPCONFIGPATH=${DIR}/moh-network/organizations/peerOrganizations/manufacturer.moh.gov.om/users/Admin@manufacturer.moh.gov.om/msp
   CORE_PEER_ADDRESS=localhost:9051
   CORE_PEER_TLS_ROOTCERT_FILE=${DIR}/moh-network/organizations/peerOrganizations/manufacturer.moh.gov.om/tlsca/tlsca.manufacturer.moh.gov.om-cert.pem

else
	echo "********* Unknown"
   echo "Unknown \"$ORG\", please choose Pharmacy/Digibank or Manufacturer/Magnetocorp"
   echo "For example to get the environment variables to set upa Manufacturer shell environment run:  ./setOrgEnv.sh Manufacturer"
   echo
   echo "This can be automated to set them as well with:"
   echo
   echo 'export $(./setOrgEnv.sh Manufacturer | xargs)'
   exit 1
fi

# output the variables that need to be set
echo "CORE_PEER_TLS_ENABLED=true"
echo "ORDERER_CA=${ORDERER_CA}"
echo "PEER0_PHARMACY_CA=${PEER0_PHARMACY_CA}"
echo "PEER0_MANUFACTURER_CA=${PEER0_MANUFACTURER_CA}"
echo "PEER0_ORG3_CA=${PEER0_ORG3_CA}"

echo "CORE_PEER_MSPCONFIGPATH=${CORE_PEER_MSPCONFIGPATH}"
echo "CORE_PEER_ADDRESS=${CORE_PEER_ADDRESS}"
echo "CORE_PEER_TLS_ROOTCERT_FILE=${CORE_PEER_TLS_ROOTCERT_FILE}"

echo "CORE_PEER_LOCALMSPID=${CORE_PEER_LOCALMSPID}"

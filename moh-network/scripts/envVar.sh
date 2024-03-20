#!/bin/bash
#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#

# This is a collection of bash functions used by different scripts

# imports
. scripts/utils.sh
echo "%% PWD: "$PWD 
export CORE_PEER_TLS_ENABLED=true
export ORDERER_CA=${PWD}/organizations/ordererOrganizations/moh.gov.om/tlsca/tlsca.moh.gov.om-cert.pem
export PEER0_PHARMACY_CA=${PWD}/organizations/peerOrganizations/pharmacy.moh.gov.om/tlsca/tlsca.pharmacy.moh.gov.om-cert.pem
export PEER0_MANUFACTURER_CA=${PWD}/organizations/peerOrganizations/manufacturer.moh.gov.om/tlsca/tlsca.manufacturer.moh.gov.om-cert.pem
export PEER0_ORG3_CA=${PWD}/organizations/peerOrganizations/org3.moh.gov.om/tlsca/tlsca.org3.moh.gov.om-cert.pem

# Set environment variables for the peer org
setGlobals() {
  local USING_ORG=""
  if [ -z "$OVERRIDE_ORG" ]; then
    USING_ORG=$1
  else
    USING_ORG="${OVERRIDE_ORG}"
  fi
  infoln "Using organization ${USING_ORG}"
  if   [ $USING_ORG = "1" ] || [ $USING_ORG = "pharmacy" ]; then
    export CORE_PEER_LOCALMSPID="PharmacyMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_PHARMACY_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/pharmacy.moh.gov.om/users/Admin@pharmacy.moh.gov.om/msp
    export CORE_PEER_ADDRESS=localhost:7051
  elif [ $USING_ORG = "2" ] || [ $USING_ORG == "manufacturer" ]; then
    export CORE_PEER_LOCALMSPID="ManufacturerMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_MANUFACTURER_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/manufacturer.moh.gov.om/users/Admin@manufacturer.moh.gov.om/msp
    export CORE_PEER_ADDRESS=localhost:9051
  else
    errorln "ORG Unknown"
  fi

  if [ "$VERBOSE" == "true" ]; then
    env | grep CORE
  fi
}

# Set environment variables for use in the CLI container
setGlobalsCLI() {
  setGlobals $1

  local USING_ORG=""
  if [ -z "$OVERRIDE_ORG" ]; then
    USING_ORG=$1
  else
    USING_ORG="${OVERRIDE_ORG}"
  fi
  if [ $USING_ORG = "1" ] || [ $USING_ORG == "pharmacy" ] ; then
    export CORE_PEER_ADDRESS=peer0.pharmacy.moh.gov.om:7051
  elif [ $USING_ORG = "2" ] || [ $USING_ORG == "manufacturer" ]; then
    export CORE_PEER_ADDRESS=peer0.manufacturer.moh.gov.om:9051
  else
    errorln "ORG Unknown"
  fi
}

# parsePeerConnectionParameters $@
# Helper function that sets the peer connection parameters for a chaincode
# operation
parsePeerConnectionParameters() {
  PEER_CONN_PARMS=()
  PEERS=""
  while [ "$#" -gt 0 ]; do
    setGlobals $1
    PEER="peer0.org$1"
    ## Set peer addresses
    if [ -z "$PEERS" ]
    then
	PEERS="$PEER"
    else
	PEERS="$PEERS $PEER"
    fi
    PEER_CONN_PARMS=("${PEER_CONN_PARMS[@]}" --peerAddresses $CORE_PEER_ADDRESS)
    ## Set path to TLS certificate
    CA=PEER0_ORG$1_CA
    TLSINFO=(--tlsRootCertFiles "${!CA}")
    PEER_CONN_PARMS=("${PEER_CONN_PARMS[@]}" "${TLSINFO[@]}")
    # shift by one to get to the next organization
    shift
  done
}

verifyResult() {
  if [ $1 -ne 0 ]; then
    fatalln "$2"
  fi
}

#!/bin/bash
./network.sh up createChannel -c emrchannel

./network.sh deployCC -ccn basic -ccp ../asset-transfer-basic/ -ccl go -c emrchannel

export FABRIC_CFG_PATH=$PWD/../config/
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="PharmacyMSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/pharmacy.moh.gov.om/peers/peer0.pharmacy.moh.gov.om/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/pharmacy.moh.gov.om/users/Admin@pharmacy.moh.gov.om/msp
export CORE_PEER_ADDRESS=localhost:7051

peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.moh.gov.om --tls --cafile "${PWD}/organizations/ordererOrganizations/moh.gov.om/orderers/orderer.moh.gov.om/msp/tlscacerts/tlsca.moh.gov.om-cert.pem" -C emrchannel -n basic --peerAddresses localhost:7051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/pharmacy.moh.gov.om/peers/peer0.pharmacy.moh.gov.om/tls/ca.crt" --peerAddresses localhost:9051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/manufacturer.moh.gov.om/peers/peer0.manufacturer.moh.gov.om/tls/ca.crt" -c '{"function":"InitLedger","Args":[]}'

peer chaincode query -C emrchannel -n basic -c '{"Args":["GetAllAssets"]}' 

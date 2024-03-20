## This is a simpilified version of: https://github.com/hyperledger/fabric-samples
## 1- Install Prerequisites (Windows WSL)
```
# Install: https://docs.docker.com/desktop/install/windows-install/
$ sudo apt install jq git curl docker-compose nodejs docker.io git
$ wget https://go.dev/dl/go1.22.1.linux-amd64.tar.gz
$ sudo tar -C /usr/local -xzf go1.22.1.linux-amd64.tar.gz
$ sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/sbin/docker-compose
$ sudo chmod +x /usr/local/sbin/docker-compose
```

## 2- Download the Fabric samples (v2.5.6), binaries, and Docker images script
```
$ mkdir fabric-dev
$ cd fabric-dev
$ curl -sSL https://raw.githubusercontent.com/hyperledger/fabric/master/scripts/bootstrap.sh | bash -s
```
## 3- Setup the environment variables in ~/.bashrc file.
```
$ vi ~/.bashrc
export GOPATH=$HOME/go
export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin 
export PATH=$PATH:<path_to_fabric_samples>/bin
export FABRIC_CFG_PATH=<path_to_fabric_samples>/config/
$ source ~/.bashrc
```

## 4- Clone this repo + start the network
```
# clone then start network 
./network.sh up createChannel -c emrchannel
# To shutdown all docker containers (data within containers will be lost)
./network.sh down
```

## 5- Deploy chaincode in emrchannel
```
./network.sh deployCC -ccn basic -ccp ../asset-transfer-basic/ -ccl go -c emrchannel
```

## 6- Set environment variables as Pharmacy
```
export FABRIC_CFG_PATH=$PWD/../config/
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="PharmacyMSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/pharmacy.moh.gov.om/peers/peer0.pharmacy.moh.gov.om/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/pharmacy.moh.gov.om/users/Admin@pharmacy.moh.gov.om/msp
export CORE_PEER_ADDRESS=localhost:7051
```

## 7- InitLedger Function
```
peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.moh.gov.om --tls --cafile "${PWD}/organizations/ordererOrganizations/moh.gov.om/orderers/orderer.moh.gov.om/msp/tlscacerts/tlsca.moh.gov.om-cert.pem" -C emrchannel -n basic --peerAddresses localhost:7051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/pharmacy.moh.gov.om/peers/peer0.pharmacy.moh.gov.om/tls/ca.crt" --peerAddresses localhost:9051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/manufacturer.moh.gov.om/peers/peer0.manufacturer.moh.gov.om/tls/ca.crt" -c '{"function":"InitLedger","Args":[]}'
```

## 8- GetAllAssets Function
```
peer chaincode query -C emrchannel -n basic -c '{"Args":["GetAllAssets"]}' 
```

## 9- TransferDrugToPharmacy Function
```
peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.moh.gov.om --tls --cafile "${PWD}/organizations/ordererOrganizations/moh.gov.om/orderers/orderer.moh.gov.om/msp/tlscacerts/tlsca.moh.gov.om-cert.pem" -C emrchannel -n basic --peerAddresses localhost:7051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/pharmacy.moh.gov.om/peers/peer0.pharmacy.moh.gov.om/tls/ca.crt" --peerAddresses localhost:9051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/manufacturer.moh.gov.om/peers/peer0.manufacturer.moh.gov.om/tls/ca.crt" -c '{"function":"TransferDrugToPharmacy","Args":["DRUG001", "Muscat Pharmacy - Seeb"]}'
```

## 10- ReadAsset Function
```
peer chaincode query -C emrchannel -n basic -c '{"Args":["ReadAsset", "DRUG002"]}'  | jq
```

## 11- AssetExists Function
```
peer chaincode query -C emrchannel -n basic -c '{"Args":["AssetExists", "DRUG002"]}'  | jq
```

## 12- CreateAsset Function
```
peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.moh.gov.om --tls --cafile "${PWD}/organizations/ordererOrganizations/moh.gov.om/orderers/orderer.moh.gov.om/msp/tlscacerts/tlsca.moh.gov.om-cert.pem" -C emrchannel -n basic --peerAddresses localhost:7051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/pharmacy.moh.gov.om/peers/peer0.pharmacy.moh.gov.om/tls/ca.crt" --peerAddresses localhost:9051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/manufacturer.moh.gov.om/peers/peer0.manufacturer.moh.gov.om/tls/ca.crt" -c '{"function":"CreateAsset","Args":["DRUG001", "12-12-2023", "Panadol", "XYZ"]}'
```

## 13- TransferDrugToPharmacy Function
```
peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.moh.gov.om --tls --cafile "${PWD}/organizations/ordererOrganizations/moh.gov.om/orderers/orderer.moh.gov.om/msp/tlscacerts/tlsca.moh.gov.om-cert.pem" -C emrchannel -n basic --peerAddresses localhost:7051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/pharmacy.moh.gov.om/peers/peer0.pharmacy.moh.gov.om/tls/ca.crt" --peerAddresses localhost:9051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/manufacturer.moh.gov.om/peers/peer0.manufacturer.moh.gov.om/tls/ca.crt" -c '{"function":"TransferDrugToPharmacy","Args":["DRUG001", "Muscat Pharmacy - Seeb"]}'
```

## 14- RecordSaleToCustomer Function
```
peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.moh.gov.om --tls --cafile "${PWD}/organizations/ordererOrganizations/moh.gov.om/orderers/orderer.moh.gov.om/msp/tlscacerts/tlsca.moh.gov.om-cert.pem" -C emrchannel -n basic --peerAddresses localhost:7051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/pharmacy.moh.gov.om/peers/peer0.pharmacy.moh.gov.om/tls/ca.crt" --peerAddresses localhost:9051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/manufacturer.moh.gov.om/peers/peer0.manufacturer.moh.gov.om/tls/ca.crt" -c '{"function":"RecordSaleToCustomer","Args":["DRUG001", "Ahmed Albusaidi - 20246403"]}'
```

## 15- GetHistoryOfAsset Function
```
peer chaincode query -C emrchannel -n basic -c '{"Args":["GetHistoryOfAsset", "DRUG001"]}'
```
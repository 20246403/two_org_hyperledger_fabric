package chaincode

import (
	"encoding/json"
	"fmt"
	"time"
	"github.com/hyperledger/fabric-contract-api-go/contractapi"
)

// SmartContract provides functions for managing an Asset
type SmartContract struct {
	contractapi.Contract
}

type Asset struct {
	ID             	string `json:"ID"`
	Name           	string `json:"Name"`
	Manufacturer 	string `json:"Manufacturer"`
	ManufactureDate string `json:"ManufactureDate"`
	Pharmacy    	string `json:"Pharmacy"`
    Customer    	string `json:"Customer"`
}

// InitLedger adds a base set of assets to the ledger
func (s *SmartContract) InitLedger(ctx contractapi.TransactionContextInterface) error {
	assets := []Asset{
		{ID: "DRUG001", Name: "Amoxicillin", Manufacturer: "GenericPharm Co", ManufactureDate: "2023-01-15", Pharmacy: "", Customer : ""},
		{ID: "DRUG002", Name: "Ibuprofen", Manufacturer: "FastRelief Pharma", ManufactureDate: "2023-02-20", Pharmacy: "", Customer : ""},
		{ID: "DRUG003", Name: "Metformin", Manufacturer: "HealthPlus Pharmaceuticals", ManufactureDate: "2024-03-10", Pharmacy: "", Customer : ""},
		{ID: "DRUG004", Name: "Lisinopril", Manufacturer: "CareMeds Inc", ManufactureDate: "2024-01-05", Pharmacy: "", Customer : ""},
	}
	for _, asset := range assets {
		assetJSON, err := json.Marshal(asset)
		if err != nil {
			return err
		}

		err = ctx.GetStub().PutState(asset.ID, assetJSON)
		if err != nil {
			return fmt.Errorf("failed to put to world state. %v", err)
		}
	}
	return nil
}

// CreateAsset issues a new asset with given details.
func (s *SmartContract) CreateAsset(ctx contractapi.TransactionContextInterface, id string, manufactureDate string, name string, manufacturer string) error {
	exists, err := s.AssetExists(ctx, id)
	if err != nil {
		return err
	}
	if exists {
		return fmt.Errorf("the asset %s already exists", id)
	}
	asset := Asset{
		ID:             	id,
		ManufactureDate:    manufactureDate,
		Name:          		name,
		Manufacturer: 		manufacturer,
	}
	assetJSON, err := json.Marshal(asset)
	if err != nil {
		return err
	}
	return ctx.GetStub().PutState(id, assetJSON)
}


// ReadAsset returns the asset stored with given id.
func (s *SmartContract) ReadAsset(ctx contractapi.TransactionContextInterface, id string) (*Asset, error) {
	assetJSON, err := ctx.GetStub().GetState(id)
	if err != nil {
		return nil, fmt.Errorf("failed to read from world state: %v", err)
	}
	if assetJSON == nil {
		return nil, fmt.Errorf("the asset %s does not exist", id)
	}
	var asset Asset
	err = json.Unmarshal(assetJSON, &asset)
	if err != nil {
		return nil, err
	}
	return &asset, nil
}

// Get History of asset.
type HistoryRecord struct {
    TxID      string `json:"txId"`
    Value     map[string]interface{} `json:"value"`
    Timestamp string `json:"timestamp"`
}
func (s *SmartContract) GetHistoryOfAsset(ctx contractapi.TransactionContextInterface, id string) (string, error) {
    historyIterator, err := ctx.GetStub().GetHistoryForKey(id)
    if err != nil {
        return "", err
    }
    defer historyIterator.Close()
    var history []HistoryRecord
    for historyIterator.HasNext() {
        modification, err := historyIterator.Next()
        if err != nil {
            return "", err
        }
		var value map[string]interface{}
		// Assuming modification.Value is a byte array containing JSON
		if err := json.Unmarshal(modification.Value, &value); err != nil {
			// Handle JSON unmarshal error, maybe log or return an error
			return "", fmt.Errorf("failed to unmarshal JSON value for id %s: %v", id, err)
		}
        // Convert the timestamp to a readable format
        timestamp := time.Unix(modification.Timestamp.Seconds, int64(modification.Timestamp.Nanos)).Format("2006-01-02 15:04:05 MST")
        // Append the history record to the slice
        history = append(history, HistoryRecord{
            TxID:      modification.TxId,
            Value:     value,
            Timestamp: timestamp,
        })
    }
    // Marshal the history slice to JSON
    historyJSON, err := json.Marshal(history)
    if err != nil {
        return "", err
    }
    return string(historyJSON), nil
}

// TransferDrugToPharmacy updates the pharmacy field for a drug in the ledger
func (s *SmartContract) TransferDrugToPharmacy(ctx contractapi.TransactionContextInterface, id string, pharmacy string) error {
    drugAsBytes, err := ctx.GetStub().GetState(id)
    if err != nil {
        return fmt.Errorf("failed to get drug %s: %v", id, err)
    }
    if drugAsBytes == nil {
        return fmt.Errorf("drug %s does not exist", id)
    }
    // Unmarshal the drug data
    drug := Asset{}
    err = json.Unmarshal(drugAsBytes, &drug)
    if err != nil {
        return err
    }
    // Update the pharmacy
    drug.Pharmacy = pharmacy
    // Marshal the updated drug and put it back in the ledger
    updatedDrugAsBytes, err := json.Marshal(drug)
    if err != nil {
        return err
    }
    return ctx.GetStub().PutState(id, updatedDrugAsBytes)
}

func (s *SmartContract) RecordSaleToCustomer(ctx contractapi.TransactionContextInterface, id string, customer string) error {
    drugAsBytes, err := ctx.GetStub().GetState(id)
    if err != nil {
        return fmt.Errorf("failed to get drug %s: %v", id, err)
    }
    if drugAsBytes == nil {
        return fmt.Errorf("drug %s does not exist", id)
    }
    // Unmarshal the drug data
    drug := Asset{}
    err = json.Unmarshal(drugAsBytes, &drug)
    if err != nil {
        return err
    }
    // Ensure the drug is associated with a pharmacy before recording a sale
    if drug.Pharmacy == "" {
        return fmt.Errorf("drug %s has not been transferred to a pharmacy", id)
    }
    // Update the customer
    drug.Customer = customer
    // Marshal the updated drug and put it back in the ledger
    updatedDrugAsBytes, err := json.Marshal(drug)
    if err != nil {
        return err
    }
    return ctx.GetStub().PutState(id, updatedDrugAsBytes)
}

// DeleteAsset deletes an given asset
func (s *SmartContract) DeleteAsset(ctx contractapi.TransactionContextInterface, id string) error {
	exists, err := s.AssetExists(ctx, id)
	if err != nil {
		return err
	}
	if !exists {
		return fmt.Errorf("the asset %s does not exist", id)
	}
	return ctx.GetStub().DelState(id)
}

// AssetExists returns true when asset with given ID exists in world state
func (s *SmartContract) AssetExists(ctx contractapi.TransactionContextInterface, id string) (bool, error) {
	assetJSON, err := ctx.GetStub().GetState(id)
	if err != nil {
		return false, fmt.Errorf("failed to read from world state: %v", err)
	}
	return assetJSON != nil, nil
}


// GetAllAssets returns all assets 
func (s *SmartContract) GetAllAssets(ctx contractapi.TransactionContextInterface) ([]*Asset, error) {
	// range query with empty string for startKey and endKey does an
	// open-ended query of all assets in the chaincode namespace.
	resultsIterator, err := ctx.GetStub().GetStateByRange("", "")
	if err != nil {
		return nil, err
	}
	defer resultsIterator.Close()
	var assets []*Asset
	for resultsIterator.HasNext() {
		queryResponse, err := resultsIterator.Next()
		if err != nil {
			return nil, err
		}
		var asset Asset
		err = json.Unmarshal(queryResponse.Value, &asset)
		if err != nil {
			return nil, err
		}
		assets = append(assets, &asset)
	}
	return assets, nil
}
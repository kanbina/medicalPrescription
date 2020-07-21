pragma solidity >=0.6.0;
pragma experimental ABIEncoderV2;

/*
    SPDX-License-Identifier: UNLICENSED
    Assumptions:
    - Coded for a 'smart user'
    - Basic implementation which assumes only basic data required
    - Assumes standardized units
    - Not tolerant of anomalies; use notes to best of ability
    - Gas price/TX fee not considered; could be better implemented in different chain (see discussion)
*/

contract Prescription
{
    enum Sex //create enum for possible sexes
    {
        Male,
        Female,
        Other
    }

    uint id;

    address internal owner; //initiates owner address variable

    mapping(address => bool) pharmaList; //mapping for verified pharmacies

    struct Patient //records information about patient (can be modified to include additional)
    {
        uint id; //no name on-chain for privacy
        uint weight;
        uint height;
        Sex sex;
    }

    struct Drug //records information about drug
    {
        uint sku; //easier to identify without confusion about names/abbreviations
        uint totalQuantity;
        uint numRefills;
        uint dosage;
        string notes;
    }

    Patient patient = Patient(0,0,0,Sex.Other); //null initiator of a patient

    Drug[] drugList; //dynamic array of medical prescription data

    constructor() public //initiate owner as the contract deployer
    {
        id = 1;
        owner = msg.sender;
    }

    modifier onlyOwner() //permissioned to owner only
    {
        require(msg.sender == owner, "You must be the owner.");
        _;
    }

    modifier onlyMedical() //permissioned to medical professionals only
    {
        require(pharmaList[msg.sender] == true, "You must be a verified pharmacist.");
        _;
    }

    function personalInfo(uint _weight, uint _height, string memory _sex) public onlyMedical //fill in patient information
    {
        patient.id = id;
        patient.weight = _weight;
        patient.height = _height;
        if (strcmp("female", _sex)) //translate entered string to enum
        {
            patient.sex = Sex.Female;
        }
        else if (strcmp("male", _sex)) //translate entered string to enum
        {
            patient.sex = Sex.Male;
        }
    }

    function makePurchase (uint _sku) public onlyMedical
    {
        for (uint i = 0; i<drugList.length; i++)
        {
            if ((drugList[i].sku == _sku) && (drugList[i].numRefills > 0))
            {
                drugList[i].numRefills--;
            }
            else
            {
                revert();
            }
        }
    }

    function verifyPharma (address check) public
    {
        bool placeholder; //represents some verification method e.g.: digital signature in database or etc.
        if(placeholder)
        {
            pharmaList[check] = true;
        }
        pharmaList[check] = false;
    }

    function addDrug (uint _sku, uint _quantity, uint _refills, uint _dosage) public onlyMedical
    {
        drugList.push(Drug(_sku, _quantity, _refills, _dosage, "none"));
    }

    function addNote (uint _sku, string memory _newNotes) public onlyMedical
    {
        for (uint i = 0; i<drugList.length; i++)
        {
            if (drugList[i].sku == _sku)
            {
                drugList[i].notes = _newNotes;
            }
        }
    }

    function strcmp(string memory a, string memory b) internal pure returns (bool)
    {
        bytes memory aBytes = bytes(a);
        bytes memory bBytes = bytes(b);
        if(aBytes.length != bBytes.length)
        {
            return false;
        }
        else
        {
            return keccak256(aBytes) == keccak256(bBytes);
        }
    }

    function getPrescription() public view returns (Drug[] memory)
    {
        return drugList;
    }
}
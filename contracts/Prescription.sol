pragma solidity >=0.6.0;
pragma experimental ABIEncoderV2;

/*
    SPDX-License-Identifier: UNLICENSED
    Assumptions:
*/

contract Prescription
{
    enum Sex{Male, Female, Other}
    
    address internal owner;

    
    mapping(address => bool) pharmaList; //mapping for verified pharmacies
    
    struct Patient
    {
        string name;
        uint weight;
        uint height;
        Sex sex;
    }
    
    struct Drug
    {
        string name;
        uint256 strength;
        uint256 totalQuantity;
        uint256 numRefills;
        uint256 dosage;
        string notes;
    }
    
    Patient patient = Patient("name",0,0,Sex.Other);
    
    Drug[] drugList;
    
    constructor() public
    {
        owner = msg.sender;
    }
    
    modifier onlyOwner()
    {
        require(msg.sender == owner, "You must be the owner.");
        _;
    }
    
    modifier onlyMedical()
    {
        require(pharmaList[msg.sender] == true, "You must be a verified pharmacist.");
        _;
    }
    
    function personalInfo(string memory _name, uint _weight, uint _height, string memory _sex) public onlyMedical
    {
        patient.name = _name;
        patient.weight = _weight;
        patient.height = _height;
        if (strcmp("female", _sex))
        {
            patient.sex = Sex.Female;
        }
        else if (strcmp("male", _sex))
        {
            patient.sex = Sex.Male;
        }
    }
    
    function makePurchase (string memory name) public onlyMedical
    {
        for (uint i = 0; i<drugList.length; i++)
        {
            if ((strcmp(drugList[i].name, name)) && (drugList[i].numRefills > 0))
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

    function addDrug (string memory tempName, uint256 tempStrength, uint256 tempQuantity, ...
    uint256 tempRefills, uint256 tempDosage) public onlyMedical
    {
        drugList.push(Drug(tempName, tempStrength, tempQuantity, tempRefills, tempDosage, "none"));
    }

    function addNote (string memory name, string memory _newNotes) public onlyMedical
    {
        for (uint i = 0; i<drugList.length; i++)
        {
            if (strcmp(drugList[i].name, name))
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
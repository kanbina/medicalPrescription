pragma solidity >=0.6.0;
pragma experimental ABIEncoderV2;


/*
    SPDX-License-Identifier: UNLICENSED
    Assumptions:
    - id_card represents a unique identifier of a physically used identification known to the doctors as well as pharmacy
    - sku is the sku (or another UNIQUE identifier) of a medicine to be prescribed
    - prescriptions do not expire in time
    - generally: minimum information is hashed to ensure maximum privacy
    -----
    - Coded for a 'smart user'
    - Basic implementation which assumes only basic data required
    - Assumes standardized units
    - Not tolerant of anomalies; use notes to best of ability
    - Gas price/TX fee not considered; could be better implemented in different chain (see discussion)
*/


contract Prescription
{
    address internal owner; //initiates owner address variable

    mapping(address => bool) pharmaList; //mapping for verified pharmacies

    mapping(bytes32 => int) prescriptions;

    constructor() public //initiate owner as the contract deployer and for convenience add him to pharmalist
    {
        owner = msg.sender;
        pharmaList[owner] = true;
    }

    modifier onlyOwner() //permissioned to owner only
    {
        require(msg.sender == owner, "You must be the owner.");
        _;
    }

    modifier onlyMedical() //permissioned to medical professionals (doctors or pharmacists) only
    {
        require(pharmaList[msg.sender] == true, "You must be a verified pharmacist");
        _;
    }

    function verifyPharma (address check) public onlyOwner
    {
        bool placeholder = true; //represents some verification method e.g.: digital signature in database or etc.
        if(placeholder)
        {
            pharmaList[check] = true;
        }
        pharmaList[check] = false;
    }

    // making a prescription: just raising the counter of the key (as it is initialized with a value of zero)
    function prescript(string memory sku, string memory id_card) public onlyMedical {
        bytes32 key = keccak256(abi.encodePacked(sku, id_card));
        prescriptions[key] = prescriptions[key] + 1;
    }

    // selling an article in the pharmacy: validating the counter is > 0
    function sell(string memory sku, string memory id_card) public onlyMedical {
        bytes32 key = keccak256(abi.encodePacked(sku, id_card));
        require(prescriptions[key] > 0, "Prescription not found");
        prescriptions[key] = prescriptions[key] - 1;
    }

    // check if "I am verified" from sender perspective
    function am_verified() public view returns(bool) {
        return pharmaList[msg.sender] == true;
    }
}
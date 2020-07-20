pragma solidity >=0.6.0;
pragma experimental ABIEncoderV2;

/*
    SPDX-License-Identifier: UNLICENSED
    Assumptions:
*/

contract Prescription {
    drug[] public drugList;

    struct drug {
        string name;
        uint256 strength;
        uint256 totalQuantity;
        uint256 numRefills;
        uint256 dosage;
        string notes;
    }

    function addDrug (string memory tempName, uint256 tempStrength, uint256 tempQuantity, uint256 tempRefills, uint256 tempDosage) public {
        drugList.push(drug(tempName, tempStrength, tempQuantity, tempRefills, tempDosage, "none"));
    }

    function addNote (string memory name, string memory _newNotes) public {
        for (uint i = 0; i<drugList.length; i++) {
            if (strcmp(drugList[i].name, name)) {
                drugList[i].notes = _newNotes;
            }
        }
    }

    function strcmp(string memory a, string memory b) internal pure returns (bool) {
        bytes memory aBytes = bytes(a);
        bytes memory bBytes = bytes(b);
        if(aBytes.length != bBytes.length) {
            return false;
        }
        else {
            return keccak256(aBytes) == keccak256(bBytes);
        }
    }
}
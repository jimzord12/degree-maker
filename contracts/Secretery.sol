//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.10;

// import "./OpenZeppelin/utils/SafeMath.sol";
import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";

/**
 * @title Secretery
 * @dev Register & Approve new Professors, Managers
 */

contract Secretery is Ownable {
    address internal SecreteryContractAddress;

    /// @custom:future-improvements Should use enum for access levels

    uint64 public totalProfessors; // Total Number of Professors, Approved or Not
    uint64 public totalApprovedProfessors; // Total Number of Approved Professors
    mapping(address => bool) public approvedProfessors; // (Professor's Address => isApproved ? true : false)
    mapping(uint => Professor) public professors; // (Professor's ID => Professor struct)

    uint64 public totalManagers; // Total Number of Managers
    mapping(address => bool) public approvedManagers; // (Manager's Address => isManager ? true : false)

    struct Professor {
        uint64 id;
        address addr;
        string name;
    }

    // ====  Modifiers  ==== //

    /**
     * @dev Requires the one calling a function containing this modifier to be a Manager
     *  🚨 Uncomment this after testing! 🚨
     */
    modifier onlyManager() {
        bool ptr = approvedManagers[msg.sender];
        require(ptr, "Secretery.sol: Only a Manager can perform this action!");
        _;
    }

    /**
     * @dev Upon deployment, saves the contract's address to a global var
     */
    constructor() {
        hardCodeForTesting();
        SecreteryContractAddress = address(this);
    }

    // ====  Functions  ==== //

    /**
     * @dev Gives Manager level access
     * @notice Only the owner can call this function
     * @param _managerAddress of account that will be appointed to a Manager
     */
    function appointManager(address _managerAddress) public onlyOwner {
        require(
            approvedManagers[_managerAddress] == false,
            "Secretery.sol: This address already has manager level access!"
        );
        totalManagers++;
        approvedManagers[_managerAddress] = true;
    }

    /**
     * @dev Creates a professor obj
     * @notice Only a Manager can call this function
     * @notice 🚨 A newly created professor obj does NOT have Professor level access! 🚨
     * @param _profID = The new professor's ID, _profAddress = address, _name = professor'/name
     */
    function registerProfessor(
        uint64 _profID,
        address _profAddress,
        string memory _name
    ) public onlyManager {
        Professor storage prof = professors[totalProfessors];
        prof.id = _profID;
        prof.addr = _profAddress;
        prof.name = _name;
        totalProfessors++;
    }

    /**
    / * @dev Gives Professor level access
    / * @notice Only a manager can call this function
    / * @param _profID = Professor's ID
      */
    function approveProfessor(uint64 _profID) public onlyManager {
        for (uint i = 0; i <= totalProfessors; i++) {
            Professor storage prof = professors[i];
            if (prof.id == _profID) {
                approvedProfessors[prof.addr] = true;
                totalApprovedProfessors++;
            }
        }
    }

    /**
     * @dev Checks if an address has professor level access
     * @dev Mainly used from other contracts for access validation
     * @param _caller the account's address in question
     */
    function isApprovedProf(address _caller) public view returns (bool) {
        console.log("The param: ", _caller);
        console.log(
            "Is an approved Professor?  Answer: ",
            approvedProfessors[_caller]
        );
        return approvedProfessors[_caller];
    }

    function hardCodeForTesting() public {
        appointManager(0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2); // No.2 Account Remix-IDE
        appointManager(0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db); // No.3 Account Remix-IDE
        appointManager(0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB); // No.4 Account Remix-IDE
        appointManager(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266); // No.1 Account Hard Hat

        registerProfessor(
            422,
            0x5B38Da6a701c568545dCfcB03FcB875f56beddC4,
            "Koulis"
        ); // No.1 Account
        registerProfessor(
            13,
            0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2,
            "Giannis"
        ); // No.2 Account
        registerProfessor(
            5571,
            0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db,
            "Xristos"
        ); // No.3 Account
        registerProfessor(
            31337,
            0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266,
            "Hard_Hat_#1"
        ); //No.1 Account Hard Hat

        approveProfessor(422);
        approveProfessor(13);
        approveProfessor(31337); //No.1 Account Hard Hat
    }
}

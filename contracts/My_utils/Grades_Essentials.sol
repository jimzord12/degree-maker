// SPDX-License-Identifier: PADA xD

pragma solidity ^0.8.10;

import "../GradesManager.sol";
/**
 * @title Grades Essentials
 * @dev Provides utility for the DegreeManager Contract
 */
abstract contract GradesEssentials {

    address public gradesManagerAddress;
    GradesManager GMcontract;

    function setGMaddress(address _addr) public {
        gradesManagerAddress = _addr;
        GMcontract = GradesManager(gradesManagerAddress);
    }

    // We get the student's PS from his AM
    function _getStudentPS(uint _am) public view returns (uint64 studentPS) {
        studentPS = GMcontract.getStudentPS(_am);
    }

    // Returns the Number of Courses the student has passed in a particular Semester
    function _hasPassedAllCourses(uint _am, uint64 _PS, uint8 _semID, uint8[] memory _CoursesTypeNum, uint8 _maxCourseTypes) public view returns (bool result) {
        result = GMcontract.hasPassedAllCourses(_am, _PS, _semID, _CoursesTypeNum, _maxCourseTypes);
    }
    // -- Modifiers
    
    // modifier onlyProf(address _caller) {
    //     require(SecreteryContractAddress != address(0), "mod_onlyProf: Secretery Contract Address has not been set yet!");
    //     require(isApprovedProf(_caller), "mod_onlyProf: Caller is not a professor!");
    //     _;
    // }

    // modifier onlyStudent(uint _studentAM) {
    //     require(students[_studentAM].addr != address(0), "GradesManager.sol: You are not a student!");
    //     _;
    // }
}
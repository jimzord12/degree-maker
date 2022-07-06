// SPDX-License-Identifier: PADA xD

pragma solidity ^0.8.10;

import "../CoursesManager.sol";

/**
 * @title Owner
 * @dev Set & change owner
 */
abstract contract CourseEssentials {

    address public coursesManagerAddress;
    // CoursesManager CMcontract = CoursesManager(coursesManagerAddress);

    function setCMaddress(address _addr) public {
        coursesManagerAddress = _addr;
    }

    // We get the student's total Semesters from his PS
    function _getSems(uint64 _PS) public view returns (uint8 studentMaxSemesters) {
        CoursesManager CMcontract = CoursesManager(coursesManagerAddress);
        studentMaxSemesters = CMcontract.getSems(_PS);
    }

    // We get the NUmber of student's Courses from a particular Semester from his PS and Semester
    function _getCourses(uint64 _PS, uint8 _semID) public view returns (uint8 studentCoursesPerSem) {
        CoursesManager CMcontract = CoursesManager(coursesManagerAddress);
        studentCoursesPerSem = CMcontract.getCourses(_PS, _semID);
    }

    // Returns a Array that it's index => CourseType && index's value => Number of Courses that have to be Passed
    // *** REQUIRES - FIXING ***
    function _getRequirementsFormSem(uint64 _PS, uint8 _semID) public view returns (uint8[] memory _typeOfCoursesNum) {
        CoursesManager CMcontract = CoursesManager(coursesManagerAddress);
        uint8 courseTypes = _getMaxCourseTypes(_PS);
        _typeOfCoursesNum = new uint8[](courseTypes);
        _typeOfCoursesNum = CMcontract.getRequirementsFormSem(_PS, _semID);
        // Using typeOfCoursesNum.length we know the total amount of Course Types this Semester has
        // And the values represent how many Courses of each Type the student must Pass!
    }

    // Returns the Max Number of Types the PS has (Ex. Y=0, EY=1, E=0, ...)
    function _getMaxCourseTypes(uint64 _PS) public view returns (uint8 MaxCourseTypes) {
        CoursesManager CMcontract = CoursesManager(coursesManagerAddress);
        MaxCourseTypes = CMcontract.getMaxCourseTypes(_PS);
    }
}
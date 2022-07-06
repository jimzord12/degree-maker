//SPDX-License-Identifier: PADA xD

pragma solidity ^0.8.10;

import "../node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";
import "../node_modules/@openzeppelin/contracts/utils/Counters.sol";
import "./My_utils/Course_Essentials.sol";
import "./My_utils/Grades_Essentials.sol";

contract DegreeManager is GradesEssentials, CourseEssentials, ERC721 {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;
    mapping(uint => bool) graduableStudents; // (AM => CanGraduate?)

    constructor(address _CMaddr, address _GMaddr) ERC721("DegreeToken", "DTN") {
        setCMaddress(_CMaddr);
        setGMaddress(_GMaddr);
    }

    // 🔧 Phase: Complete 🔧
    function checkIfStudentCanGraduate(
        uint _am /*onlyStudent(_am)*/
    ) public returns (bool result) {
        uint64 studentPS = _getStudentPS(_am); // From: GradesEssentials Contract
        uint8 maxSemesters = _getSems(studentPS); // From: CoursesEssentials Contract
        uint8 maxCourseTypes = _getMaxCourseTypes(studentPS); // From: CoursesEssentials Contract
        require(
            maxSemesters != 0,
            "DegreeManager.sol: MaxSemester == 0, however it shouldn't!"
        );
        uint8 successCounter = 0;
        for (uint8 i = 0; i < maxSemesters; i++) {
            uint8[] memory coursesReq = _getRequirementsFormSem(studentPS, i); // Array of Requirements, Index = Type, Value = Amount
            // uint8 coursesPerSem = _getCourses(studentPS, i);                    // From: CoursesEssentials Contract
            if (
                hasPassedAllCourses(
                    _am,
                    studentPS,
                    i,
                    coursesReq,
                    maxCourseTypes
                )
            )
                // Checks if all requierd Courses has been passed, in a Specific Sem
                successCounter++;
        }
        if (successCounter == maxSemesters) {
            // If all requierd Courses has been passed in every Semester
            graduableStudents[_am] = true;
        }
        result = graduableStudents[_am]; // returns the result from accesing a global mapping
    }

    function hasPassedAllCourses(
        uint _am,
        uint64 _PS,
        uint8 _semID,
        uint8[] memory CourseTypesAndReqs,
        uint8 _maxCourseTypes
    ) private view returns (bool success) {
        // Example of CourseTypesAndReqs: [1, 4, 1] => Translates to => 3 Types of Courses:
        // Type-0 (Y):  requires 1 Course,
        // Type-1 (EY): requires 4 Courses,
        // Type-2 (E):  requires 1 Course
        success = _hasPassedAllCourses(
            _am,
            _PS,
            _semID,
            CourseTypesAndReqs,
            _maxCourseTypes
        ); // Inherited from Grades_Essentials.sol
        require(
            success,
            "DegreeManager.sol: hasPassedAllCourses() function failed!"
        );
    }

    function isEligibleToGraduate(
        uint _am /*onlyStudent(_am)*/
    ) public view returns (bool) {
        return graduableStudents[_am];
    }

    // 🔧 This is were the minting occurs... 🔧
    function mint(uint _am) public returns (address) {
        require(
            graduableStudents[_am],
            "DegreeManager.sol: You can NOT mint your Degree NFT!"
        );
        require(
            balanceOf(msg.sender) < 1,
            "DegreeManager.sol: Don't be greedy! One Degree is good enough"
        );
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(msg.sender, tokenId);
        return msg.sender;
    }
}

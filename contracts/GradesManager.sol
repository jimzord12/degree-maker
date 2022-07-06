//SPDX-License-Identifier: PADA xD

pragma solidity ^0.8.10;

// import '@openzeppelin/contracts/utils/math/SafeMath.sol';
import "./Secretery.sol";
import "hardhat/console.sol";

/**
 * @title Grades Manager
 * @dev Upload Grades & Register new Student
 * @dev Inherits from the Secretety Contract
 */
contract GradesManager is Secretery {
    mapping(uint => Student) public students; // (AM => Student struct)
    uint public studentNum; // Total Number of Students

    struct PassedCourse {
        uint32 courseID; // uint32 = 8-bytes: 0-4,294,967,295
        uint8 semester; // uint8 = 2-bytes: 0-255
        uint8 grade;
        uint8 _type;
    }

    struct Student {
        address addr;
        uint am;
        uint64 ps;
        bool canGraduate;
        mapping(uint8 => mapping(uint8 => PassedCourse[])) semesters; // (Semester ID => Course Type => Array of Passed Courses of that Type
    }

    // ====  Modifiers  ==== //

    /**
     * @dev Requires (the one calling a function containing this modifier) to be a Approved Professor
     * @notice 🚨 Uncomment this after testing! 🚨
     */
    modifier onlyProf() {
        require(
            SecreteryContractAddress != address(0),
            "mod_onlyProf: Secretery Contract Address has not been set yet!"
        );
        require(
            Secretery.isApprovedProf(msg.sender),
            "mod_onlyProf: Caller is not a professor!"
        );
        console.log("[GM] Deployer - Msg.Sender", msg.sender);
        _;
    }

    /**
     * @dev Requires (the one calling a function containing this modifier) to be a registed Student
     * @notice 🚨 Uncomment this after testing! 🚨
     */
    modifier onlyStudent(uint _studentAM) {
        require(
            students[_studentAM].addr != address(0),
            "GradesManager.sol: You are not a student!"
        );

        _;
    }

    // ====  Functions  ==== //

    /**
     * @dev Upon deployment, saves the contract's to a global var by calling setSecreteryContractAddress()
     */
    constructor() {
        setSecreteryContractAddress(SecreteryContractAddress);
        hardCodeRegisterStudents(1);
        // hardCodeUploadGrades_A(1);
        hardCodeUploadGrades_B(1);
    }

    /**
     * @dev Sets Secretery Contract Address
     */
    function setSecreteryContractAddress(address _address) public onlyOwner {
        SecreteryContractAddress = _address;
    }

    /**
     * @dev Creates a Student struct
     * @notice Only a approved Proffesor can call this function
     * @notice Registers a new Student
     * @param _am new Student's AM
     * @param _addr new Student's Account Address
     * @param _ps new Student's Curriculum ID
     */
    function registerNewStudent(
        uint _am,
        address _addr,
        uint64 _ps
    ) public onlyProf {
        Student storage newStudent = students[_am];
        newStudent.am = _am;
        newStudent.addr = _addr;
        newStudent.ps = _ps;
        studentNum++;
    }

    /**
     * @dev 1) Creating Storage Pointer to access the particular Student in the students Mapping
     * @dev 2) We grab the Grade for that Student (cuz of the identical array indexs its fairly easy).
     * @dev 3) We access the semesters Mapping that lives inside the specific Student,
     *      we use the arg: _courseSemester to find the correct index,
     *      we push a new PassedCourse struct inside the subArray of the semesters Mapping.
     * @notice Indexing is CRUCIAL for this function to work as intended!
     * @notice Only a approved professor can call this function!
     * @param _courseID is the Course's ID
     * @param _courseSemester is the Semester's ID
     * @param _courseType is the Course's type
     * @param _studentsAM is an array containing the Students' IDs
     * @param _studentGrades is an array containing the Students' grades
     * @custom:future-improvement Inside for-loop check if another PassedCourse struct exists with the same _courseID
     */
    function uploadGrades(
        uint32 _courseID,
        uint8 _courseSemester,
        uint8 _courseType,
        uint256[] memory _studentsAM,
        uint8[] memory _studentGrades
    ) public onlyProf {
        require(
            _studentsAM.length > 0,
            "fromFun_uploadGrades: No Addresses have been inputed!"
        );
        require(
            _studentsAM.length == _studentGrades.length,
            "fromFun_uploadGrades: Studebt ID's and the amount of grades are not equal!"
        );

        for (uint32 i = 0; i < _studentsAM.length; i++) {
            Student storage currentStudent = students[_studentsAM[i]]; // 1
            uint8 currentGrade = _studentGrades[i]; // 2
            currentStudent.semesters[_courseSemester][_courseType].push(
                PassedCourse(
                    _courseID,
                    _courseSemester,
                    currentGrade,
                    _courseType
                )
            );
        }
    }

    /**
     * @dev Getter function, fetches Student's Curriculum ID
     * @param _am Student's AM
     */
    function getStudentPS(uint _am) public view returns (uint64) {
        Student storage student = students[_am];
        return student.ps;
    }

    /**
     * @dev This function main purpose is to provide functionality for another contract (DegreeManager.sol)
     * @notice Checks if a specific Student has passed all the Courses or met all requirements to complete a specific Semester
     * @param _am Student's AM
     * @param _PS Student's Curriculum ID
     * @param _semID Student's Semester ID
     * @param _CoursesTypeNum An array containing Semester's requirements
     * @param _maxCourseTypes The length of the prementioned array, basically
     * @return result If the Student has met all requirements, then result = true otherwise result = false
     */
    function hasPassedAllCourses(
        uint _am,
        uint64 _PS,
        uint8 _semID,
        uint8[] memory _CoursesTypeNum,
        uint8 _maxCourseTypes
    ) public view onlyStudent(_am) returns (bool result) {
        Student storage student = students[_am];
        require(
            student.ps == _PS,
            "GradesManager.sol: Student is NOT registered to this PS"
        );
        uint8 successCounter = 0;
        for (uint8 i = 0; i < _maxCourseTypes; i++) {
            if (_CoursesTypeNum[i] == 0) {
                successCounter++;
            } else if (
                student.semesters[_semID][i].length == _CoursesTypeNum[i]
            ) {
                successCounter++;
            }
        }

        require(
            _CoursesTypeNum.length == successCounter,
            "GradesManager.sol: You have NOT met the requirements to complete this Semester"
        );
        result = true;
    }

    function hardCodeRegisterStudents(uint _userPassword) public {
        uint password = 1;
        require(
            _userPassword == password,
            "GradesManager.sol - Worng Password, Please Try Again"
        );

        // PS #0
        // registerNewStudent(45789, 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4, 0);
        // registerNewStudent(43215, 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2, 0);
        // registerNewStudent(2107884698, 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db, 0);
        // registerNewStudent(20753158, 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db, 0);

        // PS #1
        // 🔥Bug: When a student registers also to another PS the previous PS is Overridden
        registerNewStudent(
            43215,
            0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2,
            1
        ); // Also registerd to PS #0
        registerNewStudent(
            45789,
            0x5B38Da6a701c568545dCfcB03FcB875f56beddC4,
            1
        ); // Also registerd to PS #0
        registerNewStudent(
            68874,
            0x5B38Da6a701c568545dCfcB03FcB875f56beddC4,
            1
        );
        registerNewStudent(
            68911,
            0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2,
            1
        );
    }

    function hardCodeUploadGrades_B(uint _userPassword) public {
        uint password = 1;
        require(
            _userPassword == password,
            "GradesManager.sol - Worng Password, Please Try Again"
        );

        // PS #1 - Coursee #1: "Rust"
        uint[] memory students_AMs_Rust = new uint[](4);
        students_AMs_Rust[0] = 68874;
        students_AMs_Rust[1] = 68911;
        students_AMs_Rust[2] = 43215;
        students_AMs_Rust[3] = 45789;

        // PS #1 - Grades for Coursee #1: "Rust"
        uint8[] memory students_Grades_Rust = new uint8[](4);
        students_Grades_Rust[0] = 5;
        students_Grades_Rust[1] = 5;
        students_Grades_Rust[2] = 5;
        students_Grades_Rust[3] = 5;

        // ABI: uploadGrades(uint32 _courseID, uint8 _courseSemester, uint8 _courseType, uint256[] memory _studentsAM, uint8[] memory _studentGrades)
        uploadGrades(1001, 0, 0, students_AMs_Rust, students_Grades_Rust);

        // ***************** // ***************** // ***************** // ***************** //

        // PS #1 - Coursee #2: "Sea of Thieves"
        uint[] memory students_AMs_Sea_of_Thieves = new uint[](2);
        students_AMs_Sea_of_Thieves[0] = 68874;
        students_AMs_Sea_of_Thieves[1] = 43215;

        // PS #1 - Grades for Coursee #2: "Sea of Thieves"
        uint8[] memory students_Grades_Sea_of_Thieves = new uint8[](2);
        students_Grades_Sea_of_Thieves[0] = 5;
        students_Grades_Sea_of_Thieves[1] = 5;

        // ABI: uploadGrades(uint32 _courseID, uint8 _courseSemester, uint8 _courseType, uint256[] memory _studentsAM, uint8[] memory _studentGrades)
        uploadGrades(
            2001,
            1,
            1,
            students_AMs_Sea_of_Thieves,
            students_Grades_Sea_of_Thieves
        );

        // ***************** // ***************** // ***************** // ***************** //

        // PS #1 - Coursee #3: "World Of Warcraft"
        uint[] memory students_AMs_WoW = new uint[](3);
        students_AMs_WoW[0] = 68874;
        students_AMs_WoW[1] = 68911;
        students_AMs_WoW[2] = 43215;

        // PS #1 - Grades for Coursee #3: "World Of Warcraft"
        uint8[] memory students_Grades_WoW = new uint8[](3);
        students_Grades_WoW[0] = 5;
        students_Grades_WoW[1] = 5;
        students_Grades_WoW[2] = 5;

        // ABI: uploadGrades(uint32 _courseID, uint8 _courseSemester, uint8 _courseType, uint256[] memory _studentsAM, uint8[] memory _studentGrades)
        uploadGrades(3001, 2, 0, students_AMs_WoW, students_Grades_WoW);

        // ***************** // ***************** // ***************** // ***************** //

        // PS #1 - Coursee #4: "Apex Legends"
        uint[] memory students_AMs_AL = new uint[](4);
        students_AMs_AL[0] = 68874;
        students_AMs_AL[1] = 68911;
        students_AMs_AL[2] = 43215;
        students_AMs_AL[3] = 45789;

        // PS #1 - Grades for Coursee #4: "Apex Legends"
        uint8[] memory students_Grades_AL = new uint8[](4);
        students_Grades_AL[3] = 5;
        students_Grades_AL[0] = 5;
        students_Grades_AL[1] = 5;
        students_Grades_AL[2] = 5;

        // ABI: uploadGrades(uint32 _courseID, uint8 _courseSemester, uint8 _courseType, uint256[] memory _studentsAM, uint8[] memory _studentGrades)
        uploadGrades(3002, 2, 0, students_AMs_AL, students_Grades_AL);

        // ***************** // ***************** // ***************** // ***************** //

        // PS #1 - Coursee #5: "League Of Legends"
        uint[] memory students_AMs_LoL = new uint[](2);
        students_AMs_LoL[0] = 68874;
        students_AMs_LoL[1] = 43215;

        // PS #1 - Grades for Coursee #5: "League Of Legends"
        uint8[] memory students_Grades_LoL = new uint8[](2);
        students_Grades_LoL[0] = 5;
        students_Grades_LoL[1] = 5;

        // ABI: uploadGrades(uint32 _courseID, uint8 _courseSemester, uint8 _courseType, uint256[] memory _studentsAM, uint8[] memory _studentGrades)
        uploadGrades(4001, 3, 0, students_AMs_LoL, students_Grades_LoL);

        // ***************** // ***************** // ***************** // ***************** //

        // PS #1 - Coursee #6: "Horizon Zero Dawn"
        uint[] memory students_AMs_HZD = new uint[](4);
        students_AMs_HZD[0] = 68874;
        students_AMs_HZD[1] = 68911;
        students_AMs_HZD[2] = 43215;
        students_AMs_HZD[3] = 45789;

        // PS #1 - Grades for Coursee #6: "Horizon Zero Dawn"
        uint8[] memory students_Grades_HZD = new uint8[](4);
        students_Grades_HZD[0] = 5;
        students_Grades_HZD[1] = 5;
        students_Grades_HZD[2] = 5;
        students_Grades_HZD[3] = 5;

        // ABI: uploadGrades(uint32 _courseID, uint8 _courseSemester, uint8 _courseType, uint256[] memory _studentsAM, uint8[] memory _studentGrades)
        uploadGrades(4002, 3, 1, students_AMs_HZD, students_Grades_HZD);

        // ***************** // ***************** // ***************** // ***************** //

        // PS #1 - Coursee #7: "Resident Evil 4"
        uint[] memory students_AMs_RE4 = new uint[](4);
        students_AMs_RE4[0] = 68874;
        students_AMs_RE4[1] = 68911;
        students_AMs_RE4[2] = 43215;
        students_AMs_RE4[3] = 45789;

        // PS #1 - Grades for Coursee #7: "Resident Evil 4"
        uint8[] memory students_Grades_RE4 = new uint8[](4);
        students_Grades_RE4[0] = 5;
        students_Grades_RE4[1] = 5;
        students_Grades_RE4[2] = 5;
        students_Grades_RE4[3] = 5;

        // ABI: uploadGrades(uint32 _courseID, uint8 _courseSemester, uint8 _courseType, uint256[] memory _studentsAM, uint8[] memory _studentGrades)
        uploadGrades(4003, 3, 0, students_AMs_RE4, students_Grades_RE4);

        // ***************** // ***************** // ***************** // ***************** //

        // PS #1 - Coursee #8: "Pac-Man Master-Elite"
        uint[] memory students_AMs_PM = new uint[](2);
        students_AMs_PM[0] = 68874;
        students_AMs_PM[1] = 43215;

        // PS #1 - Grades for Coursee #8: "Pac-Man Master-Elite"
        uint8[] memory students_Grades_PM = new uint8[](2);
        students_Grades_PM[0] = 5;
        students_Grades_PM[1] = 5;

        // ABI: uploadGrades(uint32 _courseID, uint8 _courseSemester, uint8 _courseType, uint256[] memory _studentsAM, uint8[] memory _studentGrades)
        uploadGrades(4004, 3, 1, students_AMs_PM, students_Grades_PM);
    }
}

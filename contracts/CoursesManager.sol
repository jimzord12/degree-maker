// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.10;

import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";
import "./Secretery.sol";
import "hardhat/console.sol";

/**
 * @title Courses Manager
 * @dev Creates & Manages curriculums
 */
contract CoursesManager is Ownable {
    address public SecreteryContractAddress_T;
    uint8 public currentNumOfCourses;
    uint64 public totalPS;
    mapping(uint64 => ProgrammaSpoudwn) public programmataSpoudwn;

    struct ProgrammaSpoudwn {
        uint64 id;
        uint8 maxCoursesNum; // All the Courses this program has to offer (🤣 Should make a getter() for this)
        uint8 maxSemesters; // Max number of Semesters this program has
        uint8 maxCourseTypes; // Max number of Course Types (Ex. Y=0, EY=1, E=2, etc...)
        mapping(uint8 => Semester) semesters; // (Semester_ID => Corresponding Semester)
    }

    struct Semester {
        uint8 id;
        uint8 CoursesPerSem; // Ex. 1st Semester has 6 Courses, 8th has 4 Courses, etc...
        mapping(uint8 => Course) courses; // (Course ID (1001) => Course struct)
        mapping(uint8 => uint8) requirements; // (Courses Type ( Y=0, EY=1 ) => How many of these must be passed (3x Y, 3x EY))
    }

    struct Course {
        uint32 id;
        uint8 semester;
        int8 type_; // For example, Y=0 || EY=1 || E=2
        string title;
    }

    // -- Modifiers

    modifier onlyProf_T(address _caller) {
        Secretery secreteryContract_T = Secretery(SecreteryContractAddress_T);
        bool isProf = secreteryContract_T.isApprovedProf(_caller);
        require(isProf, "mod_onlyProf: Caller is not a professor!");
        console.log("[CM] Deployer - Msg.Sender", msg.sender);
        _;
        // *IMPORTANT*
        // To access the mapping from another Contract
        // we use "( )" instead of "[ ]" because we actually call
        // the getter() function that Solidity automatically creates
        // whenever we declare a storage data type "public".
    }

    // -- Functions
    /**
     * @dev Set contract deployer as owner
     */
    constructor(address _secrAddr) {
        SecreteryContractAddress_T = _secrAddr;
        hardCodeForTesting(true);
    }

    // /**
    //  * @dev Create Course
    //  * @param Course's ID, Semester that Course belongs, the type of Course(Ex. Y=0 or EY=1 or E=2)
    //  * 0xEf9f1ACE83dfbB8f559Da621f4aEA72C6EB10eBf
    //  */

    // -- PS - Functionality --

    // @FutureUpdate: Make a getter() for PS 💡

    function createPS(
        uint64 _PS,
        uint8 _maxSemesters,
        uint8 _maxCoursesNum,
        uint8 _maxCourseTypes
    ) public onlyProf_T(msg.sender) {
        ProgrammaSpoudwn storage ps = programmataSpoudwn[_PS];
        ps.id = _PS;
        ps.maxSemesters = _maxSemesters;
        ps.maxCoursesNum = _maxCoursesNum;
        ps.maxCourseTypes = _maxCourseTypes;
        totalPS++;
    }

    function modifyPS(
        uint64 old_PS,
        uint64 new_PS,
        uint8 _maxSemesters,
        uint8 _maxCoursesNum,
        uint8 _maxCourseTypes
    ) public onlyProf_T(msg.sender) {
        // @FutureUpdate: Check if new props already exist 💡
        ProgrammaSpoudwn storage ps = programmataSpoudwn[old_PS];
        ps.id = new_PS;
        ps.maxSemesters = _maxSemesters;
        ps.maxCoursesNum = _maxCoursesNum;
        ps.maxCourseTypes = _maxCourseTypes;
    }

    function deltePS(uint64 _PS) public onlyProf_T(msg.sender) {
        // @FutureUpdate: Check if PS exists 💡
        delete programmataSpoudwn[_PS];
        totalPS--;
    }

    // -- Semesters - Functionality --

    // @FutureUpdate: Make a getter() for Semesters 💡

    function createSem(
        uint64 _PS,
        uint8 _semID,
        uint8 _CoursesPerSem /*, uint8[] memory _numOfEachCourseType*/
    ) public onlyProf_T(msg.sender) {
        ProgrammaSpoudwn storage ps = programmataSpoudwn[_PS];
        Semester storage sem = ps.semesters[_semID];
        sem.id = _semID;
        sem.CoursesPerSem = _CoursesPerSem;
        /*setSemRequirements(_PS, _semID, _numOfEachCourseType);*/
    }

    function setSemRequirements(
        uint64 _PS,
        uint8 _semID,
        uint8[] memory _numOfEachCourseType
    ) public onlyProf_T(msg.sender) {
        ProgrammaSpoudwn storage ps = programmataSpoudwn[_PS]; // Ex. PS: #0
        Semester storage sem = ps.semesters[_semID]; // Ex. Semester: #1
        require(
            _numOfEachCourseType.length <= ps.maxCourseTypes,
            "CourseManager.sol: You set more Course Types that you should!"
        );
        for (uint8 i = 0; i < ps.maxCourseTypes; i++) {
            sem.requirements[i] = _numOfEachCourseType[i]; // numOfEachCourseType: [6, 0 ,0]
            // *We have 6 Courses with Type:  Y=0
            // *We have 0 Courses with Type: EY=1
            // *We have 0 Course with Type:  E=2
            // numOfEachCourseType: [1, 4, 1]
            // *We have 1 Course with Type:  Y=0
            // *We have 4 Courses with Type: EY=1
            // *We have 1 Course with Type:  E=2
        }
    }

    function modifySem(
        uint64 _PS,
        uint8 _oldSemID,
        uint8 _newSemID,
        uint8 _CoursesPerSem
    ) public onlyProf_T(msg.sender) {
        /// @FutureUpdate: Check if new props already exist 💡
        ProgrammaSpoudwn storage ps = programmataSpoudwn[_PS];
        Semester storage sem = ps.semesters[_oldSemID];
        sem.id = _newSemID;
        sem.CoursesPerSem = _CoursesPerSem;
    }

    function delteSem(uint64 _PS, uint8 _semID) public onlyProf_T(msg.sender) {
        /// @FutureUpdate: Check if Semester exists 💡
        ProgrammaSpoudwn storage ps = programmataSpoudwn[_PS];
        delete ps.semesters[_semID];
    }

    // -- Courses - Functionality --

    function createCourse(
        uint64 _PS,
        uint8 _semester,
        uint32 _courseID,
        int8 _type_,
        string memory _title
    ) public onlyProf_T(msg.sender) {
        ProgrammaSpoudwn storage ps = programmataSpoudwn[_PS];
        Semester storage sem = ps.semesters[_semester];
        Course storage cs = sem.courses[
            /*sem.*/
            currentNumOfCourses
        ];
        cs.id = _courseID;
        cs.semester = _semester;
        cs.type_ = _type_;
        cs.title = _title;
        /*sem.*/
        currentNumOfCourses++;
    }

    function modifyCourse(
        uint64 _PS,
        uint8 _oldSemID,
        uint8 _semMappingCourseID,
        uint32 _newCourseID,
        uint8 _newSemID,
        int8 _type_,
        string memory _title
    ) public onlyProf_T(msg.sender) {
        ProgrammaSpoudwn storage ps = programmataSpoudwn[_PS];
        Semester storage sem = ps.semesters[_oldSemID];
        Course storage cs = sem.courses[_semMappingCourseID];
        cs.id = _newCourseID;
        cs.semester = _newSemID;
        cs.type_ = _type_;
        cs.title = _title;
    }

    function delteCourse(
        uint64 _PS,
        uint8 _semID,
        uint8 _semMappingCourseID
    ) public onlyProf_T(msg.sender) {
        ProgrammaSpoudwn storage ps = programmataSpoudwn[_PS];
        Semester storage sem = ps.semesters[_semID];
        delete sem.courses[_semMappingCourseID];
        /*sem.*/
        currentNumOfCourses--;
    }

    // 🔥🔥🔥 Something is Wrong here! - Fixed
    // We get students's Total Semesters from his PS
    function getSems(uint64 _PS) public view returns (uint8 a) {
        ProgrammaSpoudwn storage ps = programmataSpoudwn[_PS];
        a = ps.maxSemesters;
    }

    function getCourses(uint64 _PS, uint8 _semID) public view returns (uint8) {
        ProgrammaSpoudwn storage ps = programmataSpoudwn[_PS];
        Semester storage sem = ps.semesters[_semID];
        return sem.CoursesPerSem;
    }

    function getMaxCourseTypes(uint64 _PS) public view returns (uint8 result) {
        ProgrammaSpoudwn storage ps = programmataSpoudwn[_PS];
        result = ps.maxCourseTypes;
    }

    function getRequirementsFormSem(uint64 _PS, uint8 _semID)
        public
        view
        returns (uint8[] memory)
    {
        /// @FutureUpdate: Could use some Gas-Optimization 💡
        ProgrammaSpoudwn storage ps = programmataSpoudwn[_PS];
        Semester storage sem = ps.semesters[_semID];
        uint8 totalCourseTypes = 2; /* /replace with: ps.maxCourseTypes */
        uint8[] memory typeOfCoursesNum = new uint8[](totalCourseTypes); // Array: Holds the required number of Courses of a specific type that need to be passed
        for (uint8 i = 0; i < totalCourseTypes; i++) {
            typeOfCoursesNum[i] = sem.requirements[i]; // Using 3rd Sem as an example : sem.requirements[i]
            // There will be 2 loops, cuz we have 2 Types of Courses.
            // Loop #1: typeOfCoursesNum[0] = sem.requirements[0] = 1
            // Loop #2: typeOfCoursesNum[1] = sem.requirements[1] = 1
            // So using typeOfCoursesNum.length we know the total amount of Course Types this Semester has
            // And the values represent how many Courses of each Type the student must Pass!
        }
        return typeOfCoursesNum; // Output: [1, 1]
    }

    // 🔧 Finally Works!!! 🔧

    function getCourseInfoFromTitle(uint64 _PS, string memory _courseTitle)
        public
        view
        onlyProf_T(msg.sender)
        returns (uint32 courseID, uint8 semMappingCourseID)
    {
        ProgrammaSpoudwn storage ps = programmataSpoudwn[_PS]; // (Programma Spoudwn) PS Level
        uint8 tempA = ps.maxSemesters - 1;
        for (uint8 i = 0; i < tempA; i++) {
            Semester storage sem = ps.semesters[i]; // Semester Level
            uint8 tempB = currentNumOfCourses - 1;
            for (uint8 j = 0; j <= tempB; j++) {
                Course storage cs = sem.courses[j]; // Course Level
                string memory csTitle = cs.title;
                if (
                    keccak256(bytes(csTitle)) == keccak256(bytes(_courseTitle))
                ) {
                    return (sem.courses[j].id, j); // Returns the desired Course Struct
                }
                if (j == currentNumOfCourses) {
                    require(
                        false,
                        "CourseManager.sol: No course matching the inputed title was found"
                    ); // Throws if no course is found.
                }
            }
        }
    }

    function setSecreteryContractAddress_T(address _address)
        public
    /*onlyOwner*/
    {
        SecreteryContractAddress_T = _address;
    }

    // Function Overloading used for Testing - 3 params: ΠΑΔΑ PS, 2 params: Game Academy PS
    // Creates & Returns an array form the given args
    function HardCodeArrayforRequirements(
        uint8 a,
        uint8 b,
        uint8 c
    ) public pure returns (uint8[] memory aaaa) {
        aaaa = new uint8[](3);
        aaaa[0] = a;
        aaaa[1] = b;
        aaaa[2] = c;
    }

    function HardCodeArrayforRequirements(uint8 a, uint8 b)
        public
        pure
        returns (uint8[] memory bbbb)
    {
        bbbb = new uint8[](2);
        bbbb[0] = a;
        bbbb[1] = b;
    }

    /*
    function createDummySemesterReq_A() internal {
        //Semester: #0 -- ΠΑΔΑ
        uint8[] memory CoursesReqArray_0 = HardCodeArrayforRequirements(6, 0 ,0);
        setSemRequirements(0, 0, CoursesReqArray_0);
        delete CoursesReqArray_0;

        //Semester: #1 -- ΠΑΔΑ
        uint8[] memory CoursesReqArray_1 = HardCodeArrayforRequirements(6, 0 ,0);
        setSemRequirements(0, 1, CoursesReqArray_1);
        delete CoursesReqArray_1;

        //Semester: #2 -- ΠΑΔΑ
        uint8[] memory CoursesReqArray_2 = HardCodeArrayforRequirements(6, 0 ,0);
        setSemRequirements(0, 2, CoursesReqArray_2);
        delete CoursesReqArray_2;

        //Semester: #3-- ΠΑΔΑ
        uint8[] memory CoursesReqArray_3 = HardCodeArrayforRequirements(6, 0 ,0);
        setSemRequirements(0, 3, CoursesReqArray_3);
        delete CoursesReqArray_3;

        //Semester: #4 -- ΠΑΔΑ
        uint8[] memory CoursesReqArray_4 = HardCodeArrayforRequirements(6, 0 ,0);
        setSemRequirements(0, 4, CoursesReqArray_4);
        delete CoursesReqArray_4;

        //Semester: #5 -- ΠΑΔΑ
        uint8[] memory CoursesReqArray_5 = HardCodeArrayforRequirements(6, 0 ,0);
        setSemRequirements(0, 5, CoursesReqArray_5);
        delete CoursesReqArray_5;

        //Semester: #6 -- ΠΑΔΑ
        uint8[] memory CoursesReqArray_6 = HardCodeArrayforRequirements(3, 3, 0);
        setSemRequirements(0, 6, CoursesReqArray_6);
        delete CoursesReqArray_6;

        //Semester: #7 -- ΠΑΔΑ
        uint8[] memory CoursesReqArray_7 = HardCodeArrayforRequirements(3, 3, 0);
        setSemRequirements(0, 7, CoursesReqArray_7);
        delete CoursesReqArray_7;

        //Semester: #8 -- ΠΑΔΑ
        uint8[] memory CoursesReqArray_8 = HardCodeArrayforRequirements(1, 5, 0);
        setSemRequirements(0, 8, CoursesReqArray_8);
        delete CoursesReqArray_8;

        //Semester: #9 -- ΠΑΔΑ
        uint8[] memory CoursesReqArray_9 = HardCodeArrayforRequirements(1, 0, 1);
        setSemRequirements(0, 9, CoursesReqArray_9);
        delete CoursesReqArray_9;
    }
*/
    function createDummySemesterReq_B() internal {
        //Semester: #1 -- Game Academy --
        uint8[] memory CoursesReqArray_0 = HardCodeArrayforRequirements(1, 0);
        setSemRequirements(1, 0, CoursesReqArray_0);
        delete CoursesReqArray_0;

        //Semester: #2 -- Game Academy --
        uint8[] memory CoursesReqArray_1 = HardCodeArrayforRequirements(0, 1);
        setSemRequirements(1, 1, CoursesReqArray_1);
        delete CoursesReqArray_1;

        //Semester: #3 -- Game Academy --
        uint8[] memory CoursesReqArray_2 = HardCodeArrayforRequirements(2, 0);
        setSemRequirements(1, 2, CoursesReqArray_2);
        delete CoursesReqArray_2;

        //Semester: #4 -- Game Academy --
        uint8[] memory CoursesReqArray_3 = HardCodeArrayforRequirements(2, 2);
        setSemRequirements(1, 3, CoursesReqArray_3);
        delete CoursesReqArray_3;
    }

    function hardCodeForTesting(bool _password) public onlyOwner {
        require(_password, "CoursesManger.sol : Wrong Password!");

        // -- ΠΑΔΑ --
        // PS ID: 0, Semesters: 10, Total Courses: 71, Course Types: 3
        // (uint64 _PS, uint8 _maxSemesters, uint8 _maxCoursesNum, uint8 _maxCourseTypes)
        // createPS(0, 10, 71, 3);

        // -- ΠΑΔΑ -- Semesters
        // (uint64 _PS, uint8 _semID, uint8 _CoursesPerSem)
        // createSem(0, 0, 2); // #1 Semester
        // createSem(0, 1, 2); // #2 Semester
        // createSem(0, 2, 2); // #3 Semester
        // createSem(0, 3, 2); // #4 Semester
        // createSem(0, 4, 2); // #5 Semester
        // createSem(0, 5, 2); // #6 Semester
        // createDummySemesterReq_A();

        // -- ΠΑΔΑ -- Courses
        // (uint64 _PS, uint8 _semester, uint32 _courseID, int8 _type_, string memory _title)
        // createCourse(0, 0, 1001, 0, "Linear Algebra");    // index: 0
        // createCourse(0, 0, 1002, 0, "General Physics");
        // createCourse(0, 1, 2001, 0, "Arithmitic Analysis");
        // createCourse(0, 1, 2002, 0, "Business Finance");
        // createCourse(0, 2, 7001, 0, "Mhxanotronics");     // index: 4
        // createCourse(0, 2, 7011, 1, "Technical English");
        // createCourse(0, 3, 8003, 0, "Production Systems");
        // createCourse(0, 3, 8009, 1, "Reusable Energy");
        // createCourse(0, 4, 9005, 1, "Marketing"); // <--  // index: 8
        // createCourse(0, 4, 9001, 0, "Robotics");
        // createCourse(0, 5, 10001, 0, "Thesis");
        // createCourse(0, 5, 10002, 2, "Practice");         //index: 11

        // ***************** // ***************** // ***************** // ***************** //

        // -- Game Academy --
        // PS ID: 1, Semesters: 4, Total Courses: 8, Course Types: 2
        createPS(1, 4, 8, 2);

        // -- Game Academy -- Semesters
        // ABI: createSem(uint64 _PS, uint8 _semID, uint8 _CoursesPerSem)
        createSem(1, 0, 1); // #1 Semester: 1 Course
        createSem(1, 1, 1); // #2 Semester: 1 Course
        createSem(1, 2, 2); // #3 Semester: 2 Courses
        createSem(1, 3, 4); // #4 Semester: 4 Courses
        createDummySemesterReq_B();

        // -- Game Academy -- Courses
        // ABI: createCourse(uint64 _PS, uint8 _semester, uint32 _courseID, int8 _type_, string memory _title)
        createCourse(1, 0, 1001, 0, "Rust"); // Semester 1: has 1 Course
        // (Y=1, EY=0)

        createCourse(1, 1, 2001, 1, "Sea of Thieves"); // Semester 2: has 1 Course
        // (Y=0, EY=1)

        createCourse(1, 2, 3001, 0, "World Of Warcraft"); // Semester 3: has 2 Courses
        createCourse(1, 2, 3002, 0, "Apex Legends"); // (Y=2, EY=0)

        createCourse(1, 3, 4001, 0, "League Of Legends"); // Semester 4: has 4 Courses
        createCourse(1, 3, 4002, 1, "Horizon Zero Dawn"); // (Y=2, EY=2)
        createCourse(1, 3, 4003, 0, "Resident Evil 4");
        createCourse(1, 3, 4004, 1, "Pac-Man Master-Elite");
    }
}

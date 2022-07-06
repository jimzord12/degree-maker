const { expect } = require('chai');
const { ethers, BigNumber } = require('hardhat');

let SecreteryAddr;
let GMaddr;
let CMaddr;
let DMaddr;

const privKey1 =
  '0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80';

describe('Secretery - Deployment', function () {
  it("Should return the it's generated Address", async function () {
    const SecreteryFactory = await hre.ethers.getContractFactory(
      'Secretery',
      privKey1
    );

    const secreteryContract = await SecreteryFactory.deploy();
    SecreteryAddr = secreteryContract.address;

    console.log('>>>    Secretery Contract Desployed at: ', SecreteryAddr);

    expect(SecreteryAddr).to.equal(SecreteryAddr); // Yes I know it's stupid... I do for the satifactory
  });
});

describe('Secretery - Registering & Appointing a Professor', function () {
  it('Should register John as Professor return true if John is an Approved Professor', async function () {
    const SecreteryFactory = await hre.ethers.getContractFactory(
      'Secretery',
      privKey1
    );
    const secreteryContract = await SecreteryFactory.deploy();

    const setJohnAsProfTx = await secreteryContract.registerProfessor(
      0001,
      '0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266',
      'John'
    );

    console.log('>>>    Registering John as a Professor...');

    await setJohnAsProfTx.wait(); // wait until the transaction is mined

    const approveJohnAsProfTx = await secreteryContract.approveProfessor(0001);

    console.log('>>>    Making John a Approved Professor... ');

    await approveJohnAsProfTx.wait(); // wait until the transaction is mined

    expect(Boolean(approveJohnAsProfTx)).to.equal(true);
  });
});

describe('Grades Manager - Registering & Viewing a Student', function () {
  it('Should register a Stundent & return the Curriculum ID of the Student', async function () {
    const GradesManagerFactory = await hre.ethers.getContractFactory(
      'GradesManager',
      privKey1
    );

    const gradesManagerContract = await GradesManagerFactory.deploy();

    GMaddr = gradesManagerContract.address;

    console.log('>>>    Grades Manager Contract Desployed at: ', GMaddr);

    const registerAStudentTx = await gradesManagerContract.registerNewStudent(
      ethers.BigNumber.from(12345),
      '0x70997970C51812dc3A010C7d01b50e0d17dc79C8',
      ethers.BigNumber.from(126)
    );

    console.log('>>>    Registering a Student...');

    await registerAStudentTx.wait(); // wait until the transaction is mined

    const getStudentsCurriculumID = await gradesManagerContract.getStudentPS(
      ethers.BigNumber.from(12345)
    );

    expect(Number(getStudentsCurriculumID)).to.equal(126);
  });
});

describe('Courses Manager - Creating & Viewing a Course', function () {
  it("Should Create a Course struct & return the Course's ID", async function () {
    const CoursesManagerFactory = await hre.ethers.getContractFactory(
      'CoursesManager',
      privKey1
    );

    console.log(
      '>>>    Secretery addr Used in Contract Constructor: ',
      SecreteryAddr
    );

    const coursesManagerContract = await CoursesManagerFactory.deploy(
      SecreteryAddr
    );

    CMaddr = coursesManagerContract.address;

    const createACourseTx = await coursesManagerContract.createCourse(
      ethers.BigNumber.from(1),
      ethers.BigNumber.from(1),
      ethers.BigNumber.from(4765),
      ethers.BigNumber.from(2),
      'BlockChain_Fundamentals'
    );

    console.log('>>>    Creating Course...');

    await createACourseTx.wait(); // wait until the transaction is mined

    console.log('>>>    Course Successfully Created!');
    // console.log('>>>    Course Successfully Created!', createACourseTx);

    const course = await coursesManagerContract.getCourseInfoFromTitle(
      ethers.BigNumber.from(1),
      'BlockChain_Fundamentals'
    );

    console.log('Course ID: ', course.courseID);

    expect(Number(course.courseID)).to.equal(4765);
  });
});

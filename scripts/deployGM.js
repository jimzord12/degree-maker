// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require('hardhat');

// Courses Manager Contract
async function CoursesManagerDeploy() {
  const CoursesManagerFactory = await hre.ethers.getContractFactory(
    'CoursesManager'
  );
  const coursesManagerContract = await CoursesManagerFactory.deploy();
  await coursesManagerContract.deployed();
  console.log('CoursesManager deployed to:', coursesManagerContract.address);
}

// Grades Manager Contract
async function GradesManagerDeploy() {
  const GradesManagerFactory = await hre.ethers.getContractFactory(
    'GradesManager'
  );
  const gradesManagerContract = await GradesManagerFactory.deploy();
  await gradesManagerContract.deployed();
  console.log('GradesManager deployed to:', gradesManagerContract.address);
}

// Degree Manager Contract
async function DegreeManagerDeploy() {
  const DegreeManagerFactory = await hre.ethers.getContractFactory(
    'DegreeManager'
  );
  const degreeManagerContract = await DegreeManagerFactory.deploy();
  await degreeManagerContract.deployed();
  console.log('DegreeManager deployed to:', degreeManagerContract.address);
}

// Secretery Contract
async function SecreteryDeploy() {
  const SecreteryFactory = await hre.ethers.getContractFactory('Secretery');
  const secreteryContract = await SecreteryFactory.deploy();
  await secreteryContract.deployed();
  console.log('Secretery deployed to:', secreteryContract.address);
}

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // We get the contract to deploy
  const GradesManagerFactory = await hre.ethers.getContractFactory(
    'GradesManager'
  );
  const gradesManagerContract = await GradesManagerFactory.deploy();
  await gradesManagerContract.deployed();
  console.log('GradesManager deployed to:', gradesManagerContract.address);
  // CoursesManagerDeploy();
  //   GradesManagerDeploy();
  //   DegreeManagerDeploy();
  //   SecreteryDeploy();
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });

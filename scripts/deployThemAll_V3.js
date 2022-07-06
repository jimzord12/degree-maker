const hre = require('hardhat');
const { ethers, BigNumber } = require('hardhat');
const fs = require('fs');
const fse = require('fs-extra');

const dsDir =
  'C:/Users/Jimzord/Documents/1_Programming_Stuff/Web3_Apps/degree-maker/degree-maker-app/src/contractAddresses.json';

const dsDir1 =
  'C:/Users/Jimzord/Documents/1_Programming_Stuff/Web3_Apps/degree-maker/degree-maker-app/src/contractABIs';

const srcDir1 =
  'C:/Users/Jimzord/Documents/1_Programming_Stuff/Web3_Apps/degree-maker/degree-maker-app/artifacts/contracts';

const privKey1 =
  '0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80';

// 1 - Grades Manager Contract
const SecreteryDeploy = async function () {
  console.log('$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$');
  console.log('$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$');
  console.log('=== #1 - Gets in Secr ===');
  const SecreteryFactory = await hre.ethers.getContractFactory(
    'Secretery',
    privKey1
  );
  console.log('=== #2 (Secr)Factory Created! ===');
  const secreteryContract = await SecreteryFactory.deploy();
  secrAddress = secreteryContract.address;
  console.log('Secr Generated Address: ', secrAddress);
  console.log('=== #3 (Secr) Contract is Deploying... ===');
  await secreteryContract.deployed();
  console.log('=== #4 ===');
  console.log('Secretery deployed to:', secrAddress);
  return secrAddress;
};

// 2 - Grades Manager Contract
const GradesManagerDeploy = async function (_secrAddress) {
  console.log('=== #5 - Gets in GM  ===');
  const GradesManagerFactory = await hre.ethers.getContractFactory(
    'GradesManager',
    privKey1
  );
  console.log('=== #6 - (GM)Factory Created! ===');
  console.log('[GM] Secr Addr: ', _secrAddress);
  const gradesManagerContract = await GradesManagerFactory.deploy();
  GMAddress = gradesManagerContract.address;
  console.log('GM Generated Address: ', GMAddress);
  console.log('=== #7 - (GM) Contract is Deploying... ===');
  await gradesManagerContract.deployed();
  console.log('GradesManager deployed to:', GMAddress);
  return { _secrAddress, GMAddress };
};

// 3 - Courses Manager Contract
const CoursesManagerDeploy = async function (_addrObj) {
  console.log('=== #8 - Gets in CM ===');
  const CoursesManagerFactory = await hre.ethers.getContractFactory(
    'CoursesManager',
    privKey1
  );
  console.log('=== #9 - (CM)Factory Created! ===');
  console.log('[CM] Secr Addr: ', _addrObj._secrAddress);
  console.log('[CM] GM Addr: ', _addrObj.GMAddress);
  const coursesManagerContract = await CoursesManagerFactory.deploy(
    _addrObj._secrAddress
  );
  const _GMAddress = _addrObj.GMAddress;
  const _secrAddress = _addrObj._secrAddress;
  const CMAddress = coursesManagerContract.address;
  console.log('CM Generated Address: ', CMAddress);
  console.log('=== #10 - (CM) Contract is Deploying... ===');
  await coursesManagerContract.deployed();
  console.log('CoursesManager deployed to:', CMAddress);
  return { _secrAddress, CMAddress, _GMAddress };
};

// 4 - Degree Manager Contract
const DegreeManagerDeploy = async function (_addrObj) {
  console.log('=== #11 - Gets in DM  ===');
  const DegreeManagerFactory = await hre.ethers.getContractFactory(
    'DegreeManager',
    privKey1
  );
  console.log('=== #12 - (DM)Factory Created! ===');
  console.log('[DM] CM Addr: ', _addrObj.CMAddress);
  console.log('[DM] GM Addr: ', _addrObj._GMAddress);
  const degreeManagerContract = await DegreeManagerFactory.deploy(
    _addrObj.CMAddress,
    _addrObj._GMAddress
  );
  console.log('DM Generated Address: ', degreeManagerContract.address);
  const _DMAddress = degreeManagerContract.address;
  console.log('=== #13 - (DM) Contract is Deploying... ===');
  await degreeManagerContract.deployed();
  console.log('DegreeManager deployed to:', degreeManagerContract.address);
  const AddressesObj = {
    SecreteryAddr: _addrObj._secrAddress,
    GMAddress: _addrObj._GMAddress,
    DMAddress: _DMAddress,
    CMAddress: _addrObj.CMAddress,
  };
  console.log('[DM] Ak-47 ---');
  console.log(AddressesObj);
  return AddressesObj;
};

let resultingAddresses;

const SecrPromise = new Promise((resolve, reject) => {
  resolve(SecreteryDeploy());
});

SecrPromise.then(
  (result) => GradesManagerDeploy(result),
  console.log('GM did NOT deploy')
)
  .then((result2) => {
    console.log('2nd Then()', result2);
    return CoursesManagerDeploy(result2);
  }, console.log('CM did NOT deploy'))
  .then((result3) => {
    console.log('DM did NOT deploy');
    return DegreeManagerDeploy(result3);
  })
  .then((result4) => {
    resultingAddresses = result4;
    console.log('**********************************************************');
    console.log(`SecrAddress: ${resultingAddresses.SecreteryAddr}`);
    console.log(`GMAddress:   ${resultingAddresses.GMAddress}`);
    console.log(`CMAddress:   ${resultingAddresses.CMAddress}`);
    console.log(`DMAddress:   ${resultingAddresses.DMAddress}`);
    console.log('**********************************************************');
    const jsonContent = JSON.stringify(resultingAddresses);

    fs.writeFile(dsDir, jsonContent, 'utf8', function (err) {
      if (err) {
        console.log('An error occured while writing JSON Object to File.');
        return console.log(err);
      }

      console.log(
        'A JSON file containing the Addresses has been saved to /src dir.'
      );
    });

    fse.copySync(
      srcDir1,
      dsDir1,
      {
        overwrite: true,
      },
      (err) => {
        if (err) {
          console.error(err);
        }
      }
    );
    console.log('A folder containing the ABIs has been saved to /src dir.');
    console.log('**********************************************************');
  });

// module.exports = {
//   A: resultingAddresses.SecreteryAddr,
//   B: resultingAddresses.GMAddress,
//   C: resultingAddresses.CMAddress,
//   D: resultingAddresses.DMAddress,
// };

require('@nomiclabs/hardhat-waffle');
require('@nomiclabs/hardhat-etherscan');

// dotenv.config(); // <-- Enables us ot use env files

task('accounts', 'Prints the list of accounts', async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners(); // Receives a Array containing the accounts

  for (const account of accounts) {
    console.log(account.address);
  }
});

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: '0.8.10',
  networks: {
    localhost: {
      url: 'http://127.0.0.1:8545',
    },
  },
};

import { useEffect, useState } from 'react';
import './App.css';
import {
  VStack,
  useDisclosure,
  Button,
  Text,
  Image,
  HStack,
  Select,
  Input,
  Box,
} from '@chakra-ui/react';
import { CheckCircleIcon, WarningIcon } from '@chakra-ui/icons';
import { Tooltip } from '@chakra-ui/react';
import SelectWalletModal from './Modal';
import { useWeb3React } from '@web3-react/core';
import { networkParams } from './networks';
import { connectors } from './connectors';
import { toHex, truncateAddress } from './utils';
import { ethers, BigNumber } from 'ethers';
import PDFfile from './PDFDegree';
import { PDFDownloadLink } from '@react-pdf/renderer';
import PadaLogo from './assets/DegreeImgs/Pada_LOGO.png';
import Scroll from './SmoothScroll.js';

// ======  Importing Contract Data  ====== //

import GradesManagerJSON from './contractABIs/GradesManager.sol/GradesManager.json';
import DegreeManagerJSON from './contractABIs/DegreeManager.sol/DegreeManager.json';
import ContractAddressJSON from './contractAddresses.json';

// ======  Contracts' ABIs  ====== //

const GradesManagerContractABI = GradesManagerJSON.abi;
const DegreeManagerContractABI = DegreeManagerJSON.abi;

export default function Home() {
  const { isOpen, onOpen, onClose } = useDisclosure(); // State from Chakra-lib to interact with modal.js
  const {
    library, //Web3Provider
    chainId,
    account,
    activate,
    deactivate,
    active,
  } = useWeb3React(); // The main lib we are using to connect --@web3-react/core

  // ======  STATES  ====== //

  const [error, setError] = useState('');
  const [network, setNetwork] = useState(undefined);
  const [message, setMessage] = useState();
  const [TokenValid, setTokenValid] = useState(null);
  const [AMValid, setAMValid] = useState(null);
  const [DownloadReady, setDownloadReady] = useState(null);
  const [size, setSize] = useState('');

  const GMAddress = ContractAddressJSON.GMAddress;
  const DMAddress = ContractAddressJSON.DMAddress;

  useEffect(() => {
    const scrollContent =
      document.querySelector('.scroll-content').clientHeight;
    const innerHeight = window.innerHeight;
    // if (scrollContent > innerHeight)
    console.log('Scroll: ', scrollContent);
    console.log('Inner: ', innerHeight);
    if (scrollContent > innerHeight) console.log(1);
    if (scrollContent <= innerHeight) console.log(2);
    document.querySelector('.ponos').style.height = String(innerHeight) + 'px';
    window.innerHeight = window.innerHeight * 1.15;
    const provider = window.localStorage.getItem('provider');
    if (provider) activate(connectors[provider]);
  }, [activate, AMValid]); //If you dont include AMvalid it wont rerender after State has changed!

  // Because useState() Hook is async,
  // I have to make my own sync State xD
  function setAMtoken(result) {
    const a = result;
    console.log('--- 1) setting AM Token ---');
    setAMValid(a);
    console.log('--- 2) setting AM Token ---');
  }

  function setGraduation(result) {
    setTokenValid(result);
  }

  // ======  HANDLERS  ====== //

  // Button: Insert Token AM
  // Gets the text from input field of "Set Message"
  const handleInput = (e) => {
    const msg = e.target.value;
    setMessage(msg);
  };

  // Button: Create Token AM
  // Gets the text from input field of "Set Message"
  async function CreateTokenAM() {
    const provider2 = new ethers.providers.JsonRpcProvider(
      'http://127.0.0.1:8545/'
    );
    // const provider = library;
    const signer = provider2.getSigner(account);
    const contractGM = new ethers.Contract(
      GMAddress,
      GradesManagerContractABI, // We need to compile the GM-Contract to get this from JSON file
      signer
    );
    const am = Number(message);
    const curriculumID = 45;

    await contractGM.registerNewStudent(
      BigNumber.from(am),
      DMAddress,
      BigNumber.from(curriculumID)
    );
  }

  async function checkTokenAM() {
    console.log('Yes: 43215'); // Can Graduate
    console.log('No:  45789'); // Can NOT Graduate

    const provider2 = new ethers.providers.JsonRpcProvider(
      'http://127.0.0.1:8545/' // Used JsonRpcProvider, cuz we run a local EVM
    );
    // const provider = library; // Provides a Web3Provider
    const signer = provider2.getSigner(account);
    const contractGM = new ethers.Contract(
      GMAddress,
      GradesManagerContractABI, // We need to compile the GM-Contract to get this from JSON file
      signer
    );
    // const am = 43215;
    const responce = await contractGM.getStudentPS(
      BigNumber.from(Number(message))
    );
    console.log('--- 2.0 ---');
    console.log('Σκονακι: 45789, 43215');
    try {
      if (responce.toNumber() === 0) {
        const success = false;
        setAMtoken(success);
        setAMValid(success);
        console.log('--- 2.1 ---');
        console.log(
          `Response: ${responce.toNumber()}, Result: ${Boolean(
            responce.toNumber()
          )}`
        );
      } else {
        const success = true;
        setAMtoken(success);
        setAMValid(success);

        console.log('--- 2.2 ---');
        console.log(
          `Response: ${responce.toNumber()}, Result: ${Boolean(
            responce.toNumber()
          )}`
        );
      }
    } catch (responce) {}
    console.log('--- 3.0 ---');
  }

  // Handles Can-I-Graduate? Buttom
  async function handleGraduationCheck() {
    // const signer = provider.getSigner();
    // const provider = library; // Provides a Web3Provider
    const provider2 = new ethers.providers.JsonRpcProvider(
      'http://127.0.0.1:8545/' // Used JsonRpcProvider, cuz we run a local EVM
    );
    const signer = provider2.getSigner(account);
    const DMcontract = new ethers.Contract(
      DMAddress,
      DegreeManagerContractABI, // We need to compile the DM-Contract to get this from JSON file
      signer
    );

    try {
      const responce = await DMcontract.checkIfStudentCanGraduate(
        BigNumber.from(Number(message))
      );
      const responce2 = await DMcontract.isEligibleToGraduate(
        BigNumber.from(Number(message))
      );
      // If we do NOT get an revert Error:
      console.log('--- 1.0 ---');
      const success = true;
      setGraduation(success);
      console.log('--- 1.1 ---');
      console.log('Tx: ', responce, 'Result: ', success);
      console.log('is Eligible To Graduate: ', responce2);
    } catch (responce2) {
      // If we DO get an revert Error:
      console.log('Revert error was thrown!');
      console.log("Student didn't met the criteria for Graduation!");
      const success = false;
      setGraduation(success);
      console.log('Can Student Graduate: ', success);
    }
  }

  async function handleDegreeIssuance() {
    const provider2 = new ethers.providers.JsonRpcProvider(
      'http://127.0.0.1:8545/' // Used JsonRpcProvider, cuz we run a local EVM
    );
    const signer = provider2.getSigner(account);
    const DMcontract = new ethers.Contract(
      DMAddress,
      DegreeManagerContractABI, // We need to compile the DM-Contract to get this from JSON file
      signer
    );
    try {
      console.log('--- 1.0 ---');
      console.log(DMcontract);
      const responce = await DMcontract.mint(BigNumber.from(Number(message)));
      console.log('--- 1.1 ---');
      console.log(responce);
      const responce2 = await DMcontract.balanceOf(responce.from);
      console.log('Balance: ', responce2.toNumber());
      setDownloadReady(true);
      console.error('signer1 ', signer);
      console.error('Tx: ', responce2);
      console.error('account : ', account);
      console.log('--- 1.2 ---');
    } catch (responce) {
      // If we DO get an revert Error:
      console.log('Revert error was thrown!');
      console.log(
        'For some reason can NOT issue the Degree, Call the Mastora!'
      );
      console.error(responce);
    }
  }

  // This is used when we toggle between networks using the scroll down menu
  // ! DOES NOT APPEAR WHEN USING Metamask
  // Button: Switch Network
  const handleNetwork = (e) => {
    const provider2 = new ethers.providers.JsonRpcProvider(
      'http://127.0.0.1:8545/'
    );
    const id = e.target.value;
    console.log('Chain ID: ' + id); // The chain ID
    console.log('Connection URL: ', /*library*/ provider2.connection.url); //
    setNetwork(Number(id));
    console.log('Singer: ', /*library*/ provider2.getSigner(account));
    // const provider = window.localStorage.getItem("provider");
    //console.log(connectors[provider].getSigner());
  };

  // ! DOES NOT APPEAR WHEN USING Metamask
  const switchNetwork = async () => {
    const provider2 = new ethers.providers.JsonRpcProvider(
      'http://127.0.0.1:8545/'
    );
    console.log(`Swithing to network with Chain ID: ${network}`);
    try {
      await // library.provider
      provider2.request({
        method: 'wallet_switchEthereumChain',
        params: [{ chainId: toHex(network) }],
      });
    } catch (switchError) {
      if (switchError.code === 4902) {
        try {
          await // library.provider
          provider2.request({
            method: 'wallet_addEthereumChain',
            params: [networkParams[toHex(network)]],
          });
        } catch (error) {
          setError(error);
        }
      }
    }
  };

  // Only used at disconnect() - Below
  const refreshState = () => {
    window.localStorage.setItem('provider', undefined);
    setNetwork('');
    setMessage('');
    // setSignature("");
    // setVerified(undefined);
    // setVerified(true);
  };

  const disconnect = () => {
    refreshState();
    deactivate();
  };

  // ==== JSX Starts Here! ==== //

  return (
    <div className="a">
      <VStack
        className="ponos"
        justifyContent="center"
        alignItems="center"
        // Maing it Responsive
        // * Notes:
        // * 100vh για 4Κ, Content < UI => Αλλα κανει το Content == UI
        // * '' για 1080p, Content > UI
        h={''}
      >
        <Image
          className="Pada_img"
          boxSize={['200px', '260px', '320px']}
          src={PadaLogo}
          objectFit="cover"
          alt="ΠΑΔΑ Λογοτυπο"
        />
        <Scroll />
        <HStack marginBottom="10px">
          <Text
            margin="0"
            lineHeight="1.15"
            fontSize={['1.5em', '2em', '3em', '4em']}
            fontWeight="600"
          >
            ΠΑΔΑ BlockChain
          </Text>
        </HStack>
        <HStack>
          {!active ? (
            <Button color="green" onClick={onOpen}>
              Connect Wallet
            </Button>
          ) : (
            <Button color="red" onClick={disconnect}>
              Disconnect
            </Button>
          )}
        </HStack>
        <VStack justifyContent="center" alignItems="center" padding="10px 0">
          <HStack>
            <Text textColor="blue.300">{`Connection Status: `}</Text>
            {active ? (
              <>
                <Text textColor="orange">{`${library.connection.url}`}</Text>

                <CheckCircleIcon color="green" />
              </>
            ) : (
              <WarningIcon color="#cd5700" />
            )}
          </HStack>
          <Tooltip label={account} placement="right">
            <HStack>
              <Text textColor="blue.300">{`Account: `}</Text>
              <Text textColor="red.300">{truncateAddress(account)}</Text>
            </HStack>
          </Tooltip>
          <HStack>
            <Text textColor="blue.300">{`Network ID: `}</Text>
            <Text textColor="red.300">{chainId ? chainId : 'No Network'}</Text>
          </HStack>

          <HStack>
            {/* === Create Token AM === */}
            {active ? (
              <Box
                maxW="sm"
                borderWidth="1px"
                borderRadius="lg"
                overflow="hidden"
                padding="10px"
                color=""
              >
                <VStack>
                  <Button
                    color="tomato"
                    onClick={CreateTokenAM} /*isDisabled={!message}*/
                  >
                    Create Token AM
                  </Button>
                  <Input
                    placeholder="Token AM"
                    maxLength={20}
                    onChange={handleInput}
                    w="380px"
                  />
                  <VStack
                    justifyContent="inline"
                    alignItems="inline"
                    padding="10px 0"
                  ></VStack>
                </VStack>
              </Box>
            ) : null}
          </HStack>

          {/* === Insert Token AM === */}
          {active ? (
            <Box
              maxW="sm"
              borderWidth="1px"
              borderRadius="lg"
              overflow="hidden"
              padding="10px"
              color=""
            >
              <VStack>
                <Button
                  color="blue"
                  onClick={checkTokenAM} /*isDisabled={!message}*/
                >
                  Check Token AM
                </Button>
                <Input
                  placeholder="Insert Token"
                  maxLength={20}
                  onChange={handleInput}
                  w="380px"
                />
                {AMValid !== null ? (
                  AMValid ? (
                    <VStack
                      justifyContent="inline"
                      alignItems="inline"
                      padding="10px 0"
                    >
                      <HStack>
                        <Tooltip label={'a'} placement="bottom">
                          <Text textColor="lightgreen">{`Accepted!`}</Text>
                        </Tooltip>
                        <CheckCircleIcon color="green" />
                      </HStack>
                    </VStack>
                  ) : (
                    <VStack
                      justifyContent="inline"
                      alignItems="inline"
                      padding="10px 0"
                    >
                      <HStack>
                        <Tooltip label={'a'} placement="bottom">
                          <Text textColor="red">{`Rejected!`}</Text>
                        </Tooltip>
                        <WarningIcon color="red" />
                      </HStack>
                    </VStack>
                  )
                ) : null}
              </VStack>
            </Box>
          ) : null}
        </VStack>

        {active && (
          <HStack justifyContent="flex-start" alignItems="flex-start">
            {library.connection.url !== 'metamask' && (
              <Box
                maxW="sm"
                borderWidth="1px"
                borderRadius="lg"
                overflow="hidden"
                padding="10px"
              >
                <VStack>
                  <Button
                    textColor="blue"
                    onClick={switchNetwork}
                    isDisabled={!network}
                  >
                    Switch Network
                  </Button>
                  <Select
                    className="SelectNetwork"
                    // bg="tomato"
                    borderColor="tomato"
                    textColor="blue"
                    placeholder="Select network"
                    // bg="gray"
                    onChange={handleNetwork}
                  >
                    <option value="31337">Hardhat Local</option>
                    <option value="3">Ropsten</option>
                    <option value="4">Rinkeby</option>
                    <option value="42">Kovan</option>
                    <option value="1666600000">Harmony</option>
                    <option value="42220">Celo</option>
                  </Select>
                </VStack>
              </Box>
            )}
            {/* === Can I Graduate ==== */}
            <Box
              maxW="sm"
              borderWidth="1px"
              borderRadius="lg"
              overflow="hidden"
              padding="10px"
            >
              <VStack
                justifyContent="center"
                alignItems="center"
                padding="10px 0"
              >
                <Button
                  color="blue"
                  onClick={handleGraduationCheck} /*isDisabled={} TokenValid*/
                >
                  Can I Graduate?
                </Button>
                {TokenValid !== null ? (
                  TokenValid ? (
                    <VStack
                      justifyContent="center"
                      alignItems="center"
                      padding="10px 0"
                    >
                      <HStack
                        justifyContent="center"
                        alignItems="center"
                        padding="10px 0"
                      >
                        <Text color="lightgreen">🏆 Yes, Congrats! </Text>
                      </HStack>
                      <Button color="green" onClick={handleDegreeIssuance}>
                        Degree Issuance
                      </Button>
                    </VStack>
                  ) : (
                    <VStack>
                      <HStack>
                        {/* <WarningIcon color="red" /> */}
                        <Text color="red">Sadly, no 😔</Text>
                      </HStack>
                    </VStack>
                  )
                ) : null}
              </VStack>
            </Box>
          </HStack>
        )}
        <Text>{error ? error.message : null}</Text>
        {/* Downloading Degree */}
        {DownloadReady && (
          <Box
            maxW="sm"
            // h="100px"
            borderWidth="1px"
            borderRadius="lg"
            overflow="hidden"
            padding="10px"
          >
            <PDFDownloadLink document={<PDFfile />} fileName="YourDegree!">
              {({ loading }) =>
                loading ? (
                  <Button color={'red'}>Loading...</Button>
                ) : (
                  <Button color={'blue'}>Download!</Button>
                )
              }
            </PDFDownloadLink>
          </Box>
        )}
      </VStack>
      <SelectWalletModal isOpen={isOpen} closeModal={onClose} />
      <div className="moving-background"></div>
    </div>
  );
}

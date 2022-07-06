import { StrictMode } from 'react';
import ReactDOM from 'react-dom';
import { ChakraProvider } from '@chakra-ui/react';
import { Web3ReactProvider } from '@web3-react/core';
import { ethers } from 'ethers';

import App from './App';

const getLibrary = (provider) => {
  const library = new ethers.providers.Web3Provider(provider);
  library.pollingInterval = 4000; // frequency provider is polling
  return library;
};

const rootElement = document.getElementById('root');
ReactDOM.render(
  <StrictMode>
    <ChakraProvider>
      <Web3ReactProvider getLibrary={getLibrary}>
        <App />
      </Web3ReactProvider>
    </ChakraProvider>
  </StrictMode>,
  rootElement
);

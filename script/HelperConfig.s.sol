//SPDX-License-Identifier:MIT

//Deploy mocks when we are on local anvil chain
//keep track of contract adress for different chains
//sepolia ETH/USD
//Mainnet ETH/USD

pragma solidity 0.8.18; //stating the solidity version

import {Script} from "forge-std/Script.sol"; 
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";
contract HelperConfig is Script {  //for defining that this is a script.


    struct NetworkConfig{
        address pricefeed; //ETH/USD pricefeed address
    }

    NetworkConfig public activenetworkconfig;

//depending on which network we are value is assigned to activenetworkconfig.
//We determine the network that we are on by matching the ChainID whichis unique for all the networks.
//Chaindid for sepolia is 11155111
    constructor(){
        if(block.chainid ==11155111)
        {
            activenetworkconfig=getSepolia();
        }
        else if(block.chainid ==1)
        {
            activenetworkconfig=getethMainnet();
        }
        else{
            activenetworkconfig=getAnvil();
        }
        }
   
    function getSepolia() public pure returns(NetworkConfig memory){

        NetworkConfig memory sepoliaConfig=NetworkConfig({
            pricefeed:0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return sepoliaConfig;

    }

    function getethMainnet() public pure returns(NetworkConfig memory){

        NetworkConfig memory ethConfig=NetworkConfig({
            pricefeed:0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        });
        return ethConfig;

    }
    function getAnvil() public  returns(NetworkConfig memory){

 //for deploying on local chain like anvil:

  //deploy a mock contarct
  //and then get the mock address
      vm.startBroadcast();
      MockV3Aggregator mockv3aggregator=new MockV3Aggregator(8,2000e8);  
      //MockV3Aggregatorcontract constructor has 2 variables --decimals and initialanswer (initial price) which are passed here as 8 and 2000e8 respectively.
     
      vm.stopBroadcast();
      //basically we deploy MockV3Aggregator contract here to get the pricefeed and then the price feed address is assigned to anvilConfig.

       NetworkConfig memory anvilConfig=NetworkConfig({
            pricefeed:address(mockv3aggregator)  //we get the pricefeed for our local anvil chain.
        });
        return anvilConfig;
    }
    }
    //code for getting the pricefeed for the local chain is written in MOckV3Aggregator contract.

    //forge test ----   means deploying contract on local anvil chain
    //forge test --fork-url $SEPOLIA_RPC_URL  ----- means deploying contract on sepolia network.here api call is made to the specified fork url.
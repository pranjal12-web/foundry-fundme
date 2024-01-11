//SPDX-License-Identifier:MIT
pragma solidity 0.8.18;//stating the solidity version


import {AggregatorV3Interface} from  "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

//This library basically converts eth to usd
library PriceConverter{
    function getPrice(AggregatorV3Interface datafeed) public view returns (uint256) {
         
         //below written code is only for deploying our contract on sepolia ,but we dont want it to be hard coded and hence we will take the address as an input itself
        //  AggregatorV3Interface datafeed = AggregatorV3Interface(
        //     0x694AA1769357215DE4FAC081bf1f309aDC325306  // address for ETH/USD on sepolia network
        // );

        (
            /* uint80 roundID */,
            int256 answer,
            /* uint startedAt */,
            /* uint timeStamp */,
            /* uint80 answeredInRound */
        ) = datafeed.latestRoundData();

        // Return the price with 10 decimals
        return uint256(answer * 1e10);
    

//datafeed has 8 decimals.
//So answer has 8 decimals and is an integer value.So we need to match the no. of decimals and also convert answer into uint.
}


function getconversion(uint256 ethamt,AggregatorV3Interface datafeed) public view returns(uint256){
      uint256 pricerate=getPrice(datafeed);
      uint256 ethamtinUSD=(ethamt*pricerate)/1e18;
      return ethamtinUSD;
}

}

//functions getPrice and getconversion were first directly defined inside FundMe contract in FundMe.sol . Now we have
// put those inside a library and we will now just import this library in FundMe.sol so that we can access those functions
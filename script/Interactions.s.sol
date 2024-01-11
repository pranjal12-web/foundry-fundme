//SPDX-License-Identifier:MIT

pragma solidity 0.8.18; //stating the solidity version

import {Script,console} from "forge-std/Script.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundFundMe is Script{

     uint256 SEND_VALUE = 0.1 ether;

    function fundFundMe(address mostRecentlyDeployed) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentlyDeployed)).fund{value: SEND_VALUE}(); 
        //Sending eth to most recently deployed FundMe contract .payable keyword is used to explicitly convert mostRecentlyDeployed to a payable address, indicating that it can receive ether.
        vm.stopBroadcast();
        console.log("Funded FundMe with %s", SEND_VALUE);
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid); //address of the most recently deployed instance of the FundMe contract.
        fundFundMe(mostRecentlyDeployed);
    }

}

contract WithdrawFundMe is Script{

    function withdrawFundMe(address mostRecentlyDeployed) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentlyDeployed)).withdraw(); 
        //Sending eth to most recently deployed FundMe contract .payable keyword is used to explicitly convert mostRecentlyDeployed to a payable address, indicating that it can receive ether.
        vm.stopBroadcast();
       
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid); //address of the most recently deployed instance of the FundMe contract.
        withdrawFundMe(mostRecentlyDeployed);
    }

}
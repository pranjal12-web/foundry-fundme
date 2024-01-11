//SPDX-License-Identifier:MIT
pragma solidity 0.8.18; //stating the solidity version

import {Script} from "forge-std/Script.sol"; //for defining that this is a script.
import {FundMe} from "../src/FundMe.sol"; //importing the contract
import {HelperConfig} from "../script/HelperConfig.s.sol";

//Following is the script to deploy the Simplestorage smart contract.

contract DeployFundMe is Script {
    function run() external payable returns (FundMe) {
        //vm is a special keyword used only in foundry

        //Before broadcast -- not a real transaction
        HelperConfig helperconfig=new HelperConfig();
        address ethusdpricefeed =helperconfig.activenetworkconfig();

        //After broadcast -- It is a real transaction
        vm.startBroadcast();
        FundMe fundme = new FundMe( ethusdpricefeed);
        vm.stopBroadcast();

        //Anything between  vm.startBroadcast(); and vm.stopBroadcast(); is sent as a transaction to rpcUrl
        return fundme;
    }
}

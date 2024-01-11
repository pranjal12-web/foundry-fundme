//SPDX-License-Identifier:MIT
pragma solidity 0.8.18;//stating the solidity version

import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol";
import {FundMe} from "../../src/FundMe.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {Test, console} from "forge-std/Test.sol";
import {StdCheats} from "forge-std/StdCheats.sol";
//this is for testing the interactions script.

contract FundMeTestIntegration is Test{

    FundMe public fundMe; //creating instance of FundMe contract
    HelperConfig public helperConfig;  //creating instance of HelperConfig contract

    address USER =makeAddr("user");

    //declaring public constants:
    uint256 public constant SEND_VALUE = 0.1 ether; // just a value to make sure we are sending enough!
    uint256 public constant STARTING_USER_BALANCE = 10 ether;
    uint256 public constant GAS_PRICE = 1;

    function setUp() external {

        DeployFundMe deployer = new DeployFundMe(); //deploy DeployFundMe contract.
        fundMe=deployer.run();
        //above two lines mean ==  FundMe fundMe =new FundMe();

       //(fundMe, helperConfig) = deployer.run();
        vm.deal(USER, STARTING_USER_BALANCE);
    }

    function testUserCanFundAndOwnerWithdraw() public {

        //testing  fundFundMe contract
        FundFundMe fundFundMe = new FundFundMe();  //deploy fundFundMe contract from interactions script.
        fundFundMe.fundFundMe(address(fundMe)); //funding FundMe contract

        //testing  withdrawFundMe contract
        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();//deploy withdrawFundMe contract from interactions script.
        withdrawFundMe.withdrawFundMe(address(fundMe)); //Withdrawing from Fundme contract

        assert(address(fundMe).balance == 0);
    }

}
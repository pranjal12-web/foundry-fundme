//SPDX-License-Identifier:MIT
pragma solidity 0.8.18;//stating the solidity version

import{Test,console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test{

    FundMe public fundme;
    address USER =makeAddr("user"); //make fake user who will send transaction
    //vm.deal(USER,10e8) //starting balance(fake money) of fake user =10e8

    function setUp() external{
        fundme=new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306 );
        //deploying fundme contract inside this contract.
    }

      modifier funded{
        vm.prank(USER);
        fundme.fund{value:10e8}();
        _;
    }

    function testMinimumUSD() public{
        console.log("hello");
         
        assertEq(fundme.MINIMUM_USD(),5e18);
    }

    function testOwner() public{
        console.log(fundme.getOwner());
        console.log(msg.sender);
         
        assertEq(fundme.getOwner(),address(this));
    }

    function fundrevert() public {
        vm.expectRevert(); //next line should revert.
        fundme.fund(); //sends 0 value and hence this fails

        //basically this test passes when line after vm.expectrevert() fails.
    }
    function fundUpdates() public{
        vm.prank(USER);//next transaction will be sent by USER
       fundme.fund{value:10e8}(); //sending 10 ether

       uint256 amountfunded=fundme.getAddresstoamountfunded(USER);
       assertEq(amountfunded,10e8);
    }
    
     function checkFunderaddress() public{
        vm.prank(USER);//next transaction will be sent by USER
       fundme.fund{value:10e8}(); //sending 10 ether

       address funder=fundme.getfunder(0);
       assertEq(funder,USER);
    }


     function testOnlyOwnercanwithdraw() public funded{
      vm.prank(USER);//next transaction will be sent by USER
      vm.expectRevert();
      fundme.withdraw(); //this transaction will be sent by the USER
       
       // why does fundme.withdraw fail?
    //even if fund function is called by USER according to the modifier funded, owner of fundme functions remains the one who deployed the contract i.e FundMeTest contract address --- and hence fundme.withdraw function fails when it is called by USER as USER is not the owner.

    }

    //NOT UNDERSTOOD

    function testWithdrawSingleFunder() public funded {
        //Arrange
        uint256 startingownerbalance=fundme.getOwner().balance;
        uint256 startingfundmebalance=address(fundme).balance;

        // address(fundme).balance: is converting the contract fundme into an address type and then accessing its balance. The address type in Solidity has a .balance property that holds the Ether balance associated with the contract. This balance represents the amount of Ether held by the contract itself.

        //Act
        vm.prank(fundme.getOwner());
        fundme.withdraw(); //here withdraw function is called by the owner of FundMe contract and hence it wont be reverted

        //Assert
        uint256 endingownerbalance=fundme.getOwner().balance;
        uint256 endingfundmebalance=address(fundme).balance;

        assertEq(endingfundmebalance,0);
        assertEq(startingfundmebalance+startingownerbalance,endingownerbalance);

    }

    function testWithdrawMultipleFunders() public funded{

        uint160 numberOfFunders=10;
        uint160 startingIndex=2;
        for(uint160 i=startingIndex;i<numberOfFunders;i++)
        {
            hoax(address(i),10e8); //this function combines vm.prank and vm.deal together
            fundme.fund{value:10e8}();
        }

        uint256 startingownerbalance=fundme.getOwner().balance;
        uint256 startingfundmebalance=address(fundme).balance;

        //Act
        vm.startPrank(fundme.getOwner());
        fundme.withdraw(); //here withdraw function is called by the owner of FundMe contract and hence it wont be reverted
        vm.stopPrank();

        //Assert
        uint256 endingownerbalance=fundme.getOwner().balance;
        uint256 endingfundmebalance=address(fundme).balance;

        assertEq(endingfundmebalance,0);
        assertEq(startingfundmebalance+startingownerbalance,endingownerbalance);

    }


    function testWithdrawMultipleFunderscheaper() public funded{

        uint160 numberOfFunders=10;
        uint160 startingIndex=2;
        for(uint160 i=startingIndex;i<numberOfFunders;i++)
        {
            hoax(address(i),10e8); //this function combines vm.prank and vm.deal together
            fundme.fund{value:10e8}();
        }

        uint256 startingownerbalance=fundme.getOwner().balance;
        uint256 startingfundmebalance=address(fundme).balance;

        //Act
        vm.startPrank(fundme.getOwner());
        fundme.cheapwithdraw(); //here withdraw function is called by the owner of FundMe contract and hence it wont be reverted
        vm.stopPrank();

        //Assert
        uint256 endingownerbalance=fundme.getOwner().balance;
        uint256 endingfundmebalance=address(fundme).balance;

        assertEq(endingfundmebalance,0);
        assertEq(startingfundmebalance+startingownerbalance,endingownerbalance);

    }


}

//here we are deploying FundMeTest contract which in turn is deploying FundMe contract.
//we--> FundMeTest --> FundMe
//fundme.i_owner() is basically the address of the user who deploys FundMe contract and hence it is the address of FundMeTest contract.
//address(this) returns the address of the current contract i.e  FundMeTest. i.e address(this)==FundMeTest contract address ==fundme.i_owner()
//whereas msg.sender in this contract means address of the user who is deploying FundMeTest contract == Our address.

//We can set our own gas price : vm.txGasPrice(10e7);
// gasleft(); --- returns amount of gas left in the transaction at that moment.
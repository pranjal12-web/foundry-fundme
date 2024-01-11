//SPDX-License-Identifier:MIT
pragma solidity 0.8.18;//stating the solidity version

//chainlink github-->contracts-->src-->v0.6-->interfaces-->AggregatorV3Interface.sol
//from there we copy the code.

// pragma solidity ^0.6.0;

// // AggregatorV3Interface is an interface contract consisting of list of functions which is to be implemented by another contract.
// interface AggregatorV3Interface { //interface is a keyword

//   function decimals()
//     external
//     view
//     returns (
//       uint8
//     );

//   function description()
//     external
//     view
//     returns (
//       string memory
//     );

//   function version()
//     external
//     view
//     returns (
//       uint256
//     );

//   function getRoundData(
//     uint80 _roundId
//   )
//     external
//     view
//     returns (
//       uint80 roundId,
//       int256 answer,
//       uint256 startedAt,
//       uint256 updatedAt,
//       uint80 answeredInRound
//     );

//   function latestRoundData()
//     external
//     view
//     returns (
//       uint80 roundId,
//       int256 answer,
//       uint256 startedAt,
//       uint256 updatedAt,
//       uint80 answeredInRound
//     );

// }

//instead of writing the whole code here , we can directly import it from github.
import {AggregatorV3Interface} from  "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";

contract FundMe{

    error FundMe__notOwner();

    using PriceConverter for uint256;

    uint public myNum = 1;
    uint public constant MINIMUM_USD=5e18; //5*10^18
    AggregatorV3Interface private s_pricefeed;
    
    address[] public funders;
    mapping(address funder => uint256 amtfunded) public addresstoamtfunded;
    address private immutable i_owner;

    //constructor is a special function  which is called automatically when the contrcat gets deployed.
    constructor(address pricefeed){
        i_owner =msg.sender;  //owner=msg.sender= address of the person deploying this contract
        s_pricefeed=AggregatorV3Interface(pricefeed);
    }

//fund function is for collecting funds from the users.So we make that function payable by adding the keyword payable.
    function fund() public payable {

        myNum = myNum+2; //Value of myNum is updated only when the transaction is successful.When transaction fails value of myNum remains 1 itself.
      //  require(msg.value > 1e18,"Send atleast 1 ether");

    //1e18 =1ether.require(msg.value > 1e18,) means user must send atleast 1 ether otherwise transaction will not take place.
    //"Send atleast 1 ether" -->  this is arevert msg which is displayed when transaction doesn't take place.

    //if a transaction reverts then it undoes everything it has executed before.
    //even if transaction fails -- some gas is spent
     require(msg.value.getconversion( s_pricefeed)> MINIMUM_USD,"Send atleast minimumusd");  //user must send atleast 5 usd otherwise transaction will not take place.
//but the user is sending eth ,so how much minimum eth he has to send will be understood when we know the conversion from eth to usd and for this we write a function

//msg.value is in ETH and has 18 decimals and is uint variable.
   funders.push(msg.sender); //msg.sender refers to the person who calls the fund function.
   addresstoamtfunded[msg.sender]= addresstoamtfunded[msg.sender]+ msg.value;
    }

    //msg.value -- amount of wei sent with the message
    //msg.sender -- address pf the person calling the function i.e deployer of the contract
    //these both are global units in solidity.

    //we want withdraw function to be called only by the owners and hence we have used onlyOwner modifier
    function withdraw() public onlyOwner{

        //this for loop is updating the mapping.
        for(uint256 funderindex=0;funderindex<funders.length;funderindex++){  //for(int i=0;i<4;i++)
           address funder=funders[funderindex];
           addresstoamtfunded[funder]=0; //we are setting the amount equal to zero as we are withdrawing all the money.
        }  

        //reset the array:
        funders=new address[](0);//resetting the array funders(which was already created) to blank address array of 0 length.length;

        //now actually withdraw the money i.e send the money back to the addresses who called the fund function:
        //Sending ether to other contracts:
        //There are three ways :send,call,transfer.

        //transfer
        //payable(msg.sender).transfer.(address(this).balance); 
        //address(this).balance defines how much amount of ether to pay to that address.
        //address(this).balance == total amt of ether that address has sent us till date.

        //msg.sender==address type
        //payable(msg.sender) == payable address type.

        //transfer function is capped at 2300 gas and if more amount of gas is used in sending ether then it throws error
        //and transaction reverts.

        //send
        //payable(msg.sender).send.(address(this).balance); 

        //send function is capped at 2300 gas and if more amount of gas is used in sending ether then it doesnt revert the 
        //transaction rather it returns a boolean stating whether the transaction is successful or transaction failed.

        //so in order to revert the transaction:
        //require(( payable(msg.sender).send.(address(this).balance); ),"Failed");
        //withput require keyword the transaction wont be reverted ,only false boolean will be returned.

        //call:
       // (bool callSuccess,bytes dataReturned)=payable(msg.sender).call{value: address(this).balance}("");
        //this call function returns two variables --> boolean stating whether transaction was succesful or not and also call 
        //function can call another function as well , any data/bytes returned by that function will be stored in dataReturned.
        //But we are not calling any other function and hence not interested in dataReturned variable.

         (bool callSuccess,)=payable(msg.sender).call{value: address(this).balance}("");
         require(callSuccess,"Call Failed"); //if callSuccess is false then the transaction reverts and Call Failed message is shown.
        
        //call function does not have maximum gas limit.

    }

    function cheapwithdraw() public onlyOwner{

        
//reading and writing into storage is more gas expensive than reading and writing into memory.

        //if we use funders.length in the for loop -- we are reading from storage multiple times which is gas expensive and hence we create a new variable funderslength for which we need to read funders.length from storage only once.And then use funderslength inside the for loop which is reading from the memory.

        uint256 funderslength = funders.length;

        for(uint256 funderindex=0;funderindex<funderslength;funderindex++){  
           address funder=funders[funderindex];
           addresstoamtfunded[funder]=0; 
        }  

        funders=new address[](0);

        
         (bool callSuccess,)=payable(msg.sender).call{value: address(this).balance}("");
         require(callSuccess,"Call Failed"); 

    }

    //Modifier -- keyword which is used to give some special functionality to a particular function.

    //onlyOwner modifier is used when the function can be called only by the owners i.e only by the people who have funded.

    modifier onlyOwner(){
        if(msg.sender!=i_owner) {revert FundMe__notOwner();} //custom error  //revert the transaction if sender is not the owner
       // require(msg.sender==i_owner,"Sender is not owner");  //revert the transaction if sender is not the owner
        _; //execute rest of the code
    }

    function getVersion() public view returns(uint256){
        return s_pricefeed.version(); //version is inbuilt function which returns the version of the pricefeed.

    }


//What if someone directly sends some eth to the address where this contract is deployed without calling fund function?
//In such cases it throws error.But when someone directly sends some eth to the address where this contract is deployed
//receive and fallback functions are called bydefault and hence we have wrapped fund function inside that.


    receive() external payable { 
    fund();
}

    fallback() external payable { 
    fund();
}

function getAddresstoamountfunded(address fundingaddress) external view returns(uint256){
    return addresstoamtfunded[fundingaddress];
    //take input as fundingaddress and return amount funded (uint256) corresponding to that fundingaddress
}
function getfunder(uint256 index ) external view returns(address)
{
    return funders[index]; //returns the address of funder corresponding to the index given as input.
    //funders is an array consisting of addresses of all the funders.
}

function getOwner() external view returns(address)
{
    return i_owner;
    //this function basically returns the address of owner of the contract(i.e the one who deploys the contract==one who funds certain amount of money)
}
 }

//while deploying keep the value as 0 ether. Once deployed while calling fund function --> specify the value in ether that 
//we want to send to the contract.This amount is being sent from the wallet on which the contract is deployed to the contract.

//how to interact with the contracts outside the projects:
// first get the interface of that contract and then make api calls. Wrap an address around that contract interface and
//  then call any function that we wish to from that contract.

//functions getPrice and getconversion were first directly defined inside FundMe contract in FundMe.sol . Now we have
// put those inside a library and we will now just import this library in FundMe.sol so that we can access those functions

//Gas optimization -- making the contract gas efficient i.e reducing the amount of gas spent in deploying the contract.
//this can be done by using keywords like immutable and constant for the variables which do not change ever in the contract.

//In Advanced Solidity , we can have custom errors instead of require statement which reduce gas.for eg:
//if(msg.sender!=i_owner) {revert notOwner();}

//naming the variabkes in a certain manner :
//starting the variables with i_  for immutable variables
//starting the variables with s_  for storage variables

//immutable variables and constants are not stored in storage.abi

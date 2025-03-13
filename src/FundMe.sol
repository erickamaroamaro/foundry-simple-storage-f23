// SPDX-License-Identifier:MIT

pragma solidity ^0.8.28;


import {PriceConverter} from "./PriceConverter.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

error FundMe__NotOwner();

contract FundMe {
    using PriceConverter for uint256;

    uint256 public constant MINIMUM_USD = 5e18;
    AggregatorV3Interface private s_priceFeed;

    address[] public funders;
    mapping (address funder => uint256 amountFunded) public addressToAmountFunded;

    address public immutable i_owner;

    constructor(address priceFeed){
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeed);
    }

    // take a look at chainlink functions 
    function fund () payable public {
        require(msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD, "didn't send enoght eth");
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] += msg.value;
        // revert transaction if condition not true
    }

    function withdraw() public onlyOwner{
       
        for (uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++){
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }

        funders = new address[](0);
        //transfer
        //payable(msg.sender).transfer(address(this).balance);
        //send
        //bool sendSuccess = payable(msg.sender).send(address(this).balance);
        //require(sendSuccess, "Send fail");
        //call
        (bool callSuccess, ) = payable(msg.sender).call{value:address(this).balance}("");
        require(callSuccess, "call failed");
    }
    
    function getVersion() public view returns(uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(s_priceFeed);
        return priceFeed.version();
    }

    modifier onlyOwner(){
        if(msg.sender != i_owner) { revert FundMe__NotOwner();}
         //require(msg.sender == i_owner,"Only owner can withdraw!");
         _; //runs the following code
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }
}
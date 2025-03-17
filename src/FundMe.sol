// SPDX-License-Identifier:MIT

pragma solidity ^0.8.28;


import {PriceConverter} from "./PriceConverter.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

error FundMe__NotOwner();

contract FundMe {
    using PriceConverter for uint256;
    
    address private immutable i_owner;
    uint256 public constant MINIMUM_USD = 5e18;
    
    AggregatorV3Interface private s_priceFeed;
    address[] private s_funders;
    mapping (address funder => uint256 amountFunded) private s_addressToAmountFunded;

    constructor(address priceFeed){
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeed);
    }

    // take a look at chainlink functions 
    function fund () payable public {
        require(msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD, "didn't send enoght eth");
        s_funders.push(msg.sender);
        s_addressToAmountFunded[msg.sender] += msg.value;
        // revert transaction if condition not true
    }

    function cheaperWithdraw() public onlyOwner {
        uint256 fundersLength = s_funders.length;

        for(uint256 funderIndex =0; funderIndex < fundersLength; funderIndex++){
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);
        (bool callSuccess, ) = payable(msg.sender).call{value:address(this).balance}("");
        require(callSuccess, "call failed");

    }

    function withdraw() public onlyOwner{
       
        for (uint256 funderIndex = 0; funderIndex < s_funders.length; funderIndex++){
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }

        s_funders = new address[](0);
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

    /** Getter Functions */

    function getAddressToAmountFunded(address fundingAddress) public view returns (uint256) {
        return s_addressToAmountFunded[fundingAddress];
    }

    function getFunder(uint256 index) public view returns (address) {
        return s_funders[index];
    }

    function getOwner() public view returns(address) {
        return i_owner;
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.28;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

library PriceConverter {

   function getPrice(AggregatorV3Interface priceFeed) internal view returns(uint256){
        // address 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        // ABI 
        (,int256 price,,,) = priceFeed.latestRoundData();
        // Price at ETH in terms of USD
        // 2000.00000000
        return uint256 (price * 1e10);
    }
    function getConversionRate(uint256 ethAmount, AggregatorV3Interface priceFeed) internal view returns(uint256) {
        uint256 ethPrice = getPrice(priceFeed);
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1e18;
        return ethAmountInUsd;
    }

}
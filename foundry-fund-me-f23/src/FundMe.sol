// SPDX-License-Identifier: Unlicensed

//Get Funds from users
//Withdraw funds
//Set a minimum funding value in USD

pragma solidity ^0.8.26;

//import {AggregatorV3Interface} from "lib/chainlink-brownie-contracts/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

import {AggregatorV3Interface, PriceConverter} from "src/PriceConverter.sol";

contract FundMe {
    error FundMe_NotOwner(); // initialised an error just to call it using an if/else instead of sending strings on revert message everytime

    using PriceConverter for uint256;
    AggregatorV3Interface private s_priceFeed;

    uint256 public constant minimumUsd = 5e18;

    address[] private s_funders;

    mapping(address => uint256) private s_addressToAmountFunded;

    address private immutable owner;

    constructor(address priceFeed) {
        s_priceFeed = AggregatorV3Interface(priceFeed);
        owner = msg.sender; //owner will automatically be the deployer of the contract
    }

    function fund() public payable {
        //payable keyword gives it a red colour and specifies this transfers value/amount
        require(
            msg.value.getConversionRate(s_priceFeed) >= minimumUsd,
            "didn't receive specified amount"
        ); //require function checks the first value in bool if its false it gives the second argument as a failure response
        //any text written over the require function is reverted if the require function fails.
        s_funders.push(msg.sender);
        s_addressToAmountFunded[msg.sender] += msg.value;
    }

    function withdraw() public onlyOwner {
        for (
            /*starting index,termination condition, step amount*/ uint256 funderIndex;
            funderIndex < s_funders.length;
            funderIndex++
        ) {
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);

        //transfer capped at 2300 gas and if fails returns an error
        //msg.sender is of type address whereas payable(msg.sender) is of type payable address
        // payable(msg.sender.transfer(address(this).balance));

        //send transfer capped at 2300 gas and if fails returns a boolean
        // bool sendSuccess = msg.sender.send(address(this).balance);
        // require(sendSuccess,"Send Failed");

        //call forward all gas or set gas, returns bool
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuccess, "Call Failed");
    }

    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert FundMe_NotOwner();
        }
        //require(msg.sender == owner,"Sender of request isn't the owner!");
        _; //this just means that you can add anything in the function after this, had this been above it would check the condition in the end and execute everything first
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }

    /*
    View/Pure functions  
    */

    function getAddressToAmountFunded(
        address fundingAddress
    ) external view returns (uint256) {
        return s_addressToAmountFunded[fundingAddress];
    }

    function getFunder(uint256 index) external view returns (address) {
        return s_funders[index];
    }

    function getOwner() external view returns (address) {
        return owner;
    }
}

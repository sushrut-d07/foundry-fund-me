//SPDX-License-Identifier:Unlicensed

pragma solidity ^0.8.26;

import {Test, console} from "../lib/forge-std/src/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    uint256 send_amount = 0.1 ether;

    function setUp() external {
        // fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
    }

    modifier funded() {
        fundMe.fund{value: send_amount}();
        _;
    }

    function testMinimumDollarIsFive() public view {
        assertEq(fundMe.minimumUsd(), 5e18);
    }

    function testOwnderIsSender() public view {
        // a test needs to start with test to be inclued in forge test by solidity
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testFundFailsWithoutEnoughEth() public {
        vm.expectRevert(); //This means that the next line should revert, if it doesnt revert the whole test fails
        fundMe.fund();
    }

    function testFundUpdatesFundedDataStructure() public funded {
        uint256 amountFunded = fundMe.getAddressToAmountFunded(address(this));
        assertEq(amountFunded, send_amount);
    }

    function testAddsFunderToArrayOfFunders() public funded {
        address sender = fundMe.getFunder(0);
        assertEq(sender, address(this));
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testWithdrawIsWorkingWithOwner() public funded {
        // Arrange
        address owner = fundMe.getOwner();
        uint256 startingOwnerBalance = owner.balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Act
        vm.prank(owner); // Make the owner the caller
        fundMe.withdraw();

        // Assert
        uint256 endingOwnerBalance = owner.balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        assertEq(
            startingOwnerBalance + startingFundMeBalance,
            endingOwnerBalance
        );
        assertEq(endingFundMeBalance, 0); // Ensure the FundMe balance is now zero
    }
}

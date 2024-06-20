// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    
    FundMe fundMe;
    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;
    //This function run first and then starts doing the other function (tests)
    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE);
        

    }

    function testMinimumDollarIsFive() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
        console.log(fundMe.MINIMUM_USD());
    }

    function testOwnerIsMsgSender() public view {
        assertEq(fundMe.getOwner(), msg.sender);
        console.log(fundMe.getOwner());
        console.log(msg.sender);
    }

    function testPriceFeedVersionIsAccurate() public view {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
        console.log(version);
    }

    function testFundFailsWithoutEnoughETH() public {
        vm.expectRevert(); // The next line should revert
        fundMe.fund(); //sending 0 value
    }

    function testFundUpdatesFundedDataStructure() public {
        vm.prank(USER); // The next will be sent by USER
        fundMe.fund{value: SEND_VALUE}();
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    modifier sendValue {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }
    
    function testArrayFundersIsAdding() public sendValue {
        assertEq(fundMe.getFunders(0), USER);
    }

    function testWithdrawBalanceByNotOwner() public sendValue {
        vm.prank(USER);
        vm.expectRevert();
        fundMe.withdraw();
        
    }

    function testWithdrawBalanceByOwner() public sendValue {
        uint256 startingBalanceFromOwner = fundMe.getOwner().balance;
        uint256 startingBalanceFromFundMe = address(fundMe).balance;

        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        uint256 endingBalanceFromOwner = fundMe.getOwner().balance;
        uint256 endingBalancefromFundMe = address(fundMe).balance;
        assertEq(endingBalancefromFundMe, 0);
        assertEq(startingBalanceFromFundMe + startingBalanceFromOwner, endingBalanceFromOwner);
    }

    function testWithdrawFromMultipleFunders() public sendValue {
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // We can calculate the gas spent in this transaction withdraw() Code:
        //uint256 public constant GAS_PRICE = 1 --> This should be on the top under de contract declaration
        // uint256 gasStart = gasLeft();
        //vm.txGasPrice(GAS_PRICE)
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();
        // uint256 gasEnd = gasLeft();
        // uint256 gasUsed = gasStart - gasEnd;
        // console.log(gasUsed);

        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        assertEq(endingFundMeBalance, 0);
        assertEq(endingOwnerBalance, startingOwnerBalance + startingFundMeBalance);



    }

    function testWithdrawFromMultipleFundersCheaper() public sendValue {
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // We can calculate the gas spent in this transaction withdraw() Code:
        //uint256 public constant GAS_PRICE = 1 --> This should be on the top under de contract declaration
        // uint256 gasStart = gasLeft();
        //vm.txGasPrice(GAS_PRICE)
        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        vm.stopPrank();
        // uint256 gasEnd = gasLeft();
        // uint256 gasUsed = gasStart - gasEnd;
        // console.log(gasUsed);

        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        assertEq(endingFundMeBalance, 0);
        assertEq(endingOwnerBalance, startingOwnerBalance + startingFundMeBalance);



    }
}
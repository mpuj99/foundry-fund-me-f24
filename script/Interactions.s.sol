// SPDX-License-Identifier: MIT
//We are going to make a fund script and withdraw script

pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
// import the most recent contract
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundFundMe is Script {
    uint256 constant SEND_VALUE = 0.01 ether;

     function fundFundMe(address mostrecentlyDeployed) public {
        vm.startBroadcast();
        FundMe(payable(mostrecentlyDeployed)).fund{value: SEND_VALUE}();
        vm.stopBroadcast();
        console.log("Funded FundMe with %s", SEND_VALUE);
     }
    
    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
        fundFundMe(mostRecentlyDeployed);
    }
}

contract WithdrawFundMe is Script {

     function withdrawFundMe(address mostrecentlyDeployed) public {
        vm.startBroadcast();
        FundMe(payable(mostrecentlyDeployed)).withdraw();
        vm.stopBroadcast();
     }
    
    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
        withdrawFundMe(mostRecentlyDeployed);
    }
}
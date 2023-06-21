// SPDX-License_Indentifier:MIT

pragma solidity 0.8.19;

import {Script} from "forge-std/Script.sol";
import {DevOpsTools} from "../lib/foundry-devops/src/DevOpsTools.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundFundMe is Script{

    uint256 constant SEND_VALUE = 0.1 ether;

   
    function fundFundMe(address mostRecentlyDeployed ) public {
        vm.startBroadcast();
       FundMe(payable (mostRecentlyDeployed)).fund{value: SEND_VALUE}();
       vm.stopBroadcast();
    }




    function run() external{

        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
        vm.broadcast();
        fundFundMe(mostRecentlyDeployed);
        vm.stopBroadcast();
    }
}


contract WithdrawFundMe is Script{
    function withdrawFundMe(address mostRecentlyDeployed ) public {
        vm.startBroadcast();
        FundMe(payable (mostRecentlyDeployed)).withdraw();
        vm.stopBroadcast();
    }




    function run() external{

        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
        vm.broadcast();
        WithdrawFundMe(mostRecentlyDeployed);
        vm.stopBroadcast();
    }

}
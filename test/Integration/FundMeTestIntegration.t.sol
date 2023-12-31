// SPDX-License-Identifier: MIT 

pragma solidity 0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interaction.s.sol";


contract InteractionsTest is Test{
    FundMe fundme;
   address USER = makeAddr("user");
   uint256 constant SEND_VALUE = 0.1 ether;
   uint256 constant STARING_BALANCE = 10 ether;
   uint256 constant GAS_PRICE = 1;

   
    function setUp() external{
        //  fundme = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deployFundMe = new DeployFundMe();
        fundme = deployFundMe.run(); 
        vm.deal(USER, STARING_BALANCE);
    }

    function testUserCanFundInteractions() public{
        FundFundMe fundFundMe = new FundFundMe();
        fundFundMe.fundFundMe(address(fundme));

        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundme));

        assert(address(fundme).balance == 0);

     

    }


}
// SPDX-License-Identifier: MIT 

pragma solidity 0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";


contract FundMeTest is Test{
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

    function testMinDollarIsFive() public {
       assertEq(fundme.MINIMUM_USD(), 5E18);
    }

    function testOwnerIsMsgSender() public{
        console.log(fundme.getOwner());
        console.log(msg.sender);
        assertEq(fundme.getOwner(), msg.sender );
    }

    function testPriceFeedVersionIsAccurate() public{
        uint256 version = fundme.getVersion();
        assertEq(version, 4);
    }

    function testFundFailWithoutEnoughEth() public{
        vm.expectRevert();
        fundme.fund();
    }

    function testFundUpdatesFundedDataStructure() public{
        vm.prank(USER);//user us senduing tge contract
        fundme.fund{value: SEND_VALUE}();
        uint256 amountFunded = fundme.getAddressToamountfunded(USER);
        assertEq(amountFunded, SEND_VALUE);

    }

    function testAddsFunderToArrayOfFunders() public{
        vm.prank(USER);
        fundme.fund{value: SEND_VALUE}();
        address funder = fundme.getFunder(0);
        assertEq(funder, USER);
    }

    modifier funded(){
        vm.prank(USER);
        fundme.fund{value: SEND_VALUE}();
        _;
    }

    function testOnlyOwnerCanWithdraw() public funded{
         vm.expectRevert();
        vm.prank(USER);
        fundme.withdraw();
    }

    function testWithdrawWithASignlefunder() public funded{
        // arrange
        uint256 startingOwnerBalance = fundme.getOwner().balance;
        uint256 startingContractBalance = address(fundme).balance;
    
        // act
        vm.prank(fundme.getOwner());
        fundme.withdraw();
        // assert

        uint256 endingOwnerBalance = fundme.getOwner().balance;
        uint256 endingContractBalance = address(fundme).balance; 
        assertEq(endingContractBalance, 0 );
        assertEq(startingContractBalance+startingOwnerBalance,endingOwnerBalance);
    }

    function testWithdrawWithMultypleOwnersCheaper() public funded{
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;


        for(uint160 i = startingFunderIndex; i<numberOfFunders; i++){
            hoax(address(i), SEND_VALUE);
            fundme.fund{value: SEND_VALUE}();
        }
        // arrange
        uint256 startingContractBalance = address(fundme).balance; 
        uint256 startingOwnerBalance = fundme.getOwner().balance;
        //act
        vm.prank(fundme.getOwner());
        fundme.cheaperWithdraw();

        // assert
        assert(address(fundme).balance == 0);
        assert(startingContractBalance+startingOwnerBalance == fundme.getOwner().balance);
    }
     function testWithdrawWithMultypleOwners() public funded{
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;


        for(uint160 i = startingFunderIndex; i<numberOfFunders; i++){
            hoax(address(i), SEND_VALUE);
            fundme.fund{value: SEND_VALUE}();
        }
        // arrange
        uint256 startingContractBalance = address(fundme).balance; 
        uint256 startingOwnerBalance = fundme.getOwner().balance;
        //act
        vm.prank(fundme.getOwner());
        fundme.withdraw();

        // assert
        assert(address(fundme).balance == 0);
        assert(startingContractBalance+startingOwnerBalance == fundme.getOwner().balance);
    }

}
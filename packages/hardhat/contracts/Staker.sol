// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;  //Do not change the solidity version as it negativly impacts submission grading

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {

  ExampleExternalContract public exampleExternalContract;

  constructor(address exampleExternalContractAddress) {
      exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
  }

  uint256 public constant threshold = 1 ether;
  uint256 public deadline = block.timestamp + 30 seconds;
  bool public openForWithdraw = false;
  mapping ( address => uint256 ) public balances;
  event Stake(address, uint256);

// 1. Stake period
// 2. If threshold of ETH met === success state
// 3. If not, withdraw state where users can withdraw funds

// 1. Execute func that anyone can call after deadline
// 2. If threshold met by the deadline then exampleExternalContract.complete
// 3. If threshold not met by deadline then openForWithdraw bool should be true and users can use withdraw func
// 4. timeLeft() func returns how much time left

  modifier canWithdraw {
    require(openForWithdraw == true);
    _;
  }

  modifier timeUp {
    require(timeLeft() == 0);
    _;
  }

  function stake() public payable {
    balances[msg.sender] += msg.value;
    emit Stake(msg.sender, msg.value);
  }

  function execute() public timeUp {
    if (address(this).balance >= threshold) {
      exampleExternalContract.complete{value: address(this).balance}();
    } else {
      openForWithdraw = true;
    }
  }

  // function withdraw() public payable canWithdraw {
  //   msg.sender.transfer(msg.value);
  // }

  function timeLeft() view public returns (uint) {
    if (block.timestamp >= deadline) {
      return 0;
    }
    return deadline - block.timestamp;
  }

  receive() external payable {
    stake();
  }
}

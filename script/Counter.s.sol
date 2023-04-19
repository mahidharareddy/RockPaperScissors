// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import { HelloWorld } from 'src/HelloWorld.sol';
import { RockPaperScissors } from 'src/RockPaperScissors.sol';

contract ContractScript is Script {
    function setUp() public {}

    function run() public {
        vm.broadcast();
        // new HelloWorld("Hello from Foundry!");
        new RockPaperScissors();
    }
}

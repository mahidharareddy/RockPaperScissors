// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "src/RockPaperScissors.sol";

contract TestRockPaperScissors is Test {

  // Testing the registration of players
  function testRegister() public {
    RockPaperScissors game = new RockPaperScissors();

    // First player should be registered successfully
    uint result = game.register{value: 1e16}();
    emit log_uint(result);
    assertEq(result, 1, "Player A should be registered");

    // Second player should be registered successfully
    // uint result2 = game.register{value: 1e16+1}();
    // emit log_uint(result2);
    // assertEq(result2, 2, "Player B should be registered");
  }

  // Testing the registration of players with invalid bets
  function testInvalidBet() public {
    RockPaperScissors game = new RockPaperScissors();

    // Bet should be greater than minimum
    (bool success, ) = address(game).call{value: 1e15}(
      abi.encodeWithSignature("register()")
    );
    assertFalse(success, "Bet should be greater than minimum");

    // Second player bet should be greater than first player bet
    game.register{value: 1e16}();
    (success, ) = address(game).call{value: 1.5e16}(
      abi.encodeWithSignature("register()")
    );
    assertFalse(success, "Bet should be greater than first player's bet");
  }

//   // Testing that players can only register once
//   function testNotAlreadyRegistered() public {
//     RockPaperScissors game = new RockPaperScissors();

//     game.register{value: 1e16}();
//     (bool success, ) = address(game).call{value: 1e16}(
//       abi.encodeWithSignature("register()")
//     );
//     assert.isFalse(success, "Player should not be able to register twice");
//   }

//   // Testing the commitment of moves by registered players
//   function testPlay() public {
//     RockPaperScissors game = new RockPaperScissors();

//     // Players must be registered before making their moves
//     (bool success, ) = address(game).call(
//       abi.encodeWithSignature("play(bytes32)", bytes32(abi.encodePacked("rock")))
//     );
//     assert.isFalse(success, "Unregistered player should not be able to play");

//     game.register{value: 1e16}();
//     game.register{value: 1e16}();

//     // Players must submit their encrypted move in the commit phase
//     success = game.play{value: 1e16}(bytes32(abi.encodePacked("rock")));
//     assert.isTrue(success, "Player A should be able to commit their move");
//     (success, ) = address(game).call{value: 1e16}(
//       abi.encodeWithSignature("play(bytes32)", bytes32(abi.encodePacked("paper")))
//     );
//     assert.isTrue(success, "Player B should be able to commit their move");

//     // Players can't commit more than once
//     (success, ) = address(game).call(
//       abi.encodeWithSignature("play(bytes32)", bytes32(abi.encodePacked("scissors")))
//     );
//     assert.isFalse(success, "Player should not be able to play more than once");
//   }
}

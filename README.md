# Decentralized Rock Paper Scissors

## Contents

* [Description](#description)
* [Usage](#usage)
* [Implementation](#implementation)
    * [Registration Phase](#registration-phase)
    * [Commit Phase](#commit-phase)
    * [Reveal Phase](#reveal-phase)
    * [Result Phase](#result-phase)
    * [Helper Functions](#helper-functions)
* [How to run the project](#how-to-run-the-project)
* [Testing using Foundry](#testing-using-foundry)
* [Adversaries](#adversaries)
* [Future Work](#future-work) 

## Description
This smart contract implements Rock Paper Scissors game using Solidity. The front end application is built using React and this makes it easier for an end user to interact with the smart contract. The game follows the following sequence:
1. Players register and place a bet.
2. Each player plays their move and sends a hash of their move to the contract.
3. Once both the players played, they get to reveal their move which is compared with the previously sent hash. The contract verifies if the player's move is valid.
4. Once both the players revealed their move, the contract determines a winner and sends the bet amount to the player's account. In case of a draw, each player gets their share of the bet.
5. The game is designed in such a way that multiple 2-player games can take place simultaneously.

## Usage
1. The first step is to register the player. We use the `register()` function for this purpose. The bet amount must be greater than or equal to the minimum bet set for the game. Along with the bet value, we also check if there are two players in queue so they can start a game.
2. Commit a move by using the `play(bytes32)` function. This function expects a SHA256 hash for a given move. The moves are inputted as integers. Rock is inputted as 1, paper as 2 and scissor as 3. Since a given input always gives the same hash, this could lead to a vulnerability if the hash is known to the opponent. So, a salt is added to the integer in order to generate a randomized hash.
3. Once both the players have played their game, they can reveal their moves by using the `reveal(string memory)` function. The input given to this function is clear text. This is compared to the previously submitted hash. If both the values match, the contract marks the move as revealed and waits for the other player to reveal their move.
4. We use the `getOutcome()` function to conclude the game and the contract takes care of sending the bet amount to the winner. In case of a draw, the contract transfers the amounts back to the players.

## Implementation

### Registration Phase
A player can register using their wallet address. The React application provides a user-friendly way to interact with the smart contract. If the bet value is greater than the minimum bet set by the contract (currently 0.01 ETH), the player will be registered. 
Once a player is registered, the contract checks if there is another player waiting for an opponent. If this is the case, the contract maps both the players so they can start a game. Otherwise, the player will be put on hold until a new player joins. 
If no player shows up until 10 minutes of registration, the player gets back their bet amount from the contract.

### Commit Phase
When both the players are registered successfully, they can make a move. The `play()` function takes in a hash of the cleartext and stores it in the contract. In order to simplify this, we have used the SHA256 function in the front end to convert the cleartext that the user provides into a hash. This hash is then sent to the contract. Once a player makes a move, they can check if the opponent has played the game. If the opponent hasn't played the game for 10 minutes, the game is reset and the players get their deposit back. 
Two helper functions are used to support this usecase. The `bothPlayed()` function checks if both the players have played their game and returns a boolean value. The `checkTimeout()` function checks if the other player hasn't made a move within 10 minutes of the initial player's move and returns the deposit if that is the case.

### Reveal Phase


### Result Phase

### Helper Functions


## How to run the project

## Testing using Foundry


## Adversaries

## Future Work



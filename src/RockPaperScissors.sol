// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;
import "forge-std/Test.sol";

contract RockPaperScissors {

    uint constant public BET_MIN        = 1e16;        // The minimum bet (1 finney)
    uint constant public REVEAL_TIMEOUT = 10 minutes;  // Max delay of revelation phase
    uint256 public registerOutputValue;
    uint256 public PlayOutputValue;
    uint public initialBet;                            // Bet of first player
    uint private firstReveal;                          // Moment of first reveal

    enum Moves {None, Rock, Paper, Scissors}
    enum Outcomes {None, PlayerA, PlayerB, Draw}   // Possible outcomes
    Moves public RevealOutputValue;
    Outcomes public outcome1;

    // Players' addresses
    address payable playerA;
    address payable playerB;

    // Encrypted moves
    bytes32 private encrMovePlayerA;
    bytes32 private encrMovePlayerB;

    // Clear moves set only after both players have committed their encrypted moves
    Moves private movePlayerA;
    Moves private movePlayerB;

    /**************************************************************************/
    /*************************** REGISTRATION PHASE ***************************/
    /**************************************************************************/

    // Bet must be greater than a minimum amount and greater than bet of first player
    modifier validBet() {
        console.log("value, betmin",msg.value, BET_MIN);
        require(msg.value >= BET_MIN);
        require(initialBet == 0 || msg.value >= initialBet);
        _;
    }

    modifier notAlreadyRegistered() {
        console.log(msg.sender);

        require(msg.sender != playerA && msg.sender != playerB);
        _;
    }

    // Register a player.
    // Return player's ID upon successful registration.
    function register() public payable validBet notAlreadyRegistered returns (uint) {
        // console.log("hello");
        if (playerA == address(0x0)) {
            console.log(playerA);
            // console.log(playerB);
            console.log(msg.sender);
            // console.log(msg.value);
            // emit log(playerA);
            playerA    = payable(msg.sender);
            initialBet = msg.value;
            console.log(playerA);
            registerOutputValue = 1;
            return 1;
        } else if (playerB == address(0x0)) {
            // console.log(playerA);
            console.log("playerB:",playerB);
            // console.log(msg.sender);
            playerB = payable(msg.sender);
            registerOutputValue = 2;
            return 2;
        }
        registerOutputValue = 0;
        return 0;
    }

    function getRegisterValue() public view returns (uint256){
        return registerOutputValue;
    }

    /**************************************************************************/
    /****************************** COMMIT PHASE ******************************/
    /**************************************************************************/

    modifier isRegistered() {
        require (msg.sender == playerA || msg.sender == playerB);
        _;
    }

    // Save player's encrypted move.
    // Return 'true' if move was valid, 'false' otherwise.
    function play(bytes32 encrMove) public isRegistered returns (bool) {
        if (msg.sender == playerA && encrMovePlayerA == 0x0) {
            encrMovePlayerA = encrMove;
        } else if (msg.sender == playerB && encrMovePlayerB == 0x0) {
            encrMovePlayerB = encrMove;
        } else {
            PlayOutputValue = 0;
            return false;
        }
        PlayOutputValue = 1;
        return true;
    }

    function getPlayOutput() public view returns (uint256){
        return PlayOutputValue;
    }

    /**************************************************************************/
    /****************************** REVEAL PHASE ******************************/
    /**************************************************************************/

    modifier commitPhaseEnded() {
        require(encrMovePlayerA != 0x0 && encrMovePlayerB != 0x0);
        _;
    }

    // Compare clear move given by the player with saved encrypted move.
    // Return clear move upon success, 'Moves.None' otherwise.
    function reveal(string memory clearMove) public isRegistered commitPhaseEnded returns (Moves) {
        bytes32 encrMove = sha256(abi.encodePacked(clearMove));  // Hash of clear input (= "move-password")
        Moves move       = Moves(getFirstChar(clearMove));       // Actual move (Rock / Paper / Scissors)

        // If move invalid, exit
        if (move == Moves.None) {
            return Moves.None;
        }

        // If hashes match, clear move is saved
        if (msg.sender == playerA && encrMove == encrMovePlayerA) {
            movePlayerA = move;
        } else if (msg.sender == playerB && encrMove == encrMovePlayerB) {
            movePlayerB = move;
        } else {
            RevealOutputValue = Moves.None;
            return Moves.None;
        }

        // Timer starts after first revelation from one of the player
        if (firstReveal == 0) {
            firstReveal = block.timestamp;
        }
        RevealOutputValue = move;
        return move;
    }

    function getRevealOutput() public view returns (Moves){
        return RevealOutputValue;
    }


    // Return first character of a given string.
    function getFirstChar(string memory str) private pure returns (uint) {
        bytes1 firstByte = bytes(str)[0];
        if (firstByte == 0x31) {
            return 1;
        } else if (firstByte == 0x32) {
            return 2;
        } else if (firstByte == 0x33) {
            return 3;
        } else {
            return 0;
        }
    }

    /**************************************************************************/
    /****************************** RESULT PHASE ******************************/
    /**************************************************************************/

    modifier revealPhaseEnded() {
        require((movePlayerA != Moves.None && movePlayerB != Moves.None) ||
                (firstReveal != 0 && block.timestamp > firstReveal + REVEAL_TIMEOUT));
        _;
    }

    // Compute the outcome and pay the winner(s).
    // Return the outcome.
    function getOutcome_() public view returns (Outcomes) {
        return outcome1;
    }

    function getOutcome() public revealPhaseEnded returns (Outcomes) {

        Outcomes outcome;
        if (movePlayerA == movePlayerB) {
            outcome = Outcomes.Draw;
            outcome1 = Outcomes.Draw;
        } else if ((movePlayerA == Moves.Rock     && movePlayerB == Moves.Scissors) ||
                   (movePlayerA == Moves.Paper    && movePlayerB == Moves.Rock)     ||
                   (movePlayerA == Moves.Scissors && movePlayerB == Moves.Paper)    ||
                   (movePlayerA != Moves.None     && movePlayerB == Moves.None)) {
            outcome = Outcomes.PlayerA;
            outcome1 = Outcomes.PlayerA;
        } else {
            outcome = Outcomes.PlayerB;
            outcome1 = Outcomes.PlayerB;
        }

        address payable addrA = playerA;
        address payable addrB = playerB;
        uint betPlayerA       = initialBet;
        reset();  // Reset game before paying to avoid reentrancy attacks
        pay(addrA, addrB, betPlayerA, outcome);

        return outcome;
    }

    function reset_() public returns (bool) {
        address payable addrA = playerA;
        address payable addrB = playerB;
        uint betPlayerA = initialBet;
        initialBet      = 0;
        firstReveal     = 0;
        playerA         = payable(address(0x0));
        playerB         = payable(address(0x0));
        encrMovePlayerA = 0x0;
        encrMovePlayerB = 0x0;
        movePlayerA     = Moves.None;
        movePlayerB     = Moves.None;
        addrA.transfer(betPlayerA);
        addrB.transfer(address(this).balance);
       return true;
    }


    // Pay the winner(s).
    function pay(address payable addrA, address payable addrB, uint betPlayerA, Outcomes outcome) private {
        // Uncomment lines below if you need to adjust the gas limit
        if (outcome == Outcomes.PlayerA) {
            addrA.transfer(address(this).balance);
            // addrA.call.value(address(this).balance).gas(1000000)("");
        } else if (outcome == Outcomes.PlayerB) {
            addrB.transfer(address(this).balance);
            // addrB.call.value(address(this).balance).gas(1000000)("");
        } else {
            addrA.transfer(betPlayerA);
            addrB.transfer(address(this).balance);
            // addrA.call.value(betPlayerA).gas(1000000)("");
            // addrB.call.value(address(this).balance).gas(1000000)("");
        }
    }

    // Reset the game.
    function reset() private {
        initialBet      = 0;
        firstReveal     = 0;
        playerA         = payable(address(0x0));
        playerB         = payable(address(0x0));
        encrMovePlayerA = 0x0;
        encrMovePlayerB = 0x0;
        movePlayerA     = Moves.None;
        movePlayerB     = Moves.None; 
    }

    /**************************************************************************/
    /**************************** HELPER FUNCTIONS ****************************/
    /**************************************************************************/

    // Return contract balance
    function getContractBalance() public view returns (uint) {
        return address(this).balance;
    }

    // Return player's ID
    function whoAmI() public view returns (uint) {
        // console.log(msg.address);
        if (msg.sender == playerA) {
            return 1;
        } else if (msg.sender == playerB) {
            return 2;
        } else {
            return 0;
        }
    }

    // Return 'true' if both players have commited a move, 'false' otherwise.
    function bothPlayed() public view returns (bool) {
        return (encrMovePlayerA != 0x0 && encrMovePlayerB != 0x0);
    }

    // Return 'true' if both players have revealed their move, 'false' otherwise.
    function bothRevealed() public view returns (bool) {
        return (movePlayerA != Moves.None && movePlayerB != Moves.None);
    }

    // Return time left before the end of the revelation phase.
    function revealTimeLeft() public view returns (int) {
        // console.log(block);
        if (firstReveal != 0) {
            // console.log("hello");
            return int((firstReveal + REVEAL_TIMEOUT) - block.timestamp);
        }
        return int(REVEAL_TIMEOUT);
    }
}

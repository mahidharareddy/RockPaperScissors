// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;
import "forge-std/Test.sol";
import "forge-std/console.sol";


contract RockPaperScissors {

    uint constant public BET_MIN        = 1e16;        // The minimum bet (1 finney)
    uint constant public REVEAL_TIMEOUT = 10 minutes;  // Max delay of revelation phase
    uint public initialBet;                            // Bet of first player
    uint private firstReveal;                          // Moment of first reveal

    // Players' addresses
    address payable playerA;
    address payable playerB;

    enum Moves {None, Rock, Paper, Scissors}
    enum Outcomes {None, PlayerA, PlayerB, Draw}   // Possible outcomes


    struct Player {
        address MyAddr;
        address OppAddr;
        uint bet;
        bytes32 encryptedMove;
        Moves movePlayer;
        //uint revealTimeRemaining;
    }

    // The list of players
    Player[] public listOfPlayers;

    // Encrypted moves
    bytes32 private encrMovePlayerA;
    bytes32 private encrMovePlayerB;

    // Clear moves set only after both players have committed their encrypted moves
    Moves private movePlayerA;
    Moves private movePlayerB;

    /**************************/
    /********* REGISTRATION PHASE *********/
    /**************************/

    // Bet must be greater than a minimum amount and greater than bet of first player
    modifier validBet() {
        //require(msg.value >= BET_MIN);
        
        if (listOfPlayers.length % 2 == 0)
        {
            //console.log("In the right one1");
            require(msg.value >= BET_MIN);
        }
        else
        {
            uint len = listOfPlayers.length;
            require(msg.value >= BET_MIN && msg.value >= listOfPlayers[len-1].bet);
        }
        
        _;
    }

    modifier notAlreadyRegistered() {
        //require(msg.value >= BET_MIN);
        uint len = listOfPlayers.length;
        if (len % 2 != 0){
        require(msg.sender != listOfPlayers[len-1].MyAddr);
        }
        
        _;
    }

    // Register a player.
    // Return player's ID upon successful registration.
    uint registerOutputValue;
    function register() public payable validBet notAlreadyRegistered returns (uint) {
        // if (playerA == address(0x0)) {
        //     playerA    = payable(msg.sender);
        //     initialBet = msg.value;
        //     return 1;
        // } else if (playerB == address(0x0)) {
        //     playerB = payable(msg.sender);
        //     return 2;
        // }
        //return 0;
        listOfPlayers.push(Player(msg.sender, address(0x0), msg.value, 0x0, Moves.None));
        console.log(listOfPlayers.length);
        //console.log(listOfPlayers[1]);

        if (listOfPlayers.length % 2 == 0)
        {
            uint len = listOfPlayers.length;
            listOfPlayers[len-2].OppAddr = msg.sender;
            listOfPlayers[len-1].OppAddr = listOfPlayers[len-2].MyAddr;
            //console.log(listOfPlayers[0].OppAddr);
            //console.log(listOfPlayers[0].MyAddr);
            //console.log(listOfPlayers[0].bet);
            registerOutputValue = 2;
            return 2;     
        }
        //console.log(listOfPlayers[0].OppAddr);
        //console.log(listOfPlayers[0].MyAddr);
        //console.log(listOfPlayers[0].bet);
        //console.log(listOfPlayers[0].encryptedMove);
        //console.log(listOfPlayers[0].movePlayer);
        registerOutputValue = 1;
        return 1;

    }

    function getRegisterValue() public view returns (string memory){
        if (registerOutputValue == 1)
        {
            return "Registration Successful. Wait for the opponent to join.";
        }
        else if (registerOutputValue == 2)
        {
            return "Registration successful. Play the game.";
        }
    }

    /**************************/
    /********** COMMIT PHASE **********/
    /**************************/

    function isRegistered() private view returns (uint) {
        //require (msg.sender == playerA || msg.sender == playerB);
        for (uint i = 0; i < listOfPlayers.length; i++) {
            // Get the struct at the current index
            Player memory myStruct = listOfPlayers[i];
            if (myStruct.MyAddr == msg.sender)
            {
                return i;
            }
        }
        return 10000;    
    }

    bool PlayOutputValue;
    // Save player's encrypted move.
    // Return 'true' if move was valid, 'false' otherwise.
    function play(bytes32 encrMove) public returns (bool) {
        uint returnVal = isRegistered();
        //console.log(returnVal);
        //console.log("got this return");
        if (returnVal != 10000)
        {
            if (listOfPlayers[returnVal].OppAddr != address(0x0) && listOfPlayers[returnVal].encryptedMove == 0x0)
            {
                //console.log("Inside play found returnVal too!");
                listOfPlayers[returnVal].encryptedMove = encrMove;
                //console.log(listOfPlayers[returnVal].encryptedMove);
                PlayOutputValue = true;
                return true;
            }
        }
        PlayOutputValue = false;
        return false;

        // if (msg.sender == playerA && encrMovePlayerA == 0x0) {
        //     encrMovePlayerA = encrMove;
        // } else if (msg.sender == playerB && encrMovePlayerB == 0x0) {
        //     encrMovePlayerB = encrMove;
        // } else {
        //     return false;
        // }
        // return true;

    }

    function getPlayOutput() public view returns (string memory){
        if (PlayOutputValue == true)
        {
            return "Successfully stored the move";
        }
        else
        {
            return "Failed to store the play move";
        }
    }
    
    /**************************/
    /********** REVEAL PHASE **********/
    /**************************/

    modifier commitPhaseEnded() {
        address personalAddress = address(0x0);
        address opponentAddress = address(0x0);
        bytes32 encryptedmove1 = 0x0;
        bytes32 encryptedmove2 = 0x0;
        for (uint i = 0; i < listOfPlayers.length; i++) {
            // Get the struct at the current index
            Player memory myStruct = listOfPlayers[i];
            if (myStruct.MyAddr == msg.sender)
            {
                personalAddress = listOfPlayers[i].MyAddr;
                opponentAddress = listOfPlayers[i].OppAddr;
                encryptedmove1 = listOfPlayers[i].encryptedMove;
                break;
            }
        }

        for (uint i = 0; i < listOfPlayers.length; i++) {
            Player memory myStruct = listOfPlayers[i];
            if (myStruct.MyAddr == opponentAddress)
            {
                encryptedmove2 = listOfPlayers[i].encryptedMove;
                break;
            }
        }

        require(encryptedmove1 != 0x0 && encryptedmove2 != 0x0);
        _;
    }

    Moves RevealOutputValue;
    // Compare clear move given by the player with saved encrypted move.
    // Return clear move upon success, 'Moves.None' otherwise.
    function reveal(string memory clearMove) public commitPhaseEnded returns (Moves) {

        uint returnVal = isRegistered();
        if (returnVal != 10000)
        {
            bytes32 encrMove_inReveal = sha256(abi.encodePacked(clearMove));  // Hash of clear input (= "move-password")
            Moves move = Moves(getFirstChar(clearMove));       // Actual move (Rock / Paper / Scissors)   

            if (move == Moves.None) {
                RevealOutputValue = Moves.None;
                return Moves.None;
            }

            for (uint i = 0; i < listOfPlayers.length; i++) {
                Player memory myStruct = listOfPlayers[i];
                if (myStruct.MyAddr == msg.sender)
                {
                    if (myStruct.encryptedMove == encrMove_inReveal)
                    {
                        listOfPlayers[i].movePlayer = move;
                        console.log("working in reveal-successful");
                        console.log(uint(move));
                    }
                    break;
                }
            }
            RevealOutputValue = move;
            return move;
        }  
        else{
            RevealOutputValue = Moves.None;
            return Moves.None;
        }  


        // bytes32 encrMove_inReveal = sha256(abi.encodePacked(clearMove));  // Hash of clear input (= "move-password")
        // Moves move       = Moves(getFirstChar(clearMove));       // Actual move (Rock / Paper / Scissors)

        // // If move invalid, exit
        // if (move == Moves.None) {
        //     return Moves.None;
        // }

        // // If hashes match, clear move is saved
        // if (msg.sender == playerA && encrMove_inReveal == encrMovePlayerA) {
        //     movePlayerA = move;
        // } else if (msg.sender == playerB && encrMove_inReveal == encrMovePlayerB) {
        //     movePlayerB = move;
        // } else {
        //     return Moves.None;
        // }

        // // Timer starts after first revelation from one of the player
        // if (firstReveal == 0) {
        //     firstReveal = block.timestamp;
        // }

        // return move;
    }

    function getRevealOutput() public view returns (string memory){
        if (uint(RevealOutputValue) == 0)
        {
            return "Invalid";
        }
        if (uint(RevealOutputValue) == 1)
        {
            return "Revealed: Rock";
        }
        if (uint(RevealOutputValue) == 2)
        {
            return "Revealed: Paper";
        }
        else{
            return "Revealed: Scissors";
        }        
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

    /**************************/
    /********** RESULT PHASE **********/
    /**************************/

    modifier revealPhaseEnded() {
        address personalAddress = address(0x0);
        address opponentAddress = address(0x0);
        Moves cleartextMove1 = Moves.None;
        Moves cleartextMove2 = Moves.None;
        for (uint i = 0; i < listOfPlayers.length; i++) {
            // Get the struct at the current index
            Player memory myStruct = listOfPlayers[i];
            if (myStruct.MyAddr == msg.sender)
            {
                personalAddress = myStruct.MyAddr;
                opponentAddress = myStruct.OppAddr;
                cleartextMove1 = myStruct.movePlayer;
                console.log(uint(cleartextMove1));
                break;
            }
        }
        for (uint i = 0; i < listOfPlayers.length; i++) {
            Player memory myStruct = listOfPlayers[i];
            if (myStruct.MyAddr == opponentAddress)
            {
                cleartextMove2 = myStruct.movePlayer;
                break;
            }
        } 
        require((cleartextMove1 != Moves.None && cleartextMove2 != Moves.None));
        //         (firstReveal != 0 && block.timestamp > firstReveal + REVEAL_TIMEOUT));
        _;
    }
    Outcomes FirstOutputValue;
    // Compute the outcome and pay the winner(s).
    // Return the outcome.
    function getOutcome() public revealPhaseEnded returns (Outcomes) {
        //console.log("RevealPhaseEnded modifier executed successfully");
        Moves Player1move = Moves.None;
        Moves Player2move = Moves.None;
        address payable myoutcomeaddress;
        address payable Opponentoutcomeaddress;
        uint index1;
        uint index2;
        //enum Outcomes {None, myoutcomeaddress, Opponentoutcomeaddress, Draw}
        Outcomes outcome;
        for (uint i = 0; i < listOfPlayers.length; i++) {
            // Get the struct at the current index
            Player memory myStruct = listOfPlayers[i];
            if (myStruct.MyAddr == msg.sender)
            {
                index1 = i;
                myoutcomeaddress = payable(myStruct.MyAddr);
                Opponentoutcomeaddress = payable(myStruct.OppAddr);
                Player1move = myStruct.movePlayer; 
                break;
            }
        }
        for (uint i = 0; i < listOfPlayers.length; i++) {
            // Get the struct at the current index
            Player memory myStruct = listOfPlayers[i];
            if (myStruct.MyAddr == Opponentoutcomeaddress)
            {
                index2 = i;
                Player2move = myStruct.movePlayer; 
                break;
            }
        }
        // console.log("P1 move");
        // console.log(uint(Player1move));
        // console.log("P2 move");
        // console.log(uint(Player2move));
        
        if (Player1move == Player2move)
        {
            outcome = Outcomes.Draw;
        }
        else if ((Player1move == Moves.Rock     && Player2move == Moves.Scissors) ||
                   (Player1move == Moves.Paper    && Player2move == Moves.Rock)     ||
                   (Player1move == Moves.Scissors && Player2move == Moves.Paper)    ||
                   (Player1move != Moves.None     && Player2move == Moves.None)) {
            outcome = Outcomes.PlayerA;
        } else {
            outcome = Outcomes.PlayerB;
        }


        // if (movePlayerA == movePlayerB) {
        //     outcome = Outcomes.Draw;
        // } else if ((movePlayerA == Moves.Rock     && movePlayerB == Moves.Scissors) ||
        //            (movePlayerA == Moves.Paper    && movePlayerB == Moves.Rock)     ||
        //            (movePlayerA == Moves.Scissors && movePlayerB == Moves.Paper)    ||
        //            (movePlayerA != Moves.None     && movePlayerB == Moves.None)) {
        //     outcome = Outcomes.PlayerA;
        // } else {
        //     outcome = Outcomes.PlayerB;
        // }

        address payable addrA = myoutcomeaddress;
        address payable addrB = Opponentoutcomeaddress;
        //uint betPlayerA       = listOfPlayers[index].bet;
        pay(addrA, addrB, index1, index2, outcome);
        reset();  // Reset game before paying to avoid reentrancy attacks
        //pay(addrA, addrB, betPlayerA, outcome);
        FirstOutputValue = outcome;
        return outcome;
    }

    function getFinalOutput() public view returns (string memory){
        if (uint(FirstOutputValue) == 0)
        {
            return "Invalid";
        }
        if (uint(FirstOutputValue) == 1)
        {
            return "Player 1 won";
        }
        if (uint(FirstOutputValue) == 2)
        {
            return "Player 2 won";
        }
        if (uint(FirstOutputValue) == 3)
        {
            return "Game Drawn";
        }                        
    }

    // Pay the winner(s).
    function pay(address payable addrA, address payable addrB, uint index1, uint index2, Outcomes outcome) private {
        if (outcome == Outcomes.PlayerA) {
            addrA.transfer(listOfPlayers[index1].bet + listOfPlayers[index2].bet);
        }
        else if (outcome == Outcomes.PlayerB) {
            addrB.transfer(listOfPlayers[index1].bet + listOfPlayers[index2].bet);
        }
        else{
            addrA.transfer(listOfPlayers[index1].bet);
            addrB.transfer(listOfPlayers[index2].bet);
        }
    }

    // function pay(address payable addrA, address payable addrB, uint betPlayerA, Outcomes outcome) private {
    //     // Uncomment lines below if you need to adjust the gas limit
    //     if (outcome == Outcomes.PlayerA) {
    //         addrA.transfer(address(this).balance);
    //         // addrA.call.value(address(this).balance).gas(1000000)("");
    //     } else if (outcome == Outcomes.PlayerB) {
    //         addrB.transfer(address(this).balance);
    //         // addrB.call.value(address(this).balance).gas(1000000)("");
    //     } else {
    //         addrA.transfer(betPlayerA);
    //         addrB.transfer(address(this).balance);
    //         // addrA.call.value(betPlayerA).gas(1000000)("");
    //         // addrB.call.value(address(this).balance).gas(1000000)("");
    //     }
    // }

    // Reset the game.
    function reset() private {
        uint index1;
        uint index2;
        address opponentresetaddress = address(0x0);
        for (uint i = 0; i < listOfPlayers.length;i++)
        {
            if (msg.sender == listOfPlayers[i].MyAddr)
            {
                opponentresetaddress = listOfPlayers[i].OppAddr;
                index1 = i;
                break;
            }
        }
        for (uint i = 0; i < listOfPlayers.length;i++)
        {
            if (opponentresetaddress == listOfPlayers[i].MyAddr)
            {
                index2 = i;
                break;
            }
        }
        delete listOfPlayers[index1];
        delete listOfPlayers[index2];
        // initialBet      = 0;
        // firstReveal     = 0;
        // playerA         = payable(address(0x0));
        // playerB         = payable(address(0x0));
        // encrMovePlayerA = 0x0;
        // encrMovePlayerB = 0x0;
        // movePlayerA     = Moves.None;
        // movePlayerB     = Moves.None;
    }

    /**************************/
    /********** HELPER FUNCTIONS **********/
    /**************************/

    // Return contract balance
    function getContractBalance() public view returns (uint) {
        uint bal = 0;
        address Opponentaddress = address(0x0);
        for (uint i = 0; i < listOfPlayers.length; i++) {
            // Get the struct at the current index
            Player memory myStruct = listOfPlayers[i];
            if (myStruct.MyAddr == msg.sender)
            {
                Opponentaddress = myStruct.OppAddr;
                bal += myStruct.bet;
            }
        } 
        if (Opponentaddress != address(0x0))
        {
            for (uint i = 0; i < listOfPlayers.length; i++) {
                // Get the struct at the current index
                Player memory myStruct = listOfPlayers[i];    
                if (myStruct.MyAddr == Opponentaddress)
                {
                    bal += myStruct.bet;
                }
        }
        }
        return bal;    
        //return address(this).balance;
    }

    // Return player's ID
    function whoAmI() public view returns (uint) {
        //console.log(listOfPlayers.length);
        for (uint i = 0; i < listOfPlayers.length; i++) {
            // Get the struct at the current index
            Player memory myStruct = listOfPlayers[i];
            if (msg.sender == myStruct.MyAddr)
            {
                return i;
            }
        }
        return 10000;
        // if (msg.sender == playerA) {
        //     return 1;
        // } else if (msg.sender == playerB) {
        //     return 2;
        // } else {
        //     return 0;
        // }
    }

    // Return 'true' if both players have commited a move, 'false' otherwise.
    function bothPlayed() public view returns (bool) {
        address Opponentaddress = address(0x0);
        bool flag = false;
        for (uint i = 0; i < listOfPlayers.length; i++) {

            // Get the struct at the current index
            Player memory myStruct = listOfPlayers[i];
            console.log(myStruct.MyAddr);
            console.log(myStruct.OppAddr);
            if (msg.sender == myStruct.MyAddr)
            {   
                flag = true;
                Opponentaddress = myStruct.OppAddr;
                if (myStruct.encryptedMove == 0x0)
                {
                    console.log("you didnt play1");
                    return false;
                }
            }
        }
        if (flag == false)
        {
            console.log("you didnt register2");
            return false;
        }
        bool flag1 = false;
        for (uint i = 0; i < listOfPlayers.length; i++) {
            // Get the struct at the current index
            Player memory myStruct = listOfPlayers[i];
            if (Opponentaddress == myStruct.MyAddr)
            {
                flag1 = true;
                if (myStruct.encryptedMove == 0x0)
                {
                    console.log("opponent didnt play3");
                    return false;
                }
            }
        }
        if (flag1 == false)
        {
            console.log("opponent didnt register4");
            return false;
        }
        console.log("Success5");
        return true;


        //return (encrMovePlayerA != 0x0 && encrMovePlayerB != 0x0);
    }

    // Return 'true' if both players have revealed their move, 'false' otherwise.
    function bothRevealed() public view returns (bool) {
        address Opponentaddress = address(0x0);
        bool flag = false;
        for (uint i = 0; i < listOfPlayers.length; i++) {

            // Get the struct at the current index
            Player memory myStruct = listOfPlayers[i];
            //console.log(myStruct.MyAddr);
            //console.log(myStruct.OppAddr);
            if (msg.sender == myStruct.MyAddr)
            {   
                flag = true;
                Opponentaddress = myStruct.OppAddr;
                if (myStruct.movePlayer == Moves.None)
                {
                    //console.log("you didnt play1");
                    return false;
                }
            }
        }
        if (flag == false)
        {
            console.log("you didnt register2");
            return false;
        }
        bool flag1 = false;
        for (uint i = 0; i < listOfPlayers.length; i++) {
            // Get the struct at the current index
            Player memory myStruct = listOfPlayers[i];
            if (Opponentaddress == myStruct.MyAddr)
            {
                flag1 = true;
                if (myStruct.movePlayer == Moves.None)
                {
                    //console.log("opponent didnt play3");
                    return false;
                }
            }
        }
        if (flag1 == false)
        {
            //console.log("opponent didnt register4");
            return false;
        }
        //console.log("Success5");
        return true;


        //return (movePlayerA != Moves.None && movePlayerB != Moves.None);
    }

    // Return time left before the end of the revelation phase.
    function revealTimeLeft() public view returns (int) {
        if (firstReveal != 0) {
            return int((firstReveal + REVEAL_TIMEOUT) - block.timestamp);
        }
        return int(REVEAL_TIMEOUT);
    }

    //check if the opponent joined
    function opponentJoined() public view returns (bool)
    {
        for (uint i = 0; i < listOfPlayers.length; i++)
        {
            if (listOfPlayers[i].MyAddr == msg.sender)
            {
                if (listOfPlayers[i].OppAddr != address(0x0))
                {
                    return true;
                }
            }    

        }
        return false;
    }
}
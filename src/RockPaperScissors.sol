// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;
import "forge-std/Test.sol";
import "forge-std/console.sol";


contract RockPaperScissors {

    uint constant public BET_MIN        = 1e16;        // The minimum bet (1 finney)
    uint constant public REVEAL_TIMEOUT = 10 minutes;  // Max delay of revelation phase
    uint public initialBet;                            // Bet of first player
    uint private firstReveal;                          // Moment of first reveal
    uint public timeout = 10 minutes; // change to 10 minutes
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
        uint timeout_register;
        uint timeout_play;
        uint timeout_reveal;

        //string check_timeout_register;
        //string check_timeout_play;
        //string check_timeout_reveal;
    }
    uint registerOutputValue;
    bool PlayOutputValue;
    Moves RevealOutputValue;
    string check_timeout_register;
    string check_timeout_play;
    string check_timeout_reveal;

    // The list of players
    Player[] public listOfPlayers;


    function getPlayerIndex(address addr) private view returns (uint)
    {
        for (uint i = 0; i < listOfPlayers.length; i++)
        {
            if (addr == listOfPlayers[i].MyAddr)
            {
                return i;
            }
        }
        return 10000;
    }

    /**************************/
    /********* REGISTRATION PHASE *********/
    /**************************/

    // Bet must be greater than a minimum amount and greater than bet of first player
    modifier validBet() {        
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
        uint len = listOfPlayers.length;
        if (len % 2 != 0){
        require(msg.sender != listOfPlayers[len-1].MyAddr);
        }
        
        _;
    }

    // Register a player.
    // Return player's ID upon successful registration.
    function register() public payable validBet notAlreadyRegistered returns (uint) {

        //console.log("Initial", getContractBalance());
        //listOfPlayers.push(Player(msg.sender, address(0x0), msg.value, 0x0, Moves.None,0,0,0,0,false,Moves.None, "", "", ""));
        listOfPlayers.push(Player(msg.sender, address(0x0), msg.value, 0x0, Moves.None,0,0,0));
        console.log(listOfPlayers.length);

        if (listOfPlayers.length % 2 == 0)
        {
            uint len = listOfPlayers.length;
            listOfPlayers[len-2].OppAddr = msg.sender;
            listOfPlayers[len-1].OppAddr = listOfPlayers[len-2].MyAddr;
            listOfPlayers[listOfPlayers.length - 1].timeout_register = block.timestamp;
            registerOutputValue = 2;
            return 2;     
        }
        listOfPlayers[listOfPlayers.length - 1].timeout_register = block.timestamp;
        //uint idx1 = getPlayerIndex(msg.sender);
        registerOutputValue = 1;
        return 1;

    }

    function getRegisterValue() public view returns (string memory){
        //uint i = getPlayerIndex(msg.sender);
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

    // Save player's encrypted move.
    // Return 'true' if move was valid, 'false' otherwise.
    function play(bytes32 encrMove) public returns (bool) {
        uint returnVal = getPlayerIndex(msg.sender);
        if (returnVal != 10000)
        {
            if (listOfPlayers[returnVal].OppAddr != address(0x0) && listOfPlayers[returnVal].encryptedMove == 0x0)
            {
                listOfPlayers[returnVal].encryptedMove = encrMove;
                PlayOutputValue = true;
                listOfPlayers[returnVal].timeout_play = block.timestamp;
                return true;
            }
            
        }
        PlayOutputValue = false;
        return false;

    }

    function getPlayOutput() public view returns (string memory){
        //uint returnVal = getPlayerIndex(msg.sender);
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
        uint idx = getPlayerIndex(msg.sender);
        if (idx != 10000){
            personalAddress = listOfPlayers[idx].MyAddr;
            opponentAddress = listOfPlayers[idx].OppAddr;
            encryptedmove1 = listOfPlayers[idx].encryptedMove;
        }
        uint idx2 = getPlayerIndex(opponentAddress);
        if (idx2 != 10000)
        {
            encryptedmove2 = listOfPlayers[idx2].encryptedMove;
        }
        require(encryptedmove1 != 0x0 && encryptedmove2 != 0x0);
        _;
    }

    
    // Compare clear move given by the player with saved encrypted move.
    // Return clear move upon success, 'Moves.None' otherwise.
    function reveal(string memory clearMove) public commitPhaseEnded returns (Moves) {

        uint returnVal = getPlayerIndex(msg.sender);
        if (returnVal != 10000)
        {

            bytes32 encrMove_inReveal = sha256(abi.encodePacked(clearMove));  // Hash of clear input (= "move-password")
            Moves move = Moves(getFirstChar(clearMove));       // Actual move (Rock / Paper / Scissors)   
            listOfPlayers[returnVal].timeout_reveal = block.timestamp;
            //uint opprevealidx = getPlayerIndex(listOfPlayers[returnVal].OppAddr);

            if (move == Moves.None) {
                RevealOutputValue = Moves.None;
                return Moves.None;
            }
            
            if (listOfPlayers[returnVal].encryptedMove == encrMove_inReveal)
            {
                listOfPlayers[returnVal].movePlayer = move;
                console.log("working in reveal-successful");
                console.log(uint(move));
                RevealOutputValue = move;
                return move;
            }
        } 
        else{
            //listOfPlayers[returnVal].RevealOutputValue = Moves.None;
            return Moves.None;
        }  

    }

    function getRevealOutput() public view returns (string memory){
        //uint returnVal = getPlayerIndex(msg.sender);
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
        uint idx1 = getPlayerIndex(msg.sender);

        if (idx1 != 10000){
            personalAddress = listOfPlayers[idx1].MyAddr;
            opponentAddress = listOfPlayers[idx1].OppAddr;
            cleartextMove1 = listOfPlayers[idx1].movePlayer;
            console.log(uint(cleartextMove1));
        }
        uint idx2 = getPlayerIndex(opponentAddress);    
        if (idx2 != 10000)
        {
            cleartextMove2 = listOfPlayers[idx2].movePlayer;
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
        //enum Outcomes {None, myoutcomeaddress, Opponentoutcomeaddress, Draw}
        Outcomes outcome;
        uint index1 = getPlayerIndex(msg.sender);
        myoutcomeaddress = payable(listOfPlayers[index1].MyAddr);
        Opponentoutcomeaddress = payable(listOfPlayers[index1].OppAddr);
        Player1move = listOfPlayers[index1].movePlayer; 
        
        uint index2 = getPlayerIndex(Opponentoutcomeaddress);
        Player2move = listOfPlayers[index2].movePlayer; 

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



        address payable addrA = myoutcomeaddress;
        address payable addrB = Opponentoutcomeaddress;
        pay(addrA, addrB, index1, index2, outcome);
        reset();  // Reset game before paying to avoid reentrancy attacks
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


    // Reset the game.
    function reset() private {
        address opponentresetaddress = address(0x0);
        uint index1 = getPlayerIndex(msg.sender);
        opponentresetaddress = listOfPlayers[index1].OppAddr;
        if (opponentresetaddress != address(0x0))
        {
            uint index2 = getPlayerIndex(opponentresetaddress);
            delete listOfPlayers[index1];
            delete listOfPlayers[index2];
        }
        else{
            delete listOfPlayers[index1];
        }

    }
    /**************************/
    /********** HELPER FUNCTIONS **********/
    /**************************/

    // Return contract balance
    function getContractBalance() public view returns (uint) {
        uint bal = 0;
        address Opponentaddress = address(0x0);
        uint index = getPlayerIndex(msg.sender);
        if (index != 10000)
        {
            Opponentaddress = listOfPlayers[index].OppAddr;
            bal += listOfPlayers[index].bet;
        }
        if (Opponentaddress != address(0x0))
        {
            uint index2 = getPlayerIndex(Opponentaddress);
            if (index2 != 10000){
                bal += listOfPlayers[index2].bet;
            }
        }
        return bal;    
    }

    // Return player's ID
    function whoAmI() public view returns (uint) {
        return getPlayerIndex(msg.sender);
    }

    // Return 'true' if both players have commited a move, 'false' otherwise.
    function bothPlayed() public view returns (bool) {
        address Opponentaddress = address(0x0);
        uint index = getPlayerIndex(msg.sender);
        if (index != 10000)
        {
            Opponentaddress = listOfPlayers[index].OppAddr;
            if (listOfPlayers[index].encryptedMove == 0x0)
            {
                console.log("you didnt play");
                return false;
            }
        }
        else{
            console.log("you didnt register");
            return false;
        }

        uint index2 = getPlayerIndex(Opponentaddress);
        if (index2 != 10000){
            if (listOfPlayers[index2].encryptedMove == 0x0)
            {
                console.log("opponent didnt play");
                return false;
            }
        }
        else
        {
            console.log("opponent didnt register");
            return false;
        }
        console.log("Success");
        return true;
    }

    // Return 'true' if both players have revealed their move, 'false' otherwise.
    function bothRevealed() public view returns (bool) {
        address Opponentaddress = address(0x0);
        uint index = getPlayerIndex(msg.sender);
        if (index != 10000)
        {
            Opponentaddress = listOfPlayers[index].OppAddr;
            if (listOfPlayers[index].movePlayer == Moves.None)
            {
                //console.log("you didnt play");
                return false;
            }
        }

        else {
            console.log("you didnt register");
            return false;
        }

        uint index2 = getPlayerIndex(Opponentaddress);
        if (index2 != 10000){
            if (listOfPlayers[index2].movePlayer == Moves.None)
            {
                //console.log("opponent didnt play");
                return false;
            }
        }
        else
        {
            //console.log("opponent didnt register4");
            return false;
        }
        //console.log("Success5");
        return true;
    }

    //check if the opponent joined
    function opponentJoined() public view returns (bool)
    {
        uint index = getPlayerIndex(msg.sender);
        if (index != 10000){
            if (listOfPlayers[index].OppAddr != address(0x0))
            {
                return true;
            }
        }
        return false;
    }


    function checkTimeout_register() public 
    {
        uint myregistertime;
        uint oppregistertime;
        address oppAdr = address(0x0);
        uint index1 = getPlayerIndex(msg.sender);
        if (index1 != 10000)
        {
            myregistertime = listOfPlayers[index1].timeout_register;
            oppAdr = listOfPlayers[index1].OppAddr;
        }
        else{
            check_timeout_register = "Register your game";
            return;
        }
        if (myregistertime == 0)
        {
            check_timeout_register = "Register your game";
            return;
        }
        if (oppAdr != address(0x0))
        {
            uint index2 = getPlayerIndex(oppAdr);
            oppregistertime = listOfPlayers[index2].timeout_register;
            if (listOfPlayers[index1].bet != 0 && listOfPlayers[index2].bet != 0)
            {
                check_timeout_register = "Register Phase Done, Proceed with the next one!";
                return;
            }
            else if (oppregistertime - myregistertime > timeout || myregistertime - oppregistertime > timeout) // change this to timeout
            {
                address payable addrA;
                address payable addrB;
                addrA = payable(listOfPlayers[index1].MyAddr);
                addrB = payable(listOfPlayers[index2].MyAddr);
                addrA.transfer(listOfPlayers[index1].bet);
                addrB.transfer(listOfPlayers[index2].bet);
                reset();
                check_timeout_register = "Timeout - returned the balances to your account";
                return;
            }
            else if (listOfPlayers[index1].encryptedMove != 0x0)
            {
                check_timeout_register = "Register Phase Done, Proceed with the next one!";
                return;
            }
            else
            {
                check_timeout_register = "Hold on! There's time left";
                return;
            }
        }
        else {
            if (block.timestamp - myregistertime > timeout) //change this to timeout
            {
                address payable addrA;
                addrA = payable(listOfPlayers[index1].MyAddr);
                console.log(listOfPlayers[index1].MyAddr);
                console.log("Before", getContractBalance());
                console.log(addrA);
                //addrA.transfer(listOfPlayers[index1].bet);
                refund(addrA, listOfPlayers[index1].bet);
                console.log("After", getContractBalance());
                console.log("Returned money");
                reset();
                check_timeout_register = "Timed out, no opponent matched. Returing your deposit.";
            }
            else {
                //string memory st= uint2str(block.timestamp);
                console.log("Block timestamp is ");
                console.log(block.timestamp);
                console.log("Time during registration is");
                console.log(myregistertime);

                check_timeout_register = "Hold on! There's Time left";
            }
            
        }

    }
    function checkTimeout_register_fe() public view returns (string memory){
        return check_timeout_register;
    }    

    function refund(address payable addrA, uint value) private
    {
        addrA.transfer(value);
    }

    function checkTimeout_play() public
    {
        uint myplaytime;
        uint oppplaytime;
        address oppAdr = address(0x0);
        uint index1 = getPlayerIndex(msg.sender);
        if (index1 != 10000)
        {
            myplaytime = listOfPlayers[index1].timeout_play;
            oppAdr = listOfPlayers[index1].OppAddr;
        }
        else{
            check_timeout_play = "Register your game";
            return;
        } 
        if (myplaytime == 0)
        {
            check_timeout_play = "Play the game";
            return;
        }
        uint index2 = getPlayerIndex(oppAdr);
        if (oppAdr != address(0x0) && listOfPlayers[index2].timeout_play != 0)
        {
            oppplaytime = listOfPlayers[index2].timeout_play;
            if (listOfPlayers[index1].encryptedMove != 0x0 && listOfPlayers[index2].encryptedMove != 0x0)
            {
                check_timeout_play = "Play phase done, proceed to the reveal phase!";
                return;

            }
            else if (oppplaytime - myplaytime > timeout || myplaytime - oppplaytime > timeout) // change this to timeout
            {
                address payable addrA;
                address payable addrB;
                addrA = payable(listOfPlayers[index1].MyAddr);
                addrB = payable(listOfPlayers[index2].MyAddr);
                addrA.transfer(listOfPlayers[index1].bet);
                addrB.transfer(listOfPlayers[index2].bet);
                reset();
                check_timeout_play = "Timeout - returned the balances to your account";
                return;
            }  
            else if(listOfPlayers[index1].movePlayer != Moves.None)
            {
                check_timeout_play = "Play Phase Done, Proceed with the next one!";
                return;
            }  
            else
            {
                check_timeout_play = "Hold on! There's time left";
                return;
            }   

        }
        else
        {
            console.log("In else part");
            if (block.timestamp - myplaytime > timeout) //change this to timeout
            {
                address payable addrA = payable(msg.sender);
                uint idx1 = getPlayerIndex(msg.sender);
                refund(addrA, listOfPlayers[idx1].bet);
                reset();
                check_timeout_play = "Timed out, no opponent matched. Returing your deposit.";
            }
            else{
                check_timeout_play = "Hold on! There's Time left";
            }
        }

    }
    function checkTimeout_play_fe() public view returns (string memory){
        return check_timeout_play;
    }

    function checkTimeout_reveal() public
    {
        uint myrevealtime;
        //uint opprevealtime;
        //address oppAdr = address(0x0);

        uint index1 = getPlayerIndex(msg.sender);
        uint index2;
        if (index1 != 10000)
        {
            myrevealtime = listOfPlayers[index1].timeout_reveal;
            index2 = getPlayerIndex(listOfPlayers[index1].OppAddr);
        }
        else{
            check_timeout_reveal = "Register your game";
            return;
        } 
        if (myrevealtime == 0)
        {
            check_timeout_reveal = "Reveal your move";
            return;
        }
        if (index2 != 10000 && listOfPlayers[index2].timeout_reveal != 0)
        {
            //in if condition
            address payable addrA;
            address payable addrB;
            addrA = payable(listOfPlayers[index1].MyAddr);
            addrB = payable(listOfPlayers[index2].MyAddr);
            if (listOfPlayers[index1].movePlayer != Moves.None && listOfPlayers[index1].movePlayer != Moves.None){
                check_timeout_reveal = "Proceed to get the outcome of the game";
                //return;
            }
            if (listOfPlayers[index2].timeout_reveal - listOfPlayers[index1].timeout_reveal > timeout)
            {
                addrA.transfer(listOfPlayers[index1].bet + listOfPlayers[index2].bet);
                console.log("Shifted balances due to time out"); 
                reset();
                check_timeout_reveal = "Shifted balances due to time out";
                return;
            } 
            else if (listOfPlayers[index1].timeout_reveal - listOfPlayers[index2].timeout_reveal > timeout){ //change this to timeout
                addrB.transfer(listOfPlayers[index1].bet + listOfPlayers[index2].bet);
                console.log("Shifted balances due to time out");
                check_timeout_reveal = "Shifted balances due to time out"; 
                return;
            }      
            else
            {
                check_timeout_reveal = "Hold on! There's time left";
                return;
            }   

        }
        else
        {
            //in else condition
            if (block.timestamp - myrevealtime > timeout) //change this to timeout
            {
                refund(payable(msg.sender), listOfPlayers[getPlayerIndex(msg.sender)].bet);
                reset();
                check_timeout_reveal = "Timed out, no opponent matched. Returing your deposit.";
            }
            else{
                check_timeout_reveal = "Hold on! There's Time left";
            }
        }

    }

    function checkTimeout_reveal_fe() public view returns (string memory){
        return check_timeout_reveal;
    }


}             
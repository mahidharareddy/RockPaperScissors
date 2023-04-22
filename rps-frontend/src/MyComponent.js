import React, { useEffect, useState } from 'react';
import Web3 from 'web3';
import CryptoJS from 'crypto-js';

function MyComponent() {
  const [result, setResult] = useState(null);
  const [contract, setContract] = useState(null);
  const [address, setAddress] = useState(null);
  const [playText, setPlayText] = useState(null);
  const [bet, setBet] = useState(null);


  async function connectToContract() {
    // Create an instance of the web3 provider using the MetaMask provider
    const web3 = new Web3(window.ethereum);
    await window.ethereum.enable(); // Request access to MetaMask

    // Create an instance of the smart contract
    //const contractAddress = '0x0165878A594ca255338adfa4d48449f69242Eb8F'; // Replace with the address of your smart contract
    const contractAddress = '0x0165878A594ca255338adfa4d48449f69242Eb8F'; // Replace with the address of your smart contract
    const abi_ = [
		{
			"inputs": [],
			"name": "BET_MIN",
			"outputs": [
				{
					"internalType": "uint256",
					"name": "",
					"type": "uint256"
				}
			],
			"stateMutability": "view",
			"type": "function"
		},
		{
			"inputs": [],
			"name": "REVEAL_TIMEOUT",
			"outputs": [
				{
					"internalType": "uint256",
					"name": "",
					"type": "uint256"
				}
			],
			"stateMutability": "view",
			"type": "function"
		},
		{
			"inputs": [],
			"name": "bothPlayed",
			"outputs": [
				{
					"internalType": "bool",
					"name": "",
					"type": "bool"
				}
			],
			"stateMutability": "view",
			"type": "function"
		},
		{
			"inputs": [],
			"name": "bothRevealed",
			"outputs": [
				{
					"internalType": "bool",
					"name": "",
					"type": "bool"
				}
			],
			"stateMutability": "view",
			"type": "function"
		},
		{
			"inputs": [],
			"name": "checkTimeout_play",
			"outputs": [],
			"stateMutability": "nonpayable",
			"type": "function"
		},
		{
			"inputs": [],
			"name": "checkTimeout_play_fe",
			"outputs": [
				{
					"internalType": "string",
					"name": "",
					"type": "string"
				}
			],
			"stateMutability": "view",
			"type": "function"
		},
		{
			"inputs": [],
			"name": "checkTimeout_register",
			"outputs": [],
			"stateMutability": "nonpayable",
			"type": "function"
		},
		{
			"inputs": [],
			"name": "checkTimeout_register_fe",
			"outputs": [
				{
					"internalType": "string",
					"name": "",
					"type": "string"
				}
			],
			"stateMutability": "view",
			"type": "function"
		},
		{
			"inputs": [],
			"name": "checkTimeout_reveal",
			"outputs": [],
			"stateMutability": "nonpayable",
			"type": "function"
		},
		{
			"inputs": [],
			"name": "checkTimeout_reveal_fe",
			"outputs": [
				{
					"internalType": "string",
					"name": "",
					"type": "string"
				}
			],
			"stateMutability": "view",
			"type": "function"
		},
		{
			"inputs": [],
			"name": "getContractBalance",
			"outputs": [
				{
					"internalType": "uint256",
					"name": "",
					"type": "uint256"
				}
			],
			"stateMutability": "view",
			"type": "function"
		},
		{
			"inputs": [],
			"name": "getFinalOutput",
			"outputs": [
				{
					"internalType": "string",
					"name": "",
					"type": "string"
				}
			],
			"stateMutability": "view",
			"type": "function"
		},
		{
			"inputs": [],
			"name": "getOutcome",
			"outputs": [
				{
					"internalType": "enum RockPaperScissors.Outcomes",
					"name": "",
					"type": "uint8"
				}
			],
			"stateMutability": "nonpayable",
			"type": "function"
		},
		{
			"inputs": [],
			"name": "getPlayOutput",
			"outputs": [
				{
					"internalType": "string",
					"name": "",
					"type": "string"
				}
			],
			"stateMutability": "view",
			"type": "function"
		},
		{
			"inputs": [],
			"name": "getRegisterValue",
			"outputs": [
				{
					"internalType": "string",
					"name": "",
					"type": "string"
				}
			],
			"stateMutability": "view",
			"type": "function"
		},
		{
			"inputs": [],
			"name": "getRevealOutput",
			"outputs": [
				{
					"internalType": "string",
					"name": "",
					"type": "string"
				}
			],
			"stateMutability": "view",
			"type": "function"
		},
		{
			"inputs": [],
			"name": "initialBet",
			"outputs": [
				{
					"internalType": "uint256",
					"name": "",
					"type": "uint256"
				}
			],
			"stateMutability": "view",
			"type": "function"
		},
		{
			"inputs": [
				{
					"internalType": "uint256",
					"name": "",
					"type": "uint256"
				}
			],
			"name": "listOfPlayers",
			"outputs": [
				{
					"internalType": "address",
					"name": "MyAddr",
					"type": "address"
				},
				{
					"internalType": "address",
					"name": "OppAddr",
					"type": "address"
				},
				{
					"internalType": "uint256",
					"name": "bet",
					"type": "uint256"
				},
				{
					"internalType": "bytes32",
					"name": "encryptedMove",
					"type": "bytes32"
				},
				{
					"internalType": "enum RockPaperScissors.Moves",
					"name": "movePlayer",
					"type": "uint8"
				},
				{
					"internalType": "uint256",
					"name": "timeout_register",
					"type": "uint256"
				},
				{
					"internalType": "uint256",
					"name": "timeout_play",
					"type": "uint256"
				},
				{
					"internalType": "uint256",
					"name": "timeout_reveal",
					"type": "uint256"
				}
			],
			"stateMutability": "view",
			"type": "function"
		},
		{
			"inputs": [],
			"name": "opponentJoined",
			"outputs": [
				{
					"internalType": "bool",
					"name": "",
					"type": "bool"
				}
			],
			"stateMutability": "view",
			"type": "function"
		},
		{
			"inputs": [
				{
					"internalType": "bytes32",
					"name": "encrMove",
					"type": "bytes32"
				}
			],
			"name": "play",
			"outputs": [
				{
					"internalType": "bool",
					"name": "",
					"type": "bool"
				}
			],
			"stateMutability": "nonpayable",
			"type": "function"
		},
		{
			"inputs": [],
			"name": "register",
			"outputs": [
				{
					"internalType": "uint256",
					"name": "",
					"type": "uint256"
				}
			],
			"stateMutability": "payable",
			"type": "function"
		},
		{
			"inputs": [
				{
					"internalType": "string",
					"name": "clearMove",
					"type": "string"
				}
			],
			"name": "reveal",
			"outputs": [
				{
					"internalType": "enum RockPaperScissors.Moves",
					"name": "",
					"type": "uint8"
				}
			],
			"stateMutability": "nonpayable",
			"type": "function"
		},
		{
			"inputs": [],
			"name": "timeout",
			"outputs": [
				{
					"internalType": "uint256",
					"name": "",
					"type": "uint256"
				}
			],
			"stateMutability": "view",
			"type": "function"
		},
		{
			"inputs": [],
			"name": "whoAmI",
			"outputs": [
				{
					"internalType": "uint256",
					"name": "",
					"type": "uint256"
				}
			],
			"stateMutability": "view",
			"type": "function"
		}
	]
    const contract = new web3.eth.Contract(abi_, contractAddress);
    setContract(contract);
    const addresses = await web3.eth.getAccounts();
    setAddress(addresses[0]);

    
  }
  




  async function register(){

    // const result = await contract.methods.revealTimeLeft().call();
    
    const result = await contract.methods.register().send({from: address, value:bet});
    console.log(result);
    const call_result = await contract.methods.getRegisterValue().call();
    setResult(call_result);
  }

  async function opponentJoined(){
    const result = await contract.methods.opponentJoined().call({from: address});
    setResult(result.toString());
  }

  async function checkTimeout_register(){
	const result = await contract.methods.checkTimeout_register().send({from: address});
	//setResult(result.toString());
	const call_result = await contract.methods.checkTimeout_register_fe().call({from: address});
    setResult(call_result);
  }


  function generateSHA256Hash(string) {
    const hash = CryptoJS.SHA256(string);
    return hash.toString(CryptoJS.enc.Hex);
  }

  async function play(){
    const hash = generateSHA256Hash(playText);
    // "0-hello" -> "0x8c57ac1c7a6832f4422e69043826479e40efad928394bc0b400330acf2e5bad3"
    const result = await contract.methods.play(`0x${hash}`).send({from: address});
    const call_result = await contract.methods.getPlayOutput().call();
    setResult(call_result);
  }

  async function checkTimeout_play(){
	const result = await contract.methods.checkTimeout_play().send({from: address});
	//setResult(result.toString());
	const call_result = await contract.methods.checkTimeout_play_fe().call({from: address});
    setResult(call_result);
  }
  async function getContractBalance(){
    const result = await contract.methods.getContractBalance().call({from: address});
    setResult(result.toString());
  }
  
  async function getOutcome(){
    const result = await contract.methods.getOutcome().send({from: address});
    console.log(result);
    const call_result = await contract.methods.getFinalOutput().call();
    setResult(call_result.toString());
  }
  
  async function reveal(){
    const result = await contract.methods.reveal(playText).send({from: address});
    console.log(result);
    const call_result = await contract.methods.getRevealOutput().call();
    setResult(call_result);
  }
  async function checkTimeout_reveal(){
	const result = await contract.methods.checkTimeout_reveal().send({from: address});
	//setResult(result.toString());
	const call_result = await contract.methods.checkTimeout_reveal_fe().call({from: address});
    setResult(call_result);
  }
  
  async function minimumBet(){
    // const result = await contract.methods.minimumBet().call({from: address});
    setResult("10000000000000000");
  }
  
  async function bothPlayed(){
    const result = await contract.methods.bothPlayed().call({from: address});
    setResult(result.toString());
  }

  async function bothRevealed(){
    const result = await contract.methods.bothRevealed().call({from: address});
    setResult(result.toString());
  }
  
  async function whoAmI(){
    const result = await contract.methods.whoAmI().call({from: address});
    setResult(result.toString());
  }

  useEffect(() => {
    connectToContract();
  }, []);

  function onPlayTextChange(event){
      console.log(event.target.value);
      setPlayText(event.target.value);
  }

  function onRegister(event){
    console.log(event.target.value);
    setBet(event.target.value);
}
  //async function resetGame(){
  //   const res = await contract.methods.reset_().send({from: address});
  //   console.log(res);
  // }

  return (
    <div>
      <br/>
      <br/>
      <button onClick={minimumBet}>Minimum Bet</button>
      <br/>
      <br/>
      <input onChange={onRegister} style={{ marginRight: '15px' }}></input>
      <button onClick={register}>Register</button>
      <br/>
      <br/>
	  <div>
		<button onClick={opponentJoined} style={{ marginRight: '15px' }}>Opponent Joined</button> 
		<button onClick={checkTimeout_register}>Check timeout</button>
	  </div>
      {/* <button onClick={opponentJoined}>Opponent Joined</button>
      <br/>
      <br/> */}
	  {/* <button onClick={checkTimeout_register}Check timeout></button> */}

      <br/>
      <button onClick={whoAmI}>Who Am I</button>
      <br/>
      <br/>
      
      <div>
	  	<input onChange={onPlayTextChange} style={{ marginRight: '15px' }}></input>
	  	<button onClick={play} style={{ marginRight: '15px' }}>Play</button>
		<button onClick={checkTimeout_play}>Check timeout</button>
	  </div>
	  
      <br/>

	  <div>
	  	<button onClick={reveal} style={{ marginRight: '15px' }}>Reveal</button>
		<button onClick={checkTimeout_reveal}>Check timeout</button>
	  </div>
	
      <br/>
      <button onClick={bothPlayed}>Both Played</button>
      <br/>
      <br/>
      <button onClick={bothRevealed}>Both Revealed</button>
      <br/>
      <br/>
      <button onClick={getContractBalance}>Get Contract Balance</button>
      <br/>
      <br/>
      <button onClick={getOutcome}>Get OutCome</button>
      {result && (<div><p>Result: {JSON.stringify(result)}</p>
        {/* <p>The result is: {result}</p> */}
      </div>
      )
      }
    </div>
  );
}

export default MyComponent;

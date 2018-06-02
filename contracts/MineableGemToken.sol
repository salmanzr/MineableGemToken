pragma solidity ^0.4.18;


// ----------------------------------------------------------------------------

// 'MineableGemToken' contract

// Mineable ERC721 Token using Proof Of Work

//

// Symbol      : MGT

// Name        : MineableGemToken

// Total supply: 1,000,000,000,000,000,000,000,000,000,000.00

// Decimals    : 1

//


// ----------------------------------------------------------------------------



// ----------------------------------------------------------------------------

// Safe maths

// ----------------------------------------------------------------------------

library SafeMath {

    function add(uint a, uint b) internal pure returns (uint c) {

        c = a + b;

        require(c >= a);

    }

    function sub(uint a, uint b) internal pure returns (uint c) {

        require(b <= a);

        c = a - b;

    }

    function mul(uint a, uint b) internal pure returns (uint c) {

        c = a * b;

        require(a == 0 || c / a == b);

    }

    function div(uint a, uint b) internal pure returns (uint c) {

        require(b > 0);

        c = a / b;

    }

}



library ExtendedMath {


    //return the smaller of the two inputs (a or b)
    function limitLessThan(uint a, uint b) internal pure returns (uint c) {

        if(a > b) return b;

        return a;

    }
}

// ----------------------------------------------------------------------------

// ERC Token Standard #20 Interface

// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md

// ----------------------------------------------------------------------------

contract ERC20Interface {

    function totalSupply() public constant returns (uint);

    function balanceOf(address tokenOwner) public constant returns (uint balance);

    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);

    function transfer(address to, uint tokens) public returns (bool success);

    function approve(address spender, uint tokens) public returns (bool success);

    function transferFrom(address from, address to, uint tokens) public returns (bool success);


    event Transfer(address indexed from, address indexed to, uint tokens);

    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);

}



// ----------------------------------------------------------------------------

// Contract function to receive approval and execute function in one call

//

// Borrowed from MiniMeToken

// ----------------------------------------------------------------------------

contract ApproveAndCallFallBack {

    function receiveApproval(address from, uint256 tokens, address token, bytes data) public;

}



// ----------------------------------------------------------------------------

// Owned contract

// ----------------------------------------------------------------------------

contract Owned {

    address public owner;

    address public newOwner;


    event OwnershipTransferred(address indexed _from, address indexed _to);


    constructor() public {

        owner = msg.sender;

    }


    modifier onlyOwner {

        require(msg.sender == owner);

        _;

    }


    function transferOwnership(address _newOwner) public onlyOwner {

        newOwner = _newOwner;

    }

    function acceptOwnership() public {

        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}


// ----------------------------------------------------------------------------

// ERC721 Token, with the addition of symbol, name and decimals and an

// initial fixed supply

// ----------------------------------------------------------------------------

contract MineableGemToken is ERC20Interface, Owned {

    using SafeMath for uint;
    using ExtendedMath for uint;


    string public symbol;
    string public name;
    uint8 public decimals;
    uint public _totalSupply;

    uint public latestDifficultyPeriodStarted;

	// Number of "blocks" (gems) mined
    uint public epochCount;

	// @TODO remove this
    uint public _BLOCKS_PER_READJUSTMENT = 1024;

    // Minimum difficulty that you can mine at.
    uint public  _MINIMUM_TARGET = 2**16;

	// Maximum diffuculty that you can mine at.
    uint public  _MAXIMUM_TARGET = 2**234;

	// The actual difficulty to mine at
	// Different per user
    mapping(address => uint) public miningTarget;

	// Challenge number - means that no one can submit the same hash twice
	// A new one is generated for a user when that user mints as new gem
    mapping(address => bytes32) public challengeNumber;

	// Just stores the last person that created a MGT
    address public lastRewardTo;

	// Just stores the last block number a token was created
    uint public lastRewardEthBlockNumber;

	// Stores the solutions for each challenge so that people can't submit a solution twice
    mapping(bytes32 => bytes32) solutionForChallenge;

    uint public tokensMinted;

    mapping(address => uint) balances;


    mapping(address => mapping(address => uint)) allowed;


    event Mint(address indexed from, bytes32 newChallengeNumber);

    // ------------------------------------------------------------------------

    // Constructor

    // ------------------------------------------------------------------------

    constructor() public {

        symbol = "MGT";
        name = "MineableGemToken";
        decimals = 8;
        _totalSupply = 100000000000000000 * 10**uint(decimals);
        tokensMinted = 0;
    }

  /*
		This is the function that actually mints tokens.
		Users mint/mine tokens by calling this function with the specified nonce,
		and their (personal) challenge digest.

		If the resulting hash is lower than their selected difficulty, a new
		MGT token is created.

    */
  function mint(uint256 nonce, bytes32 challenge_digest) public returns (bool success) {

	// First, calculate the digest - the hash - of the user's challengenumber,
	//  their address, and the provided nonce
    bytes32 digest = keccak256(abi.encodePacked(challengeNumber[msg.sender], msg.sender, nonce));

	// Verify that the provided hash is correct
    if (digest != challenge_digest) revert();

    // Verify that the provided hash is leq than the mining target
    if(uint256(digest) > miningTarget[msg.sender]) revert();

	// @TODO here is where we want to actually mint the coins
	mintGemToken(miningTarget[msg.sender]);
    tokensMinted = tokensMinted.add(1);

    // Set readonly diagnostics data
    lastRewardTo = msg.sender;
    lastRewardEthBlockNumber = block.number;

	// Set new challenge number for the user
	// This is just the hash of the nonce, which will change every time
	// (because we never have an identical hash)
	challengeNumber[msg.sender] = keccak256(abi.encodePacked(nonce));

	emit Mint(msg.sender, challengeNumber[msg.sender]);

    return true;
  }
  
  function mintGemToken(uint difficulty) internal {
      
  }

  // Sets the user's difficulty that they wish to mine at
  function setMyDifficulty(uint difficulty) public {
	require(difficulty > _MAXIMUM_TARGET && difficulty < _MINIMUM_TARGET);
	miningTarget[msg.sender] = difficulty;
  }

  // Get the user's challenge number
  function getChallengeNumber() public constant returns (bytes32) {
    return challengeNumber[msg.sender];
  }

  // Gets the number of zeroes the digest of the PoW solution requires (different per user)
  function getMiningDifficulty() public constant returns (uint) {
    return _MAXIMUM_TARGET.div(miningTarget[msg.sender]);
  }

  // Gets a user's mining target
  function getMiningTarget() public constant returns (uint) {
    return miningTarget[msg.sender];
  }

  // Helps debug mining software
  function getMintDigest(uint256 nonce, bytes32 challenge_number) public view returns (bytes32 digesttest) {

    bytes32 digest = keccak256(abi.encodePacked(challenge_number, msg.sender, nonce));

    return digest;
  }

  // Helps debug mining software
  function checkMintSolution(uint256 nonce, bytes32 challenge_digest, bytes32 challenge_number, uint testTarget) public view returns (bool success) {

    bytes32 digest = keccak256(abi.encodePacked(challenge_number, msg.sender, nonce));

    if(uint256(digest) > testTarget) revert();

    return (digest == challenge_digest);
  }

  // ------------------------------------------------------------------------

  // Total supply

  // ------------------------------------------------------------------------

  function totalSupply() public constant returns (uint) {

    return _totalSupply  - balances[address(0)];
  }

  // ------------------------------------------------------------------------

  // Get the token balance for account `tokenOwner`

  // ------------------------------------------------------------------------

  function balanceOf(address tokenOwner) public constant returns (uint balance) {

    return balances[tokenOwner];
  }

  // ------------------------------------------------------------------------

  // Transfer the balance from token owner's account to `to` account

  // - Owner's account must have sufficient balance to transfer

  // - 0 value transfers are allowed

  // ------------------------------------------------------------------------

  function transfer(address to, uint tokens) public returns (bool success) {

    balances[msg.sender] = balances[msg.sender].sub(tokens);

    balances[to] = balances[to].add(tokens);

    emit Transfer(msg.sender, to, tokens);

    return true;

  }

  // ------------------------------------------------------------------------

  // Token owner can approve for `spender` to transferFrom(...) `tokens`

  // from the token owner's account

  //

  // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md

  // recommends that there are no checks for the approval double-spend attack

  // as this should be implemented in user interfaces

  // ------------------------------------------------------------------------

  function approve(address spender, uint tokens) public returns (bool success) {

    allowed[msg.sender][spender] = tokens;

    emit Approval(msg.sender, spender, tokens);

    return true;

  }

  // ------------------------------------------------------------------------

  // Transfer `tokens` from the `from` account to the `to` account

  //

  // The calling account must already have sufficient tokens approve(...)-d

  // for spending from the `from` account and

  // - From account must have sufficient balance to transfer

  // - Spender must have sufficient allowance to transfer

  // - 0 value transfers are allowed

  // ------------------------------------------------------------------------

  function transferFrom(address from, address to, uint tokens) public returns (bool success) {

    balances[from] = balances[from].sub(tokens);

    allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);

    balances[to] = balances[to].add(tokens);

    emit Transfer(from, to, tokens);

    return true;
  }

  // ------------------------------------------------------------------------

  // Returns the amount of tokens approved by the owner that can be

  // transferred to the spender's account

  // ------------------------------------------------------------------------

  function allowance(address tokenOwner, address spender) public constant returns (uint remaining) {

    return allowed[tokenOwner][spender];
  }

  // ------------------------------------------------------------------------

  // Token owner can approve for `spender` to transferFrom(...) `tokens`

  // from the token owner's account. The `spender` contract function

  // `receiveApproval(...)` is then executed

  // ------------------------------------------------------------------------

  function approveAndCall(address spender, uint tokens, bytes data) public returns (bool success) {

    allowed[msg.sender][spender] = tokens;

    emit Approval(msg.sender, spender, tokens);

    ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, this, data);

    return true;
  }

  // ------------------------------------------------------------------------

  // Don't accept ETH

  // ------------------------------------------------------------------------

  function () public payable {

    revert();
  }

  // ------------------------------------------------------------------------

  // Owner can transfer out any accidentally sent ERC20 tokens

  // ------------------------------------------------------------------------

  function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {

    return ERC20Interface(tokenAddress).transfer(owner, tokens);

  }
}

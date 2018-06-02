pragma solidity ^0.4.23;

/// @title Interface for contracts conforming to ERC-721: Non-Fungible Tokens
contract ERC721 {
  // Required methods
  function totalSupply() public view returns (uint256 total);
  function balanceOf(address _owner) public view returns (uint256 balance);
  function ownerOf(uint256 _tokenId) external view returns (address owner);
  function approve(address _to, uint256 _tokenId) external;
  function transfer(address _to, uint256 _tokenId) external;
  function transferFrom(address _from, address _to, uint256 _tokenId) external;

  // Events
  event Transfer(address from, address to, uint256 tokenId);
  event Approval(address owner, address approved, uint256 tokenId);
}

contract GemBase {
  /*** EVENTS ***/

	// The "mint" event (or birth, or whatever you'd like to think of it as)
  event Metamorphisis(address owner, uint256 gemId, uint256 rarity);

	// The "transfer" event
  event Transfer(address from, address to, uint256 tokenId);

	// The main Gem struct
  struct Gem {
		// The rarity of the gem. Determined by the difficulty when mined
    uint256 rarity;

    // The price of the gem.
    uint256 price;

    // The timestamp from the block when this cat came into existence.
    uint64 morphTime;
  }

	// Stores literally all of the gems in existence
  Gem[] gems;

	// Mapping of gems to who owns them
  mapping (uint256 => address) public gemIndexToOwner;

	// Mapping of address to number of tokens (gems) owned
  mapping (address => uint256) ownershipTokenCount;

	// Mapping used in transferFrom
  mapping (uint256 => address) public gemIndexToApproved;

	// Standard ERC721 transfer
  function _transfer(address _from, address _to, uint256 _tokenId) internal {
    // Since the number of gems is capped to 2^32 we can't overflow this
    ownershipTokenCount[_to]++;

    // Transfer ownership
    gemIndexToOwner[_tokenId] = _to;

    // When creating new gems _from is 0x0, but we can't account that address.
    if (_from != address(0)) {
      ownershipTokenCount[_from]--;

      // Clear any previously approved ownership exchange
      delete gemIndexToApproved[_tokenId];
    }

    // Emit the transfer event.
    emit Transfer(_from, _to, _tokenId);
  }

  /// @dev An internal method that creates a new gem and stores it. This
  ///  method doesn't do any checking and should only be called when the
  ///  input data is known to be valid. Will generate both a Metamorphisis event
  ///  and a Transfer event.
  /// @param _rarity The gem's genetic code.
  /// @param _owner The inital owner of this gem, must be non-zero
  function _createGem(uint256 _rarity, address _owner) internal returns (uint) {

    // Initialize the gem in memory
    Gem memory _gem = Gem({
      rarity: _rarity,
      price: uint256(0),
      morphTime: uint64(now)
    });

    // Initalize the gem ID & push it to the list of gems
    uint256 newGemId = gems.push(_gem) - 1;

    require(newGemId == uint256(uint32(newGemId)));

		// Emit the Metamorphisis event
    emit Metamorphisis(
      _owner,
      newGemId,
      _gem.rarity
    );

    // This will assign ownership, and also emit the Transfer event
    _transfer(0, _owner, newGemId);

    return newGemId;
  }
}

contract GemOwnership is GemBase, ERC721 {

    /// @notice Name and symbol of the non fungible token, as defined in ERC721.
    string public constant name = "MineableGemTokens";
    string public constant symbol = "MGT";

  // Put a gem for sale only if the caller is the owner
  function putGemForSale (uint256 _gemId, uint256 _price) external {
      require(_price != 0);
      require(_owns(msg.sender, _gemId));
      gems[_gemId].price = _price;
    }

  // Delist a gem that you don't want to sell anymore
  function delistGem (uint256 _gemId) external {
      require(_owns(msg.sender, _gemId));
      gems[_gemId].price = 0;
  }

  // Buy a gem that is for sale (i.e. the price is not 0)
  function buyGem (uint256 _gemId) external payable {
      require(gems[_gemId].price != 0);
      require(msg.value == gems[_gemId].price);

      // Transfer gem to the buyer
      _transfer(gemIndexToOwner[_gemId], msg.sender, _gemId);

      // Transfer ether to the previous owner
      gemIndexToOwner[_gemId].transfer(msg.value);
    } 

    // Internal utility functions: These functions all assume that their input arguments
    // are valid. We leave it to public methods to sanitize their inputs and follow
    // the required logic.

    /// @dev Checks if a given address is the current owner of a particular Gem.
    /// @param _claimant the address we are validating against.
    /// @param _tokenId gem id, only valid when > 0
    function _owns(address _claimant, uint256 _tokenId) internal view returns (bool) {
      return gemIndexToOwner[_tokenId] == _claimant;
    }

    /// @dev Checks if a given address currently has transferApproval for a particular Gem.
    /// @param _claimant the address we are confirming gem is approved for.
    /// @param _tokenId gem id, only valid when > 0
    function _approvedFor(address _claimant, uint256 _tokenId) internal view returns (bool) {
      return gemIndexToApproved[_tokenId] == _claimant;
    }

    /// @dev Marks an address as being approved for transferFrom(), overwriting any previous
    ///  approval. Setting _approved to address(0) clears all transfer approval.
    ///  NOTE: _approve() does NOT send the Approval event. This is intentional because
    ///  _approve() and transferFrom() are used together for putting Gems on auction, and
    ///  there is no value in spamming the log with Approval events in that case.
    function _approve(uint256 _tokenId, address _approved) internal {
        gemIndexToApproved[_tokenId] = _approved;
    }

    /// @notice Returns the number of Gems owned by a specific address.
    /// @param _owner The owner address to check.
    /// @dev Required for ERC-721 compliance
    function balanceOf(address _owner) public view returns (uint256 count) {
        return ownershipTokenCount[_owner];
    }

    /// @notice Transfers a Gem to another address. If transferring to a smart
    ///  contract be VERY CAREFUL to ensure that it is aware of ERC-721 (or
    ///  CryptoGems specifically) or your Gem may be lost forever. Seriously.
    /// @param _to The address of the recipient, can be a user or contract.
    /// @param _tokenId The ID of the Gem to transfer.
    /// @dev Required for ERC-721 compliance.
    function transfer(
        address _to,
        uint256 _tokenId
    )
        external
    {
        // Safety check to prevent against an unexpected 0x0 default.
        require(_to != address(0));
        // Disallow transfers to this contract to prevent accidental misuse.
        // The contract should never own any gems (except very briefly
        // after a gen0 cat is created and before it goes on auction).
        require(_to != address(this));

        // You can only send your own gem.
        require(_owns(msg.sender, _tokenId));

        // Reassign ownership, clear pending approvals, emit Transfer event.
        _transfer(msg.sender, _to, _tokenId);
    }

    /// @notice Grant another address the right to transfer a specific Gem via
    ///  transferFrom(). This is the preferred flow for transfering NFTs to contracts.
    /// @param _to The address to be granted transfer approval. Pass address(0) to
    ///  clear all approvals.
    /// @param _tokenId The ID of the Gem that can be transferred if this call succeeds.
    /// @dev Required for ERC-721 compliance.
    function approve(
        address _to,
        uint256 _tokenId
    )
        external
    {
        // Only an owner can grant transfer approval.
        require(_owns(msg.sender, _tokenId));

        // Register the approval (replacing any previous approval).
        _approve(_tokenId, _to);

        // Emit approval event.
        emit Approval(msg.sender, _to, _tokenId);
    }

    /// @notice Transfer a Gem owned by another address, for which the calling address
    ///  has previously been granted transfer approval by the owner.
    /// @param _from The address that owns the Gem to be transfered.
    /// @param _to The address that should take ownership of the Gem. Can be any address,
    ///  including the caller.
    /// @param _tokenId The ID of the Gem to be transferred.
    /// @dev Required for ERC-721 compliance.
    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    )
        external
    {
        // Safety check to prevent against an unexpected 0x0 default.
        require(_to != address(0));
        // Disallow transfers to this contract to prevent accidental misuse.
        // The contract should never own any gems (except very briefly
        // after a gen0 cat is created and before it goes on auction).
        require(_to != address(this));
        // Check for approval and valid ownership
        require(_approvedFor(msg.sender, _tokenId));
        require(_owns(_from, _tokenId));

        // Reassign ownership (also clears pending approvals and emits Transfer event).
        _transfer(_from, _to, _tokenId);
    }

    /// @notice Returns the total number of Gems currently in existence.
    /// @dev Required for ERC-721 compliance.
    function totalSupply() public view returns (uint) {
        return gems.length - 1;
    } 

    /// @notice Returns the address currently assigned ownership of a given Gem.
    /// @dev Required for ERC-721 compliance.
    function ownerOf(uint256 _tokenId)
        external
        view
        returns (address owner)
    {
        owner = gemIndexToOwner[_tokenId];

        require(owner != address(0));
    }

    /// @notice Returns a list of all Gem IDs assigned to an address.
    /// @param _owner The owner whose Gems we are interested in.
    /// @dev This method MUST NEVER be called by smart contract code. First, it's fairly
    ///  expensive (it walks the entire Gem array looking for gems belonging to owner),
    ///  but it also returns a dynamic array, which is only supported for web3 calls, and
    ///  not contract-to-contract calls.
    function tokensOfOwner(address _owner) external view returns(uint256[] ownerTokens) {
        uint256 tokenCount = balanceOf(_owner);

        if (tokenCount == 0) {
            // Return an empty array
            return new uint256[](0);
        } else {
            uint256[] memory result = new uint256[](tokenCount);
            uint256 totalGems = totalSupply();
            uint256 resultIndex = 0;

            // We count on the fact that all gems have IDs starting at 1 and increasing
            // sequentially up to the totalGem count.
            uint256 gemId;

            for (gemId = 1; gemId <= totalGems; gemId++) {
                if (gemIndexToOwner[gemId] == _owner) {
                    result[resultIndex] = gemId;
                    resultIndex++;
                }
            }

            return result;
        }
    }
}

// The ERC-918 stuff!
contract GemMining is GemOwnership {
	using SafeMath for uint256;

  // Minimum and maximum difficulties for mining gems
  uint public _MINIMUM_TARGET = 2**16;
  uint public _MAXIMUM_TARGET = 2**234;

  // Difficulty that each user is mining at
  // (they can set this)
  mapping(address => uint) public miningTarget;

  // Challenge number - changes every time a user mints
  // (this is also per user)
  mapping(address => bytes32) public challengeNumber;

  // Stores solutions for each challenge so that people can't submit a challenge twice
  mapping(bytes32 => bytes32) public solutionForChallenge;

  /*  This is the function that actually mints tokens.
      Users mint (mine) tokens by calling this function with the specified nonce
      and their personal challenge digest.

      If the resulting hash is *lower* than their selected difficulty, a new MGT token is created.
  */

  function mint(uint nonce, bytes32 challenge_digest) public returns (bool success) {
    // First, calculate the digest (hash) of the user's:
    //  1) challenumber, 2) address, 3) provided nonce
    bytes32 digest = keccak256(abi.encodePacked(challengeNumber[msg.sender], msg.sender, nonce));

    // Verify that the provided hash is correct
    if (digest != challenge_digest) revert();

    // Verify that the provided hash is leq than the mining target
    if (uint(digest) > miningTarget[msg.sender]) revert();

    // Success! Call the internal minting function.
    _createGem(miningTarget[msg.sender], msg.sender);

    // Set new challenge number for the user
    challengeNumber[msg.sender] = keccak256(abi.encodePacked(nonce));

		return true;
  }

  // Sets the user's difficulty that they wish to mine at
  function setMyDifficulty(uint difficulty) public {
    require(difficulty < _MAXIMUM_TARGET && difficulty > _MINIMUM_TARGET);
    miningTarget[msg.sender] = difficulty;
  }

  // Get the user's challenge number
  function getChallengeNumber() public constant returns (bytes32) {
    return challengeNumber[msg.sender];
  }

  // Gets the number of zeroers the digest of the PoW solution requires for the user
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
}

contract GemCore is GemMining {
  /// @notice Creates the main CryptoGems smart contract instance.
  constructor () public {
    // Start with a the rarest-possible (unachievable) token
        _createGem(uint256(-1), address(0x0));
    }

    /// @notice No tipping!
    function() external payable {
				revert();
    }

    /// @notice Returns all the relevant information about a specific kitty.
    /// @param _id The ID of the kitty of interest.
    function getGem(uint256 _id)
        external
        view
        returns (
        uint256 morphTime,
        uint256 price,
        uint256 rarity,
        address owner
    ) {
        Gem storage myGem = gems[_id];
        morphTime = uint256(myGem.morphTime);
        rarity = myGem.rarity;
        price = myGem.price;
        owner = gemIndexToOwner[_id];
    }
}

// Safemath library
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

// ExtendedMath library
library ExtendedMath {
    // Return the smaller of the two inputs (a or b)
    function limitLessThan(uint a, uint b) internal pure returns (uint c) {
        if(a > b) return b;
        return a;
    }
}

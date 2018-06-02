contract GemBase {
    /*** EVENTS ***/

    /// @dev The Metamorphisis event is fired whenever a new Gem comes into existence. This obviously
    ///  includes any time a cat is created through the giveMetamorphisis method, but it is also called
    ///  when a new gen0 cat is created.
    event Metamorphisis(address owner, uint256 gemId, uint256 rarity);

    /// @dev Transfer event as defined in current draft of ERC721. Emitted every time a Gem
    ///  ownership is assigned, including metamorphs.
    event Transfer(address from, address to, uint256 tokenId);

    /*** DATA TYPES ***/

    /// @dev The main Gem struct. Every gem in CryptoGems is represented by a copy
    ///  of this structure, so great care was taken to ensure that it fits neatly into
    ///  exactly two 256-bit words. Note that the order of the members in this structure
    ///  is important because of the byte-packing rules used by Ethereum.
    ///  Ref: http://solidity.readthedocs.io/en/develop/miscellaneous.html
    struct Gem {
        // The Gem's genetic code is packed into these 256-bits, the format is
        // sooper-sekret! A cat's genes never change.
        uint256 rarity;

        // The timestamp from the block when this cat came into existence.
        uint64 morphTime;
    }

    /*** STORAGE ***/

    /// @dev An array containing the Gem struct for all Gems in existence. The ID
    ///  of each cat is actually an index into this array. Note that ID 0 is a negacat,
    ///  the unGem, the mythical beast that is the parent of all gen0 cats. A bizarre
    ///  creature that is both matron and sire... to itself! Has an invalid genetic code.
    ///  In other words, cat ID 0 is invalid... ;-)
    Gem[] gems;

    /// @dev A mapping from cat IDs to the address that owns them. All cats have
    ///  some valid owner address, even gen0 cats are created with a non-zero owner.
    mapping (uint256 => address) public gemIndexToOwner;

    // @dev A mapping from owner address to count of tokens that address owns.
    //  Used internally inside balanceOf() to resolve ownership count.
    mapping (address => uint256) ownershipTokenCount;

    /// @dev A mapping from GemIDs to an address that has been approved to call
    ///  transferFrom(). Each Gem can only have one approved address for transfer
    ///  at any time. A zero value means no approval is outstanding.
    mapping (uint256 => address) public gemIndexToApproved;


    /// @dev Assigns ownership of a specific Gem to an address.
    function _transfer(address _from, address _to, uint256 _tokenId) internal {
        // Since the number of gems is capped to 2^32 we can't overflow this
        ownershipTokenCount[_to]++;
        // transfer ownership
        gemIndexToOwner[_tokenId] = _to;
        // When creating new gems _from is 0x0, but we can't account that address.
        if (_from != address(0)) {
            ownershipTokenCount[_from]--;
            // clear any previously approved ownership exchange
            delete gemIndexToApproved[_tokenId];
        }
        // Emit the transfer event.
        Transfer(_from, _to, _tokenId);
    }

    /// @dev An internal method that creates a new gem and stores it. This
    ///  method doesn't do any checking and should only be called when the
    ///  input data is known to be valid. Will generate both a Metamorphisis event
    ///  and a Transfer event.    
    /// @param _rarity The gem's genetic code.
    /// @param _owner The inital owner of this cat, must be non-zero (except for the unGem, ID 0)
    function _createGem(                
        uint256 _rarity,
        address _owner
    )
        internal
        returns (uint)
    {

        Gem memory _gem = Gem({
            rarity: _rarity,
            morphTime: uint64(now)            
        });
        uint256 newGemId = gems.push(_gem) - 1;

        // It's probably never going to happen, 4 billion cats is A LOT, but
        // let's just be 100% sure we never let this happen.
        require(newGemId == uint256(uint32(newGemId)));

        // emit the metamorphisis event
        Metamorphisis(
            _owner,
            newGemId,                        
            _gem.rarity
        );

        // This will assign ownership, and also emit the Transfer event as
        // per ERC721 draft
        _transfer(0, _owner, newGemId);

        return newGemId;
    }

}

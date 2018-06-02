contract GemMinting is GemOwnership {    

    // Counts the number of cats the contract owner has created.    
    uint256 public createdCount;

    /// @dev we can create promo kittens, up to a limit.
    /// @param _genes the encoded genes of the kitten to be created, any value is accepted
    /// @param _owner the future owner of the created kittens. 
    function createPromoKitty(uint256 _rarity, address _owner) external {            
        _createGem(0, 0, 0, _rarity, _owner);
        createdCount++;
    }

}

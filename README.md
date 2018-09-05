
 ## MineableGemToken

 #### An ERC-721 "collectible" token that is mined using PoW

  * Infinite token supply
  * Difficulty customizable
  * More difficult = more rare gems minted
  * Less difficult = less rare gems minted
  * Compatible with all services that support ERC721 tokens

 #### How does it work?

This is an adaptation of ERC-918 for ERC-721 tokens - non-fungible tokens. Instead of CryptoKitties minted by the creators of that platform, these are gems created by mining with Proof of Work!

In order to mine CryptoGems, users must submit a nonce that hashes, along with a universal challenge number and their address, to a number that is below their *individual* set difficulty. If a users submits a hash that follows these conditions, they "mint" a new CryptoGem.

#### Developed by Salman Rahim and Caleb Ditchfield

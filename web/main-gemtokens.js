function displayWei(id, wei, ethToUsd) {
    ether = web3.fromWei(wei, "ether");
    $(id).text(ether.toFormat(5, web3.BigNumber.ROUND_HALF_UP) + " ETH");
    $(id).attr("data-original-title", ether.toFormat() + " ETH");
    $(id).tooltip();
    if (ethToUsd !== undefined)
        $(id + "-usd").text("($" + ether.times(ethToUsd).toFormat(2, web3.BigNumber.ROUND_HALF_UP) + ")");
}

function setup() {
    var abiArray = [
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"name": "owner",
				"type": "address"
			},
			{
				"indexed": false,
				"name": "gemId",
				"type": "uint256"
			},
			{
				"indexed": false,
				"name": "rarity",
				"type": "uint256"
			}
		],
		"name": "Metamorphisis",
		"type": "event"
	},
	{
		"constant": false,
		"inputs": [
			{
				"name": "_to",
				"type": "address"
			},
			{
				"name": "_tokenId",
				"type": "uint256"
			}
		],
		"name": "approve",
		"outputs": [],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [
			{
				"name": "_gemId",
				"type": "uint256"
			}
		],
		"name": "buyGem",
		"outputs": [],
		"payable": true,
		"stateMutability": "payable",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [
			{
				"name": "_gemId",
				"type": "uint256"
			}
		],
		"name": "delistGem",
		"outputs": [],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"name": "from",
				"type": "address"
			},
			{
				"indexed": false,
				"name": "to",
				"type": "address"
			},
			{
				"indexed": false,
				"name": "tokenId",
				"type": "uint256"
			}
		],
		"name": "Transfer",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"name": "owner",
				"type": "address"
			},
			{
				"indexed": false,
				"name": "approved",
				"type": "address"
			},
			{
				"indexed": false,
				"name": "tokenId",
				"type": "uint256"
			}
		],
		"name": "Approval",
		"type": "event"
	},
	{
		"constant": false,
		"inputs": [
			{
				"name": "nonce",
				"type": "uint256"
			},
			{
				"name": "challenge_digest",
				"type": "bytes32"
			}
		],
		"name": "mint",
		"outputs": [
			{
				"name": "success",
				"type": "bool"
			}
		],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [
			{
				"name": "_gemId",
				"type": "uint256"
			},
			{
				"name": "_price",
				"type": "uint256"
			}
		],
		"name": "putGemForSale",
		"outputs": [],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [
			{
				"name": "difficulty",
				"type": "uint256"
			}
		],
		"name": "setMyDifficulty",
		"outputs": [],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [
			{
				"name": "_to",
				"type": "address"
			},
			{
				"name": "_tokenId",
				"type": "uint256"
			}
		],
		"name": "transfer",
		"outputs": [],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [
			{
				"name": "_from",
				"type": "address"
			},
			{
				"name": "_to",
				"type": "address"
			},
			{
				"name": "_tokenId",
				"type": "uint256"
			}
		],
		"name": "transferFrom",
		"outputs": [],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "constructor"
	},
	{
		"payable": true,
		"stateMutability": "payable",
		"type": "fallback"
	},
	{
		"constant": true,
		"inputs": [],
		"name": "_MAXIMUM_TARGET",
		"outputs": [
			{
				"name": "",
				"type": "uint256"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [],
		"name": "_MINIMUM_TARGET",
		"outputs": [
			{
				"name": "",
				"type": "uint256"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [
			{
				"name": "_owner",
				"type": "address"
			}
		],
		"name": "balanceOf",
		"outputs": [
			{
				"name": "count",
				"type": "uint256"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [
			{
				"name": "",
				"type": "address"
			}
		],
		"name": "challengeNumber",
		"outputs": [
			{
				"name": "",
				"type": "bytes32"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [
			{
				"name": "nonce",
				"type": "uint256"
			},
			{
				"name": "challenge_digest",
				"type": "bytes32"
			},
			{
				"name": "challenge_number",
				"type": "bytes32"
			},
			{
				"name": "testTarget",
				"type": "uint256"
			}
		],
		"name": "checkMintSolution",
		"outputs": [
			{
				"name": "success",
				"type": "bool"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [
			{
				"name": "",
				"type": "uint256"
			}
		],
		"name": "gemIndexToApproved",
		"outputs": [
			{
				"name": "",
				"type": "address"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [
			{
				"name": "",
				"type": "uint256"
			}
		],
		"name": "gemIndexToOwner",
		"outputs": [
			{
				"name": "",
				"type": "address"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [],
		"name": "getChallengeNumber",
		"outputs": [
			{
				"name": "",
				"type": "bytes32"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [
			{
				"name": "_id",
				"type": "uint256"
			}
		],
		"name": "getGem",
		"outputs": [
			{
				"name": "morphTime",
				"type": "uint256"
			},
			{
				"name": "price",
				"type": "uint256"
			},
			{
				"name": "rarity",
				"type": "uint256"
			},
			{
				"name": "id",
				"type": "uint256"
			},
			{
				"name": "owner",
				"type": "address"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [],
		"name": "getMiningDifficulty",
		"outputs": [
			{
				"name": "",
				"type": "uint256"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [],
		"name": "getMiningTarget",
		"outputs": [
			{
				"name": "",
				"type": "uint256"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [
			{
				"name": "nonce",
				"type": "uint256"
			},
			{
				"name": "challenge_number",
				"type": "bytes32"
			}
		],
		"name": "getMintDigest",
		"outputs": [
			{
				"name": "digesttest",
				"type": "bytes32"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [
			{
				"name": "",
				"type": "address"
			}
		],
		"name": "miningTarget",
		"outputs": [
			{
				"name": "",
				"type": "uint256"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [],
		"name": "name",
		"outputs": [
			{
				"name": "",
				"type": "string"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [
			{
				"name": "_tokenId",
				"type": "uint256"
			}
		],
		"name": "ownerOf",
		"outputs": [
			{
				"name": "owner",
				"type": "address"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [
			{
				"name": "",
				"type": "bytes32"
			}
		],
		"name": "solutionForChallenge",
		"outputs": [
			{
				"name": "",
				"type": "bytes32"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [],
		"name": "symbol",
		"outputs": [
			{
				"name": "",
				"type": "string"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [
			{
				"name": "_owner",
				"type": "address"
			}
		],
		"name": "tokensOfOwner",
		"outputs": [
			{
				"name": "ownerTokens",
				"type": "uint256[]"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [],
		"name": "totalSupply",
		"outputs": [
			{
				"name": "",
				"type": "uint256"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	}
];

		var contract = web3.eth.contract(abiArray).at("0x6478f69cc8da40031d7aaee77bdfd50015e75237");

    var myNumGems;
		var myGems;

    contract.balanceOf(web3.eth.accounts[0], function(error, result) {
			if (!error) {
				myNumGems = result;
			} else {
				console.error(error)
			}
		});

		function refresh() {

			// First, delete all of the displayed gems
			$("#gem-display").empty()

			// Grab the number of gems we have
			contract.balanceOf(web3.eth.accounts[0], function(error, result) {
				if (!error) {
				  myNumGems = result;
			
					contract.getMiningTarget(function(error, result) {
						if (!error) {
							rarity = result.toNumber() / (1E61);
							var htmlString = "<p>You own "+myNumGems+" gems!</p><p>Your Rarity Target: "+rarity+
															 " (high number = less rare)</p><div class='row'><div class='col-sm-10 mr-0 pr-0'><input type='button' id='setdifficultybutton' class='btn btn-md rounded-0 border-right-0' value='Set Target Rarity'></input></div>" +
															 "<div class='col-sm-2 pl-0 ml-0'><input type='text' id='setdifficultyvalue' class='input-sm rounded-0 border-left-0 form-control'></input></div></div>"
							$("#numtokensdiv").html(htmlString);
							$("#setdifficultybutton").click(function(){
								var temp = $("#setdifficultyvalue").val();
								diff = new web3.BigNumber(10).pow(61) * temp;
								console.log(diff.toString());
								contract.setMyDifficulty(diff.toString(), function(error, result){
									if(!error) {
										console.log("Set difficulty sucessful!");
									} else {
										console.error(error);	
									}
								});
							});
						} else {
							console.error(error);
						}
					});
				} else {
					console.error(error);
				}
			});

			if (myGems != 0) {
				// Get the Gem ids
        contract.tokensOfOwner(web3.eth.accounts[0], function(error, result) {
					if (!error) {
						// Resould should be a list of ids
						var j;
						console.log("Owned Gems (IDs):");
						$("#gem-display").empty();
						for(let j of result){
							//console.log(result[j].c[0]);
							// Grab the gem info and put it on the page
							contract.getGem(j, function(error, result) {
								if(!error) {
									console.log(result);
									
									var creationDate = new Date(result[0].c[0]*1000);
									var rarity = result[2].toNumber() / 1E61;
									var price = result[1].c[0] == 0 ? "Not for sale" : result[1].c[0] / 10000;
									var priceString = price == "Not for sale" ? "Not for sale" : price + " ETH";
									var buttonText = price == "Not for sale" ? "Sell" : "Delist";
									var gemID = result[3].c[0];
									var onClickScript = "";

									gemString = "<div " +
															" style='background: rgba(0,"+parseInt((1E6-rarity)/4000)+",25,0.5)'" +
															" id='gem"+gemID+"'" +
															" class='gem col-sm-6 col-mg-5 col-lg-5' data-price='"+price+"' data-rarity='"+rarity+"'>" + 
															"GEM ID: " + result[3].c[0] +
															"<br/>Creation Date: " + creationDate.toLocaleString() +
															"<br/>Price: " + priceString +
															"<br/>Rarity: " + rarity +
															"<br/><br/><div class='row'><div class='col-sm-9 mr-0 pr-0 text-left'><button type='button' class='btn btn-info rounded-0 border-right-0' onClick='"+onClickScript+"' value='Sell'>" + buttonText + "</button></div>" + 
															"<div class='col-sm-3 ml-0 pl-0 text-right'><input type='text' class='input-sm form-control rounded-0 border-left-0'></div></div>" +
															"</div>"

									$("#gem-display").prepend(gemString);
									$("#gem" + gemID + " button").click(function() {
										if ($("#gem" + gemID).data("price") == "Not for sale") {
											var price = $("#gem" + gemID + " input").val() * 1e18;
											console.log("Selected Price:" + price);
											contract.putGemForSale(gemID, price, function(error, result){
											});
										} else {
											contract.delistGem(gemID, function(error, result){
											});
										}
									});
											
	
								} else {
									console.error(error);
								}
							});
						}
					} else {
						console.error(error);
					}
				});

			}
		}

    refresh();
    setTimeout(refresh, 2000);
}

window.addEventListener("load", function() {
    if (typeof web3 !== "undefined") {
        web3 = new Web3(web3.currentProvider);
        web3.version.getNetwork(function(error, result) {
            if (!error) {
                if (result == "1") {
									  console.log("Setting up (Mainnet)...");
                    setup();
                } else {
										console.log("Setting up (Ropsten)...");
										setup();
								}
            } else {
							console.log(error);
						}
        });
    } else {
		  console.log("No web3 found.");
		}
});

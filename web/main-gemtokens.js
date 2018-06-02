function displayWei(id, wei, ethToUsd) {
    ether = web3.fromWei(wei, "ether");
    $(id).text(ether.toFormat(5, web3.BigNumber.ROUND_HALF_UP) + " ETH");
    $(id).attr("data-original-title", ether.toFormat() + " ETH");
    $(id).tooltip();
    if (ethToUsd !== undefined)
        $(id + "-usd").text("($" + ether.times(ethToUsd).toFormat(2, web3.BigNumber.ROUND_HALF_UP) + ")");
}

function setup() {
    var abiArray = [];
    var contract = web3.eth.contract(abiArray).at("0x0");

    var myNumGems;
		var myGems;

    contract.myBalance({from: web3.eth.accounts[0]}, function(error, result) {
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
			contract.myBalance({from: web3.eth.accounts[0]}, function(error, result) {
				if (!error) {
				  myNumGems = result;
				} else {
				  console.error(error);
				}
			});

			if (myGems != 0) {
				// Then, if we have any, display them
				var i;
				for (i=0; i < myNumGems; i++){
					contract.getGem(i, {from: web3.eth.accounts[0]}, function(error, result) {
						if (!error) {
						  $("#gem-display").append("<div class='col-sm'>Gem"+i+"</div>")
						} else {
						  console.error(error);
						}
					});
				}
			}
		}

    refresh();
    setInterval(refresh, 10000);
}

window.addEventListener("load", function() {
    if (typeof web3 !== "undefined") {
        web3 = new Web3(web3.currentProvider);
        web3.version.getNetwork(function(error, result) {
            if (!error) {
                if (result == "1") {
									  console.log("Setting up...");
                    setup();
                }
            }
        });
    }
});

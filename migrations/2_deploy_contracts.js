var GemCore = artifacts.require("./GemCore.sol");

module.exports = function(deployer) {
  deployer.deploy(GemCore);
};

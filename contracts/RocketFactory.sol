pragma solidity ^0.4.2;

/***
   * Note: Since this contract handles contract creation by other contracts, it's deployment gas usage will be high depending on the amount of contracts it can create.
   * For the moment it supports the RocketPoolMini creations, but if more automatic contract creations are added, be wary of the gas for deployment as it may exceed the block gas limit
***/ 

import "./RocketHub.sol";
import "./RocketPoolMini.sol";
import "./contract/Owned.sol";


/// @title Where we build the rockets! New contracts created by Rocket Pool are done here so they can be tracked.
/// @author David Rugendyke

contract RocketFactory is Owned {

	/**** Properties ***********/

    // Address of the main RocketHub contract
    address private rocketHubAddress;
    // Our rocket factory contracts
    mapping (address => Contract) public contracts;
    // Keep an array of all our contract addresses for iteration
    address[] public contractAddresses;


    /*** Structs ***************/

    struct Contract {
        address contractAddress;
        bytes32 name;
        uint256 created;
        bool exists;
    }


    /*** Modifiers ***************/

    /// @dev Only allow access from the latest version of the RocketPool contract
    modifier onlyLatestRocketPool() {
        RocketHub rocketHub = RocketHub(rocketHubAddress);
        if (msg.sender != rocketHub.getRocketPoolAddress()) throw;
        _;
    }


    /*** Methods ***************/

    /// @dev RocketFactory constructor
    function RocketFactory(address currentRocketHubAddress) {
        // Address of the main RocketHub contract, should never need updating
        rocketHubAddress = currentRocketHubAddress;
    }


    /// @dev Create a new RocketPoolMini contract, deploy to the etherverse and return the address to the caller
    /// @dev Note that the validation and logic for creation should be done in the calling contract
    /// @param miniPoolStakingDuration The staking duration for the mini pool
    function createRocketPoolMini(uint256 miniPoolStakingDuration) public onlyLatestRocketPool returns(address) {
        // Create the new pool and add it to our list
        RocketPoolMini newPoolAddress = new RocketPoolMini(rocketHubAddress, miniPoolStakingDuration);
        // Store it now after a few checks
        if(addContract(sha3('rocketMiniPool'), newPoolAddress)) {
            return newPoolAddress;
        }
    } 

    /// @dev Add the contract to our list of contract created contracts
    /// @param newName The type/name of this contract
    /// @param newContractAddress The address of this contract
    function addContract(bytes32 newName, address newContractAddress) private returns(bool) {
         // Basic error checking for the storage
        if (newContractAddress != 0 && contracts[newContractAddress].exists == false) {
            // Add the new contract to the mapping of Contract structs
            contracts[newContractAddress] = Contract({
                contractAddress: newContractAddress,
                name: newName,
                created: now,
                exists: true
            });
            // Store our contract address so we can iterate over it if needed
            contractAddresses.push(newContractAddress);
            // Success
            return true;
        }
        return false;
    } 

 


}

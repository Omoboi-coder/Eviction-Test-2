// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/Modules/ProposalModule.sol";
import "../src/Modules/AuthLayer.sol";
import "../src/Modules/TimelockModule.sol";
import "../src/Modules/RewardDistributor.sol";
import "../src/Core/MyAresTreasury.sol";

contract Deploy is Script {

    function run() external {
        vm.startBroadcast();

      
        address governance = msg.sender;

    
        address[] memory guardians = new address[](1);
        guardians[0] = msg.sender;

        ProposalModule    proposalModule    = new ProposalModule(governance);
        AuthLayer         authLayer         = new AuthLayer(governance, 1, guardians);
        TimelockModule    timelockModule    = new TimelockModule(governance);
        RewardDistributor rewardDistributor = new RewardDistributor(governance);

       
        AresTreasury treasury = new AresTreasury(
            governance,
            address(proposalModule),
            address(authLayer),
            address(timelockModule),
            address(rewardDistributor)
        );

        vm.stopBroadcast();
    }
}
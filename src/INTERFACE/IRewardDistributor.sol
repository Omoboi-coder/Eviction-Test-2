// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

interface IRewardDistributor {
    //Events
    event EpochDistributionStarted(uint256 indexed epochId, address tokenAddress, bytes32 merkleRoot, uint256 totalRewardPool);

    event RewardClaimed(uint256 indexed epochId, address indexed userAddress, uint256 amountClaimed);
// Functions
    function initializeRewardEpoch(address tokenAddress, bytes32 merkleRoot, uint256 totalRewardPool) external returns (uint256);

    function claim(uint256 epochId, uint256 totalAmountEarned, bytes32[] calldata merkleProofArray) external;
}

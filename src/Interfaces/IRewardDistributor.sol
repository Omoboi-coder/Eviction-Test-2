// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IRewardDistributor {

    event EpochStarted(uint256 indexed epochId, bytes32 merkleRoot, uint256 totalAmount);
    event RewardClaimed(uint256 indexed epochId, address indexed claimant, uint256 amount);

    function startEpoch(
        address token,
        bytes32 merkleRoot,
        uint256 totalAmount
    ) external returns (uint256 epochId);

    function claim(
        uint256 epochId,
        uint256 amount,
        bytes32[] calldata proof
    ) external;
}
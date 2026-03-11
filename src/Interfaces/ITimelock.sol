// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ITimelock {

    event ProposalQueued(bytes32 indexed proposalId, uint256 unlockTime);
    event ProposalDischarged(bytes32 indexed proposalId);

    function enqueue(bytes32 proposalId) external;

    function discharge(bytes32 proposalId) external;

    function isReady(bytes32 proposalId) external view returns (bool);
}
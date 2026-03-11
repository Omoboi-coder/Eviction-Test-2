// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IProposalSystem {

    event ProposalLodged(bytes32 indexed proposalId, address indexed proposer);
    event ProposalCommitted(bytes32 indexed proposalId);
    event ProposalCancelled(bytes32 indexed proposalId);

    function lodgeTransfer(
        address token,
        address recipient,
        uint256 amount
    ) external payable returns (bytes32 proposalId);

    function lodgeCall(
        address target,
        bytes calldata callData,
        uint256 value
    ) external payable returns (bytes32 proposalId);

    function lodgeUpgrade(
        address target,
        bytes calldata callData
    ) external payable returns (bytes32 proposalId);

    function cancel(bytes32 proposalId) external;

    function commit(bytes32 proposalId) external;

    function getProposal(bytes32 proposalId) external view returns (
        address proposer,
        address target,
        uint8 stage,
        uint256 createdAt,
        bool executed
    );
}
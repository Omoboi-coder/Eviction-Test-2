// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "../Interfaces/IProposalSystem.sol";
import "../Libraries/ProposalLib.sol";
import "../Libraries/Errors.sol";

// I was able to implement this Module by doing serious Research!!

contract ProposalModule is IProposalSystem {
    using ProposalLib for ProposalLib.Proposal;

    address public governance;

    uint256 public constant PROPOSAL_BOND = 0.01 ether;

    uint256 private nonce;

    mapping(bytes32 => ProposalLib.Proposal) public proposals;

    constructor(address _governance) {
        governance = _governance;
    }

    modifier onlyGovernance() {
        if (msg.sender != governance) revert Errors.OnlyGovernance(msg.sender);
        _;
    }

    function lodgeTransfer(
        address token,
        address recipient,
        uint256 amount
    ) external payable returns (bytes32 proposalId) {
        if (msg.value < PROPOSAL_BOND)
            revert Errors.InsufficientBond(msg.value, PROPOSAL_BOND);

        bytes memory callData = abi.encode(token, recipient, amount);
        proposalId = _lodge(recipient, callData, 0);
    }

    //fucntion for call proposal
    function lodgeCall(
        address target,
        bytes calldata callData,
        uint256 value
    ) external payable returns (bytes32 proposalId) {
        if (msg.value < PROPOSAL_BOND)
            revert Errors.InsufficientBond(msg.value, PROPOSAL_BOND);

        proposalId = _lodge(target, callData, value);
    }

    function lodgeUpgrade(
        address target,
        bytes calldata callData
    ) external payable returns (bytes32 proposalId) {
        if (msg.value < PROPOSAL_BOND)
            revert Errors.InsufficientBond(msg.value, PROPOSAL_BOND);

        proposalId = _lodge(target, callData, 0);
    }

    function _lodge(
        address target,
        bytes memory callData,
        uint256 value
    ) internal returns (bytes32 proposalId) {
        nonce++;
        proposalId = ProposalLib.computeId(msg.sender, target, callData, nonce);

        if (proposals[proposalId].createdAt != 0)
            revert Errors.DuplicateProposal(proposalId);

        // my strct values
        proposals[proposalId] = ProposalLib.Proposal({
            id: proposalId,
            proposer: msg.sender,
            target: target,
            callData: callData,
            value: value,
            bond: msg.value,
            createdAt: block.timestamp,
            queuedAt: 0,
            stage: ProposalLib.DRAFT,
            executed: false
        });

        emit ProposalLodged(proposalId, msg.sender);
    }

    function commit(bytes32 proposalId) external onlyGovernance {
        ProposalLib.Proposal storage p = _getProposal(proposalId);

        if (p.stage != ProposalLib.DRAFT)
            revert Errors.WrongStage(proposalId, p.stage);
        if (p.isDraftExpired()) revert Errors.ProposalExpired(proposalId);

        p.commit();
        emit ProposalCommitted(proposalId);
    }

    function cancel(bytes32 proposalId) external {
        ProposalLib.Proposal storage p = _getProposal(proposalId);

        if (msg.sender != p.proposer) revert Errors.NotProposer(msg.sender);
        if (p.stage == ProposalLib.CLOSED)
            revert Errors.WrongStage(proposalId, p.stage);

        if (p.stage == ProposalLib.DRAFT) {
            uint256 bond = p.bond;
            p.bond = 0;
            p.close();
            (bool success, ) = msg.sender.call{value: bond}("");
            require(success, "Transfer failed");
        } else {
            p.close();
           
        }

        emit ProposalCancelled(proposalId);
    }

    function getProposal(
        bytes32 proposalId
    )
        external
        view
        returns (
            address proposer,
            address target,
            uint8 stage,
            uint256 createdAt,
            bool executed
        )
    {
        ProposalLib.Proposal storage p = _getProposal(proposalId);
        return (p.proposer, p.target, p.stage, p.createdAt, p.executed);
    }

    function _getProposal(
        bytes32 proposalId
    ) internal view returns (ProposalLib.Proposal storage) {
        ProposalLib.Proposal storage p = proposals[proposalId];
        if (p.createdAt == 0) revert Errors.ProposalNotFound(proposalId);
        return p;
    }
}

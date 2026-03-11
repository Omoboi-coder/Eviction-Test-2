// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../Interfaces/ITimelock.sol";
import "../Libraries/ProposalLib.sol";
import "../Libraries/Errors.sol";

contract TimelockModule is ITimelock {

    address public governance;
    uint256 public constant DELAY = 2 days;

    mapping(bytes32 => uint256) public queuedAt;
    mapping(bytes32 => bool) public executed;

    bool private locked;

    modifier noReentrant() {
        if (locked) revert Errors.NoReentrancy();
        locked = true;
        _;
        locked = false;
    }

    modifier onlyGovernance() {
        if (msg.sender != governance) revert Errors.OnlyGovernance(msg.sender);
        _;
    }

    constructor(address _governance) {
        governance = _governance;
    }

    function enqueue(bytes32 proposalId) external onlyGovernance {
        queuedAt[proposalId] = block.timestamp;
        emit ProposalQueued(proposalId, block.timestamp + DELAY);
    }

    function discharge(
        bytes32 proposalId,
        address target,
        uint256 value,
        bytes calldata callData
    ) external noReentrant {
        if (queuedAt[proposalId] == 0) revert Errors.ProposalNotFound(proposalId);

        uint256 unlockTime = queuedAt[proposalId] + DELAY;
        if (block.timestamp < unlockTime) revert Errors.TooEarly(unlockTime, block.timestamp);
        if (block.timestamp > unlockTime + 48 hours) revert Errors.ExecutionWindowClosed(proposalId);
        if (executed[proposalId]) revert Errors.WrongStage(proposalId, ProposalLib.CLOSED);

        executed[proposalId] = true;

        (bool success, ) = target.call{value: value}(callData);
        require(success, "execution failed");

        emit ProposalDischarged(proposalId);
    }

    function isReady(bytes32 proposalId) external view returns (bool) {
        if (queuedAt[proposalId] == 0) return false;
        uint256 unlockTime = queuedAt[proposalId] + DELAY;
        return block.timestamp >= unlockTime && block.timestamp <= unlockTime + 48 hours;
    }

    receive() external payable {}
}
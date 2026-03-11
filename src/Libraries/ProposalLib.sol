// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;


// this library holds the proposal struct and all the stage logic
// i kept it separate so the main module doesnt get too much and messy


library ProposalLib {

    uint8 internal constant DRAFT      = 0;
    uint8 internal constant COMMITTED  = 1;
    uint8 internal constant QUEUED     = 2;
    uint8 internal constant EXECUTABLE = 3;
    uint8 internal constant CLOSED     = 4;

    struct Proposal {
        bytes32 id;
        address proposer;
        address target;
        bytes callData;
        uint256 value;
        uint256 bond;
        uint256 createdAt;
        uint256 queuedAt;
        uint8 stage;
        bool executed;
    }

    function computeId(
        address proposer,
        address target,
        bytes memory callData,
        uint256 nonce
    ) internal pure returns (bytes32) {
        return keccak256(abi.encode(proposer, target, callData, nonce));
    }

    function isDraftExpired(Proposal storage p) internal view returns (bool) {
        return p.stage == DRAFT && block.timestamp > p.createdAt + 7 days;
    }

    function isExecutionWindowOpen(
        Proposal storage p,
        uint256 timelockDelay
    ) internal view returns (bool) {
        if (p.stage != EXECUTABLE) return false;
        uint256 unlockTime = p.queuedAt + timelockDelay;
        uint256 windowEnd  = unlockTime + 48 hours;
        return block.timestamp >= unlockTime && block.timestamp <= windowEnd;
    }

    function commit(Proposal storage p) internal {
        p.stage = COMMITTED;
    }

    function enqueue(Proposal storage p) internal {
        p.stage    = QUEUED;
        p.queuedAt = block.timestamp;
    }

    function markExecutable(Proposal storage p) internal {
        p.stage = EXECUTABLE;
    }

    function close(Proposal storage p) internal {
        p.stage = CLOSED;
    }
}
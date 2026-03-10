// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

interface ITimelock {
    event TimelockScheduled(bytes32 indexed actionHash, uint256 matureTimestamp);
    event TimelockDischarged(bytes32 indexed actionHash);

    function hashAction(uint256 proposalId, address targetAddress, uint256 callValue, bytes calldata callData) external pure returns (bytes32);

    function scheduleOperation(uint256 proposalId, address targetAddress, uint256 callValue, bytes calldata callData) external;

    function pullTrigger(uint256 proposalId, address targetAddress, uint256 callValue, bytes calldata callData) external;
}

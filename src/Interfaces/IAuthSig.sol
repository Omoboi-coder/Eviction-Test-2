// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IAuthSig {

    event GuardianSigned(bytes32 indexed proposalId, address indexed guardian);

    function approve(
        bytes32 proposalId,
        uint256 nonce,
        bytes calldata signature
    ) external;

    function hasQuorum(bytes32 proposalId) external view returns (bool);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../Interfaces/IAuthSig.sol";
import "../Libraries/SignatureLib.sol";
import "../Libraries/Errors.sol";

contract AuthLayer is IAuthSig {

    address public governance;
    uint256 public quorum;

    mapping(address => bool) public isGuardian;
    mapping(bytes32 => uint256) public approvalCount;
    mapping(bytes32 => mapping(address => bool)) public hasSigned;
    mapping(address => mapping(uint256 => bool)) public usedNonces;

    constructor(address _governance, uint256 _quorum, address[] memory _guardians) {
        governance = _governance;
        quorum     = _quorum;

        for (uint256 i = 0; i < _guardians.length; i++) {
            isGuardian[_guardians[i]] = true;
        }
    }

    function approve(
        bytes32 proposalId,
        uint256 nonce,
        bytes calldata signature
    ) external {
        if (!isGuardian[msg.sender]) revert Errors.NotGuardian(msg.sender);
        if (usedNonces[msg.sender][nonce]) revert Errors.NonceAlreadyUsed(msg.sender, nonce);
        if (hasSigned[proposalId][msg.sender]) revert Errors.NotEnoughApprovals(0, quorum);

        address signer = SignatureLib.getSignerAddress(
            proposalId,
            nonce,
            block.chainid,
            address(this),
            signature
        );

        if (signer != msg.sender) revert Errors.BadSignature(signer, msg.sender);

        usedNonces[msg.sender][nonce]     = true;
        hasSigned[proposalId][msg.sender] = true;
        approvalCount[proposalId]++;

        emit GuardianSigned(proposalId, msg.sender);
    }

    function hasQuorum(bytes32 proposalId) external view returns (bool) {
        return approvalCount[proposalId] >= quorum;
    }
}
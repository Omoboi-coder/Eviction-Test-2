// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IAuthSig{
    event SignerEndorsed(uint256 indexed proposalId, address indexed signerAddress);
    
    function verifySignature(
        uint256 proposalId, 
        address expectedSignerAddress, 
        uint256 uniqueNonce, 
        uint256 signatureDeadline, 
        bytes calldata digitalSignature
    ) external;
    
// Function
    function hasReachedQuorum(uint256 proposalId) external view returns (bool);
}

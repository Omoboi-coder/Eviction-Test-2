// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

library MerkleLib {

    // This takes a proof, a root and a leaf
    // returns true if the leaf is in the tree
    // leaf is the hash of the person address and their amount
    function verify(
        bytes32[] calldata proof,
        bytes32 root,
        bytes32 leaf
    ) internal pure returns (bool) {
        bytes32 computed = leaf;

        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];

            // this makes sure my    proof works regardless of how they are arranged in the tree
            if (computed <= proofElement) {
                computed = keccak256(abi.encodePacked(computed, proofElement));
            } else {
                computed = keccak256(abi.encodePacked(proofElement, computed));
            }
        }

        return computed == root;
    }

    function buildLeaf(
        address claimant,
        uint256 amount
    ) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(claimant, amount));
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// I was able to do this library by doing serious research.....

library SignatureLib {

    function getSignerAddress(
        bytes32 proposalId,
        uint256 nonce,
        uint256 chainId,
        address contractAddress,
        bytes calldata signature
    ) internal pure returns (address) {

        bytes32 digest = keccak256(abi.encodePacked(
            "\x19Ethereum Signed Message:\n32",
            keccak256(abi.encode(
                proposalId,
                nonce,
                chainId,
                contractAddress
            ))
        ));

        // split signature into its 3 parts
        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := calldataload(signature.offset)
            s := calldataload(add(signature.offset, 32))
            v := byte(0, calldataload(add(signature.offset, 64)))
        }

        // recover and return the signer
        return ecrecover(digest, v, r, s);
    }
}
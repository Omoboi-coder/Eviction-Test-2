// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../Interfaces/IRewardDistributor.sol";
import "../Libraries/MerkleLib.sol";
import "../Libraries/Errors.sol";

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
}

contract RewardDistributor is IRewardDistributor {

    address public governance;

    struct Epoch {
        address token;
        bytes32 merkleRoot;
        uint256 totalAmount;
    }

    uint256 public currentEpochId;

    mapping(uint256 => Epoch) public epochs;
    mapping(uint256 => mapping(address => bool)) public claimed;

    modifier onlyGovernance() {
        if (msg.sender != governance) revert Errors.OnlyGovernance(msg.sender);
        _;
    }

    constructor(address _governance) {
        governance = _governance;
    }

    function startEpoch(
        address token,
        bytes32 merkleRoot,
        uint256 totalAmount
    ) external onlyGovernance returns (uint256 epochId) {
        if (merkleRoot == bytes32(0)) revert Errors.NoActiveRoot();

        currentEpochId++;
        epochId = currentEpochId;

        epochs[epochId] = Epoch({
            token:       token,
            merkleRoot:  merkleRoot,
            totalAmount: totalAmount
        });

        emit EpochStarted(epochId, merkleRoot, totalAmount);
    }

    function claim(
        uint256 epochId,
        uint256 amount,
        bytes32[] calldata proof
    ) external {
        Epoch storage epoch = epochs[epochId];

        if (epoch.merkleRoot == bytes32(0)) revert Errors.NoActiveRoot();
        if (claimed[epochId][msg.sender]) revert Errors.AlreadyClaimed(msg.sender);

        bytes32 leaf = MerkleLib.buildLeaf(msg.sender, amount);
        if (!MerkleLib.verify(proof, epoch.merkleRoot, leaf)) revert Errors.InvalidProof(msg.sender, amount);

        claimed[epochId][msg.sender] = true;

        bool success = IERC20(epoch.token).transfer(msg.sender, amount);
        if (!success) revert Errors.TransferFailed(epoch.token, msg.sender, amount);

        emit RewardClaimed(epochId, msg.sender, amount);
    }
}
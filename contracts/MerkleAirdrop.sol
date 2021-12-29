//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract MerkleAirdrop is Ownable {
    bytes32 public merkleRoot;
    bool public cancelable;
    mapping(uint256 => uint256) private claimedBitMap;

    event Claimed(uint256 idx, address addr, uint256 num);

    modifier isCancelable() {
        require(cancelable, "forbidden action");
        _;
    }

    constructor(bytes32 _merkleRoot, bool _cancelable) {
        merkleRoot = _merkleRoot;
        cancelable = _cancelable;
    }

    receive() external payable {}

    function isClaimed(uint256 index) public view returns (bool) {
        uint256 claimedWordIndex = index / 256;
        uint256 claimedBitIndex = index % 256;
        uint256 claimedWord = claimedBitMap[claimedWordIndex];
        uint256 mask = (1 << claimedBitIndex);
        return claimedWord & mask == mask;
    }

    function _setClaimed(uint256 index) private {
        uint256 claimedWordIndex = index / 256;
        uint256 claimedBitIndex = index % 256;
        claimedBitMap[claimedWordIndex] = claimedBitMap[claimedWordIndex] | (1 << claimedBitIndex);
    }

    function claim(uint256 index, address account, uint256 amount, bytes32[] calldata merkleProof) external {
        require(!isClaimed(index), "Drop already claimed.");

        // Verify the merkle proof.
        bytes32 node = keccak256(abi.encodePacked(index, account, amount));
        require(MerkleProof.verify(merkleProof, merkleRoot, node), "Invalid proof.");

        // Mark it claimed and send the token.
        _setClaimed(index);
        Address.sendValue(payable(account), amount);

        emit Claimed(index, account, amount);
    }

    function setRoot(bytes32 _merkleRoot) public onlyOwner {
        merkleRoot = _merkleRoot;
    }

    function closeAirdrop() public isCancelable onlyOwner returns(bool) {
        require(address(this).balance >= 0, "No balance");
        Address.sendValue(payable(owner()), address(this).balance);
        return true;
    }
}

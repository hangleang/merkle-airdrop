import { ethers } from "hardhat";
import { utils } from "ethers";

import * as whitelist from "../whitelist.json";
import { MerkleTree } from "merkletreejs";
import keccak256 from "keccak256";
async function main() {
  // equal to MerkleAirdrop.sol #keccak256(abi.encodePacked(index, account, amount));
  const elements = whitelist.users.map((x, i) =>
  utils.solidityKeccak256(["uint256", "address", "uint256"], [i, x.address, x.amount])
  ); 
  const merkleTree = new MerkleTree(elements, keccak256, { sort: true });
  elements.forEach(element => {
  console.log(merkleTree.getHexProof(element))
  });
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
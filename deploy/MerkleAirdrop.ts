import { HardhatRuntimeEnvironment } from 'hardhat/types'
import { DeployFunction } from 'hardhat-deploy/types'
import { utils } from "ethers";
import * as data from '../whitelist.json';

import { MerkleTree } from "merkletreejs";
import keccak256 from "keccak256";

const deploy: DeployFunction = async (hre: HardhatRuntimeEnvironment) => {
  const { deployments, getUnnamedAccounts } = hre
  const { deploy } = deployments
  const [ deployer ] = await getUnnamedAccounts()

  // equal to MerkleAirdrop.sol #keccak256(abi.encodePacked(index, account, amount));
  const elements = data.users.map((x, i) =>
    utils.solidityKeccak256(["uint256", "address", "uint256"], [i, x.address, x.amount])
  ); 
  const merkleTree = new MerkleTree(elements, keccak256, { sort: true });
  const root = merkleTree.getHexRoot();

  await deploy('MerkleAirdrop', {
    from: deployer,
    args: [
      root,
      true
    ],
    log: true,
    deterministicDeployment: false
  })
}

deploy.tags = ['MerkleAirdrop']
export default deploy
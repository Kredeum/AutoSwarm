import { getContract, type Address, type ReadContractReturnType } from "viem";
import erc20 from "@autoswarm/contracts/out/IERC20.sol/IERC20.json";

import { addressesGetField } from "../common/addresses";
import { callPublicClient } from "./call";

const _params = async (bzzChainId: number) => {
  const address = addressesGetField(bzzChainId, "BzzToken");
  const abi = erc20.abi;
  const client = await callPublicClient(bzzChainId);
  return { address, abi, client };
};

const callBzzBalance = async (bzzChainId: number, account?: Address): Promise<bigint | undefined> => {
  if (account === undefined) return;

  const bzzContract = getContract(await _params(bzzChainId));

  return (await bzzContract.read.balanceOf([account])) as bigint;
};

export { callBzzBalance };

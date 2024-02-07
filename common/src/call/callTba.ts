import type { Address, Hex } from "viem";
import { callIsContract, callPublicClient } from "./call";
import { ZERO_BYTES32 } from "../constants/constants";
import autoSwarmAccount from "@autoswarm/contracts/out/AutoSwarmAccount.sol/AutoSwarmAccount.json";

const callTbaBzzStampId = async (bzzChainId: number, tba: Address | undefined): Promise<Hex> => {
  if (!(tba && (await callIsContract(bzzChainId, tba)))) return ZERO_BYTES32;

  const publicClient = await callPublicClient(bzzChainId);

  return (await publicClient.readContract({
    address: tba,
    abi: autoSwarmAccount.abi,
    functionName: "stampId",
  })) as Hex;
};

const callTbaSwarmHash = async (bzzChainId: number, tba: Address | undefined): Promise<Hex | undefined> => {
  if (!(tba && (await callIsContract(bzzChainId, tba)))) return;

  const publicClient = await callPublicClient(bzzChainId);

  return (await publicClient.readContract({
    address: tba,
    abi: autoSwarmAccount.abi,
    functionName: "swarmHash",
  })) as Hex;
};

const callTbaSwarmSize = async (bzzChainId: number, tba: Address | undefined): Promise<bigint> => {
  if (!(tba && (await callIsContract(bzzChainId, tba)))) return 0n;

  const publicClient = await callPublicClient(bzzChainId);

  return (await publicClient.readContract({
    address: tba,
    abi: autoSwarmAccount.abi,
    functionName: "swarmSize",
  })) as bigint;
};

const callTbaToken = async (bzzChainId: number, tba: Address): Promise<readonly [bigint, Address, bigint]> => {
  const publicClient = await callPublicClient(bzzChainId);

  return (await publicClient.readContract({
    address: tba,
    abi: autoSwarmAccount.abi,
    functionName: "token",
  })) as readonly [bigint, Address, bigint];
};

export { callTbaSwarmHash, callTbaSwarmSize, callTbaBzzStampId, callTbaToken };

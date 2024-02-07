import type { Hex } from "viem";

import { addressesGetField } from "../common/addresses";
import { callPublicClient } from "./call";

import autoSwarmMarket from "@autoswarm/contracts/out/AutoSwarmMarket.sol/AutoSwarmMarket.json";

const callMarketCurrentBatchId = async (bzzChainId: number): Promise<Hex> => {
  const publicClient = await callPublicClient(bzzChainId);

  return (await publicClient.readContract({
    address: addressesGetField(bzzChainId, "AutoSwarmMarket"),
    abi: autoSwarmMarket.abi,
    functionName: "currentBatchId",
  })) as Hex;
};

const callMarketCurrentNodeOwner = async (bzzChainId: number): Promise<Hex> => {
  const publicClient = await callPublicClient(bzzChainId);

  return (await publicClient.readContract({
    address: addressesGetField(bzzChainId, "AutoSwarmMarket"),
    abi: autoSwarmMarket.abi,
    functionName: "currentNodeOwner",
  })) as Hex;
};

const callMarketStampToBatchId = async (bzzChainId: number, stampId: Hex): Promise<Hex> => {
  const publicClient = await callPublicClient(bzzChainId);

  return (await publicClient.readContract({
    address: addressesGetField(bzzChainId, "AutoSwarmMarket"),
    abi: autoSwarmMarket.abi,
    functionName: "stampToBatchId",
    args: [stampId],
  })) as Hex;
};

const callMarketNewBatchNeeded = async (bzzChainId: number): Promise<boolean> => {
  const publicClient = await callPublicClient(bzzChainId);

  return (await publicClient.readContract({
    address: addressesGetField(bzzChainId, "AutoSwarmMarket"),
    abi: autoSwarmMarket.abi,
    functionName: "newBatchNeeded",
  })) as boolean;
};

const callMarketCurrentBatchFilling = async (bzzChainId: number): Promise<bigint> => {
  const publicClient = await callPublicClient(bzzChainId);

  return (await publicClient.readContract({
    address: addressesGetField(bzzChainId, "AutoSwarmMarket"),
    abi: autoSwarmMarket.abi,
    functionName: "currentBatchFilling",
  })) as bigint;
};

export { callMarketNewBatchNeeded, callMarketCurrentNodeOwner, callMarketCurrentBatchId, callMarketStampToBatchId, callMarketCurrentBatchFilling };

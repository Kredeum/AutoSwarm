import type { Address, Hex } from "viem";

import { addressesGetField } from "../common/addresses";
import { callPublicClient } from "./call";
import { BUCKET_DEPTH } from "../constants/constants";
import { utilsIsNullBytes32 } from "../common/utils";

import postageStamp from "@autoswarm/contracts/out/PostageStamp.sol/PostageStamp.json";

//////////////////////////////////////////////////////////////////////////////////////////////////////
// READ : onchain view functions reading the chain via rpc, i.e. functions with publicClient as parameter
//////////////////////////////////////////////////////////////////////////////////////////////////////

const callPostageBatches = async (bzzChainId: number, batchId: Hex): Promise<[Address, number, number, boolean, bigint, bigint]> => {
  // console.info('callPostageBatches', batchId);

  const publicClient = await callPublicClient(bzzChainId);

  const [owner, depth, bucketDepth, immutableFlag, normalisedBalance, lastUpdatedBlockNumber] = (await publicClient.readContract({
    address: addressesGetField(bzzChainId, "PostageStamp"),
    abi: postageStamp.abi,
    functionName: "batches",
    args: [batchId],
  })) as [Address, number, number, boolean, bigint, bigint];

  return [owner, depth, bucketDepth, immutableFlag, normalisedBalance, lastUpdatedBlockNumber];
};

const callPostageCurrentTotalOutPayment = async (bzzChainId: number): Promise<bigint> => {
  const publicClient = await callPublicClient(bzzChainId);

  return (await publicClient.readContract({
    address: addressesGetField(bzzChainId, "PostageStamp"),
    abi: postageStamp.abi,
    functionName: "currentTotalOutPayment",
  })) as bigint;
};

const callPostageLastPrice = async (bzzChainId: number): Promise<bigint> => {
  const publicClient = await callPublicClient(bzzChainId);

  return (await publicClient.readContract({
    address: addressesGetField(bzzChainId, "PostageStamp"),
    abi: postageStamp.abi,
    functionName: "lastPrice",
  })) as bigint;
};

const callPostageRemainingBalance = async (bzzChainId: number, batchId: Hex): Promise<bigint | undefined> => {
  if (utilsIsNullBytes32(batchId)) return;

  const publicClient = await callPublicClient(bzzChainId);

  const data = await publicClient.readContract({
    address: addressesGetField(bzzChainId, "PostageStamp"),
    abi: postageStamp.abi,
    functionName: "remainingBalance",
    args: [batchId],
  });

  return data as bigint;
};

export { callPostageBatches, callPostageLastPrice, callPostageRemainingBalance, callPostageCurrentTotalOutPayment };

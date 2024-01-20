import { autoSwarmMarketAbi } from "../constants/abis";
import { sendWallet } from "./send";
import { addressesGetField } from "../common/addresses";
import type { Hex } from "viem";

const sendMarketNewBatch = async (bzzChainId: number, bzzAmount: bigint) => {
  const [publicClient, walletClient, walletAddress] = await sendWallet(bzzChainId);

  const { request } = await publicClient.simulateContract({
    account: walletAddress,
    address: addressesGetField(bzzChainId, "AutoSwarmMarket"),
    abi: autoSwarmMarketAbi,
    functionName: "newBatch",
    args: [bzzAmount],
  });
  const hash = await walletClient.writeContract(request);
  await publicClient.waitForTransactionReceipt({ hash });
};

const sendMarketSync = async (bzzChainId: number) => {
  const [publicClient, walletClient, walletAddress] = await sendWallet(bzzChainId);

  const { request } = await publicClient.simulateContract({
    account: walletAddress,
    address: addressesGetField(bzzChainId, "AutoSwarmMarket"),
    abi: autoSwarmMarketAbi,
    functionName: "sync",
  });
  const hash = await walletClient.writeContract(request);
  await publicClient.waitForTransactionReceipt({ hash });
};

const sendMarketAttachStamps = async (bzzChainId: number, stampIds: readonly Hex[], batchId: Hex) => {
  if (stampIds.length === 0) return;
  const [publicClient, walletClient, walletAddress] = await sendWallet(bzzChainId);

  const { request } = await publicClient.simulateContract({
    account: walletAddress,
    address: addressesGetField(bzzChainId, "AutoSwarmMarket"),
    abi: autoSwarmMarketAbi,
    functionName: "attachStamps",
    args: [stampIds, batchId],
  });
  const hash = await walletClient.writeContract(request);
  await publicClient.waitForTransactionReceipt({ hash });
};

export { sendMarketNewBatch, sendMarketSync, sendMarketAttachStamps };

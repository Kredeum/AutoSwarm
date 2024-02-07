import type { Address, Hex } from "viem";
import { sendWallet } from "./send";
import { addressesGetField } from "../common/addresses";
import { BUCKET_DEPTH } from "../constants/constants";
import postageStamp from "@autoswarm/contracts/out/PostageStamp.sol/PostageStamp.json";

const sendPostageCreateBatch = async (bzzChainId: number, owner: Address, initialBalancePerChunk: bigint, depth: number, nonce: Hex) => {
  const [publicClient, walletClient, walletAddress] = await sendWallet(bzzChainId);

  const postageStampAddress = addressesGetField(bzzChainId, "PostageStamp");

  const { request } = await publicClient.simulateContract({
    account: walletAddress,
    address: postageStampAddress,
    abi: postageStamp.abi,
    functionName: "createBatch",
    args: [owner, initialBalancePerChunk, depth, BUCKET_DEPTH, nonce, false],
  });
  const hash = await walletClient.writeContract(request);
  await publicClient.waitForTransactionReceipt({ hash });
};

export { sendPostageCreateBatch };

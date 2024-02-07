import { type Address, zeroAddress, type Hex } from "viem";
import { sendWallet } from "./send";
import { ZERO_BYTES32 } from "../constants/constants";
import autoSwarmAccount from "@autoswarm/contracts/out/AutoSwarmAccount.sol/AutoSwarmAccount.json";

const sendTbaCreateStamp = async (bzzChainId: number, tba: Address, swarmHash = ZERO_BYTES32 as Hex, nftSize: bigint, bzzAmount: bigint) => {
  console.info("sendTbaCreateStamp:", bzzChainId, tba, swarmHash, nftSize);

  if (!(bzzChainId > 0)) throw new Error("Bad chain!");
  if (!tba) throw new Error("No TBA!");
  if (!nftSize) throw new Error("No Swarm Size!");
  if (!swarmHash) throw new Error("No Swarm Hash!");

  const [publicClient, walletClient, walletAddress] = await sendWallet(bzzChainId);

  const { request } = await publicClient.simulateContract({
    account: walletAddress,
    address: tba,
    abi: autoSwarmAccount.abi,
    functionName: "createStamp",
    args: [swarmHash, nftSize, bzzAmount],
  });

  const hash = await walletClient.writeContract(request);
  await publicClient.waitForTransactionReceipt({ hash });
};

const sendTbaTopUp = async (bzzChainId: number, tba: Address | undefined, bzzAmount: bigint) => {
  if (!(bzzChainId > 0)) throw new Error("Bad chain!");
  if (!tba) throw new Error("Bad TBA!");

  const [publicClient, walletClient, walletAddress] = await sendWallet(bzzChainId);

  const { request } = await publicClient.simulateContract({
    account: walletAddress,
    address: tba,
    abi: autoSwarmAccount.abi,
    functionName: "topUp",
    args: [bzzAmount],
  });
  const hash = await walletClient.writeContract(request);
  await publicClient.waitForTransactionReceipt({ hash });
};

const sendTbaWithdraw = async (bzzChainId: number, tba: Address, token = zeroAddress) => {
  if (!(bzzChainId > 0 && tba)) throw new Error("sendTbaWithdraw: No tba");

  const [publicClient, walletClient, walletAddress] = await sendWallet(bzzChainId);

  const { request } = await publicClient.simulateContract({
    account: walletAddress,
    address: tba,
    abi: autoSwarmAccount.abi,
    functionName: "withdraw",
    args: [token],
  });
  const hash = await walletClient.writeContract(request);
  await publicClient.waitForTransactionReceipt({ hash });
};

export { sendTbaTopUp, sendTbaWithdraw, sendTbaCreateStamp };

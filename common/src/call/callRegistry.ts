import type { Address, Hex } from "viem";
import { callPublicClient } from "./call";
import { addressesGetField } from "../common/addresses";
import { SALT } from "../constants/constants";
import erc6551Registry from "@autoswarm/contracts/out/Erc6551Registry.sol/Erc6551Registry.json";

const callRegistryAccount = async (bzzChainId: number, nftChainId: number, nftCollection: Address, nftTokenId: bigint): Promise<Address> => {
  console.info("callRegistryAccount start", bzzChainId, nftChainId, nftCollection, nftTokenId);

  const publicClient = await callPublicClient(bzzChainId);

  const erc6551RegistryAddress = addressesGetField(bzzChainId, "ERC6551Registry");
  const autoSwarmAccount = addressesGetField(bzzChainId, "AutoSwarmAccount");

  const tba = await publicClient.readContract({
    address: erc6551RegistryAddress,
    abi: erc6551Registry.abi,
    functionName: "account",
    args: [autoSwarmAccount, SALT, BigInt(nftChainId), nftCollection, nftTokenId],
  });
  console.log("callRegistryAccount ~ tba:", tba);

  return tba as Address;
};

export { callRegistryAccount };

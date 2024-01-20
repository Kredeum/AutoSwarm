<script lang="ts">
  import type { Address, Hex } from "viem";
  import { onMount } from "svelte";

  import { STAMP_PRICE } from "@autoswarm/common/src/constants/constants.js";
  import type { Metadata, NftMetadata, SwarmMetadata, TbaMetadata } from "@autoswarm/common/src/constants/types";

  import { callBlock } from "@autoswarm/common/src/call/call.js";

  import { sendBzzTransfer } from "@autoswarm/common/src/send/sendBzz";
  import { sendTbaCreateStamp, sendTbaTopUp } from "@autoswarm/common/src/send/sendTba";
  import { sendRegistryCreateAccount } from "@autoswarm/common/src/send/sendRegistry";
  import { displayBalance, displayDate, displayDuration } from "@autoswarm/common/src/display/display";

  import { utilsIsNullBytes32 } from "@autoswarm/common/src/common/utils.js";
  import { bzzChainId } from "@autoswarm/common/src/swarm/bzz";
  import { alertError, alertInfo, alertSuccess } from "@autoswarm/common/src/stores/alertMessage";

  import Nft from "./Nft.svelte";

  import { nftIds } from "@autoswarm/common/src/common/nft";
  import { fetchBeeMetadata } from "@autoswarm/common/src/fetch/fetchBeeMetadata";
  import DetailsNft from "../Details/DetailsNft.svelte";
  import DetailsBee from "../Details/DetailsBee.svelte";
  import DetailsTba from "../Details/DetailsTba.svelte";
  import DetailsWallet from "../Details/DetailsWallet.svelte";
  import { callTbaMetadata } from "@autoswarm/common/src/call/callTbaMetadata";

  ////////////////////// AutoSwarm Component /////////////////////////////////
  // <AutoSwarm {metadata} {nftMetadata} />
  //////////////////////////////////////////////////////////////////////////////
  export let metadata: Metadata;
  export let nftMetadata: NftMetadata;
  ////////////////////////////////////////////////////////////////////////////

  // Block
  let blockTimestamp: number = 0;
  let blockNumber: number = 0;

  let beeMetadata: SwarmMetadata = {};
  let tbaMetadata: TbaMetadata = {};

  let tbaDeployed: boolean | undefined;
  let tbaBalance = 0n;

  let tbaAddress: Address | undefined;
  let tbaPrice: bigint | undefined;
  let tbaSwarmHash: Hex | undefined;
  let tbaUntil: number | undefined;
  let tbaResaved: boolean | undefined;
  let tbaResavedGaranteed: boolean | undefined;
  let tbaResavedDuration = 0;
  let nftSize: bigint | undefined;

  // State
  let details = false;
  let resaving: number;
  let toping: number;

  const refresh = async () => {
    if (!($bzzChainId && nftMetadata)) return;
    console.info("<NftMetadata refresh  IN", $bzzChainId);

    try {
      tbaMetadata = await callTbaMetadata($bzzChainId, ...nftIds(nftMetadata));
      console.info("tbaMetadata", tbaMetadata);

      tbaBalance = tbaMetadata.tbaBalance || 0n;
      tbaPrice = tbaMetadata.tbaPrice || nftMetadata.nftPrice;
      tbaSwarmHash = beeMetadata.swarmHash || tbaMetadata.tbaSwarmHash;
      tbaResaved = !utilsIsNullBytes32(tbaMetadata.tbaStampId);
      tbaResavedGaranteed = !utilsIsNullBytes32(tbaMetadata.tbaBatchId);
      tbaResavedDuration = Number(tbaMetadata.tbaDuration);
      ({ tbaDeployed, tbaAddress } = tbaMetadata);

      // Block
      {
        const block = await callBlock($bzzChainId);
        blockTimestamp = Number(block.timestamp) || 0;
        blockNumber = Number(block.number) || 0;
      }
      tbaUntil = blockTimestamp + Number(tbaResavedDuration) || 0;
    } catch (e) {
      console.error("<NftMetadata refresh", e);
      alertError("NftMetadata Refresh Error", e);
    }
    console.info("<NftMetadata refresh OUT");
  };

  const reSave = async () => {
    console.info("reSave");

    try {
      if (resaving) throw new Error("Already ReSaving!");
      if (!tbaAddress) throw new Error("No Tba found");
      if (!nftSize) throw new Error("No Nft Size found");
      if (!tbaPrice) throw new Error("No Stamp Price found");

      if (utilsIsNullBytes32(tbaSwarmHash)) {
        resaving = 1;
        beeMetadata = await fetchBeeMetadata(nftMetadata);
        console.info("beeMetadata\n", beeMetadata);
        await refresh();
      }

      if (!tbaDeployed) {
        resaving = 2;
        alertInfo(`Confirm transaction to create Token Bound Account (TBA)`);
        await sendRegistryCreateAccount($bzzChainId, ...nftIds(nftMetadata));
        await refresh();
      }
      if (tbaBalance < tbaPrice) {
        resaving = 3;
        alertInfo(`Confirm transaction to transfer ${displayBalance(tbaPrice, 16, 3)} BZZ to TBA`);
        await sendBzzTransfer($bzzChainId, tbaAddress, tbaPrice);
        await refresh();
      }

      if (!tbaResaved) {
        resaving = 4;
        alertInfo(`Confirm transaction to setup your TBA`);
        await sendTbaCreateStamp($bzzChainId, tbaAddress, tbaSwarmHash, nftSize, tbaPrice);

        await refresh();
      }

      {
        resaving = 5;
        alertSuccess(`Your NFT has been ReSaved on Swarm! 🎉'`);
      }
    } catch (e) {
      alertError(`ReSave (${resaving - 1}/3) :`, e);
    }
    resaving = 0;
  };

  const topUp = async () => {
    console.info("topUp");

    try {
      if (toping) throw new Error("Already Topping Up!");
      if (!tbaAddress) throw new Error("No Tba found");
      if (!tbaPrice) throw new Error("No Stamp Price found");

      {
        toping = 1;
        alertInfo(`Confirm transfer of ${displayBalance(tbaPrice, 16, 3)} BZZ to TBA`);
        await sendBzzTransfer($bzzChainId, tbaAddress, tbaPrice);
        refresh();
      }

      {
        toping = 2;
        alertSuccess("Your NFT has been TopUped on Swarm! 🎉");
      }
    } catch (e) {
      alertError(`TopUp`, e);
    }

    toping = 0;
  };

  onMount(async () => {
    console.info("metadata:\n", metadata);
    console.info("nftMetadata:\n", nftMetadata);
    nftSize = nftMetadata.nftSize || 0n;

    refresh();
  });
</script>

<section id="resaver">
  <div class="nfts-grid">
    <Nft {metadata} {nftMetadata} />

    <div class="batch-topUp">
      {#if !tbaResaved}
        <button class="btn btn-topup" on:click="{reSave}">
          ReSave NFT
          {#if resaving}
            &nbsp;
            <i class="fa-solid fa-spinner fa-spin-pulse"></i> &nbsp; {resaving - 1}/3
          {/if}
        </button>
      {:else}
        <br />
        {#if tbaResavedDuration > 0}
          <button class="btn btn-storage">
            Storage {tbaResavedGaranteed ? "Guaranteed" : "Estimation"}
          </button>
          <br />
          <div class="batch-topUp-infos">
            <p>for</p>
            <p>{displayDuration(tbaResavedDuration)}</p>
            <p>until</p>
            <p>{displayDate(tbaUntil)}</p>
          </div>
        {:else}
          <button class="btn btn-storage">Storage NOT Guaranteed</button>
          <br />
        {/if}

        <br />

        <button class="btn btn-topup" on:click="{topUp}">
          TopUp 1 Year
          {#if toping}
            &nbsp;
            <i class="fa-solid fa-spinner fa-spin-pulse"></i>
          {/if}
        </button>
      {/if}
      <div class="batch-topUp-below">
        <p>Price: {displayBalance(tbaPrice, 16, 2)} Bzz</p>
        <p><small>({displayBalance(STAMP_PRICE, 16, 2)} BZZ / Mb / Year)</small></p>
      </div>
    </div>
  </div>
</section>

<br />
{#if tbaResaved}
  <p class="intro-text">Click on TopUp button to Increase NFT storage duration</p>
{:else}
  <p class="intro-text">Click on ReSave button to Save your NFT on Swarm</p>
{/if}
<br />

<p>
  <button class="btn" on:click="{() => (details = !details)}">
    {#if details}hide{/if} details
  </button>
</p>

{#if details}
  <div id="details">
    <hr />
    <DetailsNft {nftMetadata} />
    {#if beeMetadata.swarmHash}
      <hr />
      <DetailsBee {beeMetadata} />
    {/if}
    <hr />
    <DetailsTba {tbaMetadata} />
    <hr />
    <DetailsWallet />
    <hr />
  </div>
{/if}

<style>
  #details {
    width: 1100px;
    display: block;
    text-align: left;
  }
</style>

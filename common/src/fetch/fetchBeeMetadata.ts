import type { SwarmMetadata, NftMetadata } from "../constants/types";
import { fetchNftTar } from "../fetchBee/fetchNftTar";
import { fetchBeeTarPost } from "../fetchBee/fetchBeeTar";

import { beeOk } from "../swarm/bee";
import { utilsIsNullBytes32 } from "../common/utils";
import { bzzImageName } from "../swarm/bzz";

const fetchBeeMetadata = async (nftAutoSwarm: NftMetadata): Promise<SwarmMetadata> => {
  if (!(await beeOk())) return {};

  const beeMetadata: SwarmMetadata = {};

  const [body] = await fetchNftTar([nftAutoSwarm.nftImageUri, nftAutoSwarm.nftMetadataUri]);

  const swarmHash = await fetchBeeTarPost(body);
  if (!utilsIsNullBytes32(swarmHash)) {
    beeMetadata.swarmHash = swarmHash;
    const imageName = await bzzImageName(swarmHash);
    if (imageName) beeMetadata.swarmImageName = imageName;
  }

  return beeMetadata;
};

export { fetchBeeMetadata };

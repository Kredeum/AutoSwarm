---
marp: true
theme: default
---

### Sync :

1. If not before overlapping period Buy a new Batch (that becomes current Batch)

1. List N NFTs stamps to attach (or re-attach) to current Batch
1. For each NFT Stamp:
  1. Checks NFT Size and Swarm Hash with a dedicated Swarm node, reset it if needed (NFT changed, or falsy)
  1. Transfer payment of the Stamp from the TBA to the Market
  1. Attach the Stamp to the current Market Batch: mapping StampId to BatchId


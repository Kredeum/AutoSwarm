---
marp: true
theme: default
paginate: true
footer: AutoSwarm NFTs Stamper - Swarm Grant #xx
_paginate: false
_footer: ""
_class: invert
---

# AutoSwarm NFTs Stamper (2/3)

## _Empowering Eternal Digital Ownership_

&nbsp;

&nbsp;


### 7th November 2023

---
# AutoSwarm Schedule (3 grants)

### 1/3 : AutoSwarm PoC (done)
AutoSwarm demo via One Page example : Topping Up an existing NFT by One year.

## 2/3 : AutoSwarm Stamper (this grant)
PoC prooved the need to manage Stamps one by one, this is the purpose of this development, results in same demo with Stamp TopUp instead of Batch TopUp

### 3/3 : AutoSwarm ReSaver (next)
To be able to manage -- to AutoSwarm -- whatever NFTs, this means re-store on Swarm any existing NFTs, to be able then  to ToPup them

---

# PostageStamp vs AutoSwarm Market

## PostageStamp : _manage Batch of Stamps with depth and ttl_
- topUp => more ttl / same depth
- dilute =>  more depth / less ttl
- extends _added_ => more depth / same ttl

## AutoSwarm Market : _manage Stamps with size and ttl_
- topUp => for immutable NFT / fixed size
- extends _later_, for mutable NFT or any other useCase, any Swarm file

---
# Architecture decisions :

- One Stamp per NFT
- One Year Stamp by default (365 days precisly),
- One Month Batch by default (30 days precisely)
- One Week overlapping time between two Batches (7 days)
- Stamps attached to one Batch (two during overlapping time), changed every month (if Stamp not expired)
- One Batch at a time, except two Batches during overlapping time
- Stamps use same remaining balance mechanism as Batches, but with size and ttl, instead of depth and ttl

---

#  AutoSwarm Creation Workflow

0. Offchain : **Choose NFT**
1. Onchain : **Create TBA**  (NFT Token Bound Created TBA)
2. Onchain : **Send Bzz** to TBA
3. Onchain : **TopUp NFT** => creates a Stamp to store NFT metadata
4. Offchain : **Attach Stamp** to the Batch on a Swarm node
5. Onchain : **Register Stamp** on this Batchid after attachement

---

#  AutoSwarm Batch Rolling Workflow
1. Offchain : Create one new Batch on a Swarm node
2. Onchain : Register this Batch
3. Onchain : Export all Stamp to attach from AutoSwamr Market
4. Offchain : Attach all Stamps to the new Batch on a Swarm node
5. Onchain : Register all Stamps on this Batchid after attachement
6. Offchain : Wait a month
7. Offchain : Back to 1.

---

#  Onchain : AutoSwarm Market Smartcontract

## Done
- 3 versions to get the final working one, with Architecture decisions
- similar mechanism tha PostageStamp

## ToDo
- use same sorted list mechanism
- security audits
- real tests on testnets with real users

---

# Offchain : AutoSwarm scripts and cron

## Done
- One time panual attachment of Stamp

## ToDo :
- offchain attachment of Stamps to batches : to be done within AutoSwarm Re-Saver : same scripts to develop
- cron job

import { SECONDS_PER_BLOCK } from './constants';

const utilsBzzToNBal = (bzz: bigint, depth: number): bigint => bzz / 2n ** BigInt(depth);

const utilsNBalToBzz = (balance: bigint, depth: number): bigint => balance * 2n ** BigInt(depth);

const utilsBzzToTtl = (bzz: bigint, lastPrice: bigint, depth: number): bigint =>
	utilsNBalToTtl(utilsNBalToBzz(bzz, depth), lastPrice);

const utilsNBalToTtl = (balance: bigint, lastPrice: bigint): bigint =>
	(balance * SECONDS_PER_BLOCK) / lastPrice;

const utilsTtlToBalance = (ttl: bigint, lastPrice: bigint): bigint =>
	(ttl * lastPrice) / SECONDS_PER_BLOCK;

export { utilsBzzToTtl, utilsNBalToTtl, utilsTtlToBalance, utilsNBalToBzz, utilsBzzToNBal };

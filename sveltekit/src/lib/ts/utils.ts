import { BUCKET_DEPTH, SECONDS_PER_BLOCK } from './constants';

const utilsBzzToNBal = (bzz: bigint, depth: number): bigint => {
	if (depth <= BUCKET_DEPTH) return 0n;

	return bzz / 2n ** BigInt(depth);
};

const utilsNBalToBzz = (nbal: bigint, depth: number): bigint => {
	if (depth <= BUCKET_DEPTH) return 0n;

	return nbal * 2n ** BigInt(depth);
};

const utilsBzzToTtl = (bzz: bigint, lastPrice: bigint, depth: number): bigint =>
	utilsNBalToTtl(utilsBzzToNBal(bzz, depth), lastPrice);

const utilsNBalToTtl = (nBal: bigint, lastPrice: bigint): bigint => {
	if (lastPrice == 0n) return 0n;

	return (nBal * SECONDS_PER_BLOCK) / lastPrice;
};

const utilsTtlToNBal = (ttl: bigint, lastPrice: bigint): bigint =>
	(ttl * lastPrice) / SECONDS_PER_BLOCK;

export { utilsBzzToTtl, utilsNBalToTtl, utilsTtlToNBal, utilsNBalToBzz, utilsBzzToNBal };
import { BUCKET_DEPTH, SECONDS_PER_BLOCK } from '../constants/constants';

const utilsBzzToNBal = (bzz: bigint | undefined, depth: number | undefined): bigint | undefined => {
	if (bzz === undefined || depth === undefined) return undefined;
	if (depth <= BUCKET_DEPTH) return 0n;

	return bzz / 2n ** BigInt(depth);
};

const utilsNBalToBzz = (
	nbal: bigint | undefined,
	depth: number | undefined
): bigint | undefined => {
	if (nbal === undefined || depth === undefined) return;
	if (depth <= BUCKET_DEPTH) return 0n;

	return nbal * 2n ** BigInt(depth);
};

const utilsBzzToTtl = (
	bzz: bigint | undefined,
	lastPrice: bigint | undefined,
	depth: number | undefined
): bigint | undefined => {
	if (bzz === undefined || lastPrice === undefined || depth === undefined) return;

	return utilsNBalToTtl(utilsBzzToNBal(bzz, depth), lastPrice);
};

const utilsNBalToTtl = (
	nBal: bigint | undefined,
	lastPrice: bigint | undefined
): bigint | undefined => {
	if (nBal === undefined || lastPrice === undefined) return;
	if (lastPrice == 0n) return 0n;

	return (nBal * BigInt(SECONDS_PER_BLOCK)) / lastPrice;
};

const utilsTtlToNBal = (
	ttl: number | undefined,
	lastPrice: bigint | undefined
): bigint | undefined => {
	if (ttl === undefined || lastPrice === undefined) return;

	return (BigInt(ttl) * lastPrice) / BigInt(SECONDS_PER_BLOCK);
};

export { utilsBzzToTtl, utilsNBalToTtl, utilsTtlToNBal, utilsNBalToBzz, utilsBzzToNBal };

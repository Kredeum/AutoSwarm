import { BUCKET_DEPTH, BUCKET_SIZE } from './constants';
import { utilsNBalToTtl } from './utils';

const batchBzzToNBal = (bzz: bigint, depth: number): bigint => {
	if (depth <= BUCKET_DEPTH) return 0n;

	return bzz / 2n ** BigInt(depth - BUCKET_DEPTH);
};

const batchSizeBatch = (depth: number | undefined): bigint => {
	if (depth === undefined) return 0n;

	return 2n ** BigInt(depth) * BUCKET_SIZE;
};

const batchSizeBucket = (): bigint => batchSizeBatch(BUCKET_DEPTH);

const batchNBalToBzz = (batchNBal: bigint, depth: number): bigint => {
	if (depth <= BUCKET_DEPTH) return 0n;

	return batchNBal * 2n ** BigInt(depth - BUCKET_DEPTH);
};

const batchBzzToTtl = (bzz: bigint, lastPrice: bigint, depth: number): bigint =>
	utilsNBalToTtl(batchBzzToNBal(bzz, depth), lastPrice);

export { batchNBalToBzz, batchBzzToNBal, batchBzzToTtl, batchSizeBatch, batchSizeBucket };

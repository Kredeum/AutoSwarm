import { BUCKET_DEPTH, BUCKET_SIZE } from '../constants/constants';
import { utilsNBalToTtl } from './utils';

const batchBzzToNBal = (bzz: bigint | undefined, depth: number | undefined): bigint | undefined => {
	if (bzz === undefined || depth === undefined) return;
	if (depth <= BUCKET_DEPTH) return 0n;

	return bzz / 2n ** BigInt(depth - BUCKET_DEPTH);
};

const batchSizeBatch = (depth: number | undefined): bigint | undefined => {
	if (depth === undefined) return;

	return 2n ** BigInt(depth) * BigInt(BUCKET_SIZE);
};

const batchSizeBucket = (): bigint => batchSizeBatch(BUCKET_DEPTH)!;

const batchNBalToBzz = (
	batchNBal: bigint | undefined,
	depth: number | undefined
): bigint | undefined => {
	if (batchNBal === undefined || depth === undefined) return;
	if (depth <= BUCKET_DEPTH) return 0n;

	return batchNBal * 2n ** BigInt(depth - BUCKET_DEPTH);
};

const batchBzzToTtl = (
	bzz: bigint | undefined,
	lastPrice: bigint | undefined,
	depth: number | undefined
): bigint | undefined => utilsNBalToTtl(batchBzzToNBal(bzz, depth), lastPrice);

export { batchNBalToBzz, batchBzzToNBal, batchBzzToTtl, batchSizeBatch, batchSizeBucket };

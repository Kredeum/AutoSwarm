import { batchBzzToNBal } from './batch';
import { BUCKET_DEPTH, BUCKET_SIZE } from './constants';
import { utilsNBalToTtl } from './utils';

// const batchBzzToNBal = (bzz: bigint, depth: number): bigint => {
// 	if (depth <= BUCKET_DEPTH) return 0n;

// 	return bzz / 2n ** BigInt(depth - BUCKET_DEPTH);
// };

const stampBzzToNBal = (bzz: bigint, size: bigint): bigint => {
	if (size === 0n) return 0n;

	return bzz * BUCKET_SIZE / size;
};

const stampNBalToBzz = (nBal: bigint, size: bigint): bigint => (nBal * size) / BUCKET_SIZE;

const stampBzzToTtl = (bzz: bigint, size: bigint, lastPrice: bigint): bigint =>
	utilsNBalToTtl(stampBzzToNBal(bzz, size), lastPrice);

export { stampNBalToBzz, stampBzzToNBal, stampBzzToTtl };

import { callPostageLastPrice } from '../call/callPostage';
import {
	BUCKET_DEPTH,
	CHUNK_SIZE,
	CHUNK_PRICE_DEFAULT,
	SECONDS_PER_BLOCK
} from '../constants/constants';
import { utilsNBalToTtl } from './utils';

const batchBzzToNBal = (bzz: bigint | undefined, depth: number | undefined): bigint | undefined => {
	if (bzz === undefined || depth === undefined) return;
	if (depth <= BUCKET_DEPTH) return 0n;

	return bzz / 2n ** BigInt(depth - BUCKET_DEPTH);
};

const batchSizeBatch = (depth: number | undefined): bigint | undefined => {
	if (depth === undefined) return;

	return 2n ** BigInt(depth) * CHUNK_SIZE;
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

const batchPrice = async (bzzChaind: number, depth: number, ttl: number, lastPrice?: bigint) => {
	lastPrice ||= (await callPostageLastPrice(bzzChaind)) || CHUNK_PRICE_DEFAULT;
	return 2n ** BigInt(depth) * lastPrice * BigInt(Math.floor(ttl / SECONDS_PER_BLOCK));
};

const batchBzzToTtl = (
	bzz: bigint | undefined,
	lastPrice: bigint | undefined,
	depth: number | undefined
): bigint | undefined => utilsNBalToTtl(batchBzzToNBal(bzz, depth), lastPrice);

export {
	batchPrice,
	batchNBalToBzz,
	batchBzzToNBal,
	batchBzzToTtl,
	batchSizeBatch,
	batchSizeBucket
};

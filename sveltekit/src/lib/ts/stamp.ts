import { BUCKET_SIZE } from './constants';
import { utilsNBalToTtl } from './utils';

// bzz = (ttl * lastPrice * size * RATIO) / (SECONDS_PER_BLOCK * BUCKET_SIZE);
// ttl = (bzz * SECONDS_PER_BLOCK * BUCKET_SIZE) / (lastPrice * size * RATIO);

const stampBzzToNBal = (bzz: bigint, size: bigint): bigint => (bzz * BUCKET_SIZE) / size;

const stampNBalToBzz = (nBal: bigint, size: bigint): bigint => (nBal * size) / BUCKET_SIZE;

const stampBzzToTtl = (bzz: bigint, lastPrice: bigint, size: bigint): bigint =>
	utilsNBalToTtl(stampBzzToNBal(bzz, size), lastPrice);

export { stampNBalToBzz, stampBzzToNBal, stampBzzToTtl };

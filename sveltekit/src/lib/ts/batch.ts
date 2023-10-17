import { utilsNBalToTtl } from './utils';

const batchBzzToNBal = (bzz: bigint, depth: number): bigint => bzz / 2n ** BigInt(depth);

const batchNBalToBzz = (batchNBal: bigint, depth: number): bigint =>
	batchNBal * 2n ** BigInt(depth);

const batchBzzToTtl = (bzz: bigint, lastPrice: bigint, depth: number): bigint =>
	utilsNBalToTtl(batchBzzToNBal(bzz, depth), lastPrice);

export { batchNBalToBzz, batchBzzToNBal, batchBzzToTtl };

import {
	batchSizeBatch,
	batchSizeBucket,
	batchBzzToNBal,
	batchNBalToBzz
} from '$lib/ts/swarm/batch';
import { BUCKET_DEPTH, BUCKET_SIZE } from '$lib/ts/constants/constants';
import { expect, test } from 'vitest';

test('BUCKET_DEPTH and BUCKET_SIZE', () => {
	expect(BUCKET_DEPTH).toBe(16);
	expect(BUCKET_SIZE).toBe(4_096);
});

test('batchBzzToNBal should convert BZZ to NBal', () => {
	expect(batchBzzToNBal(1_000n, 0)).toBe(0n);
	expect(batchBzzToNBal(1_000n, BUCKET_DEPTH)).toBe(0n);

	expect(batchBzzToNBal(960_000n, BUCKET_DEPTH + 2)).toBe(240_000n);

	// depth 23 = 16 + 7  => 2**7 = 128 = bucket depth
	expect(batchBzzToNBal(10n ** 16n, 23)).toBe(78_125_000_000_000n);
});

test('batchSize', () => {
	expect(batchSizeBatch(0)).toBe(BUCKET_SIZE);

	expect(batchSizeBatch(BUCKET_DEPTH)).toBe(268_435_456n);

	expect(batchSizeBucket()).toBe(268_435_456n);

	expect(batchSizeBatch(23)).toBe(34_359_738_368n);
});

// test('batchNBalToBzz should convert NBal to BZZ', () => {
// 	expect(batchNBalToBzz(0n, BUCKET_DEPTH + 1n)).toBe(0n);
// 	expect(batchNBalToBzz(250n, BUCKET_DEPTH + 2n)).toBe(1_000n);
// 	expect(batchNBalToBzz(25n * 10n ** 9n, BUCKET_DEPTH + 4n)).toBe(1_000n * 10n ** 9n);

// 	expect(batchNBalToBzz(390625n, BUCKET_DEPTH + 2n)).toBe(10n ** 12n);
// 	expect(batchNBalToBzz(244140625n, BUCKET_DEPTH + 4n)).toBe(10n ** 16n);
// });

import { expect, test } from 'vitest';

import { stampBzzToNBal, stampNBalToBzz, stampBzzToTtl } from '$lib/ts/stamp';
import { BUCKET_DEPTH, BUCKET_SIZE } from '$lib/ts/constants';
import { utilsNBalToTtl } from '$lib/ts/utils';

test('BUCKET_DEPTH and BUCKET_SIZE', () => {
	expect(BUCKET_DEPTH).toBe(16);
	expect(BUCKET_SIZE).toBe(4_096n);
});


test('stampBzzToNBal should convert BZZ to NBal', () => {
	expect(stampBzzToNBal(1_000n, 0n)).toBe(0n);
	expect(stampBzzToNBal(1_000n, 1n)).toBe(1_000n * BUCKET_SIZE);
	expect(stampBzzToNBal(1_000n, 4n)).toBe(250n * BUCKET_SIZE);

	expect(stampBzzToNBal(1_000n, 10n)).toBe(100n * BUCKET_SIZE);
	expect(stampBzzToNBal(1_000n, 10n)).toBe(409600n);

	expect(stampBzzToNBal(1_000n * 10n ** 9n, 20n)).toBe(50n * 10n ** 9n * BUCKET_SIZE);
	expect(stampBzzToNBal(1_000n * 10n ** 9n, 20n)).toBe(204_800_000_000_000n);

	// check integer division is done the right way
	expect(stampBzzToNBal(10n ** 16n, 24n)).not.toBe((10n ** 16n / 24n) * BUCKET_SIZE);
	expect(stampBzzToNBal(10n ** 16n, 24n)).not.toBe(10n ** 16n * (BUCKET_SIZE / 24n));
	expect(stampBzzToNBal(10n ** 16n, 24n)).toBe((10n ** 16n * BUCKET_SIZE) / 24n);
	expect(stampBzzToNBal(10n ** 16n, 24n)).toBe(1_706_666_666_666_666_666n);

	// with no rounding problems, shortcuts are allowed
	expect(stampBzzToNBal(10n ** 12n, 20n)).toBe((1_000n / 20n) * 10n ** 9n * BUCKET_SIZE);
	expect(stampBzzToNBal(10n ** 12n, 20n)).toBe(204_800_000_000_000n);
});

test('stampNBalToBzz should convert NBal to BZZ', () => {
	expect(stampNBalToBzz(1_000n, 2n)).toBe(2000n / BUCKET_SIZE);
	expect(stampNBalToBzz(24_000_000n, 2n)).toBe(48_000_000n / BUCKET_SIZE);
	expect(stampNBalToBzz(24_000_000n, 2n)).toBe(11718n);

	expect(stampNBalToBzz(204_800_000_000_000n, 20n)).toBe(10n ** 12n);
	expect(stampNBalToBzz(1_706_666_666_666_666_667n, 24n)).toBe(10n ** 16n);
});

test('stampBzzToTtl should convert BZZ to TTL', () => {
	expect(stampBzzToNBal(1_000n, 10n)).toBe(409_600n);
	expect(utilsNBalToTtl(409_600n, 24_000n)).toBe(85n);
	expect(stampBzzToTtl(1_000n, 10n, 24_000n)).toBe(85n);

	expect(stampBzzToTtl(1_000n, 10n, 1_000n)).toBe(2048n);
	expect(stampBzzToTtl(2_000_000n, 20n, 24_000n)).toBe(85_333n);

  // 1 Bzz ttl for 100Ko at price 24 000 Plur/block
  expect(stampBzzToNBal(10n ** 16n, 100_000n)).toBe(409_600_000_000_000n);
	expect(utilsNBalToTtl(409_600_000_000_000n, 24_000n)).toBe(85_333_333_333n);
	expect(stampBzzToTtl(10n ** 16n, 100_000n, 24_000n)).toBe(85_333_333_333n);
});
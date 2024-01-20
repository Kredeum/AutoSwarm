import { expect, test } from 'vitest';

import { stampBzzToNBal, stampNBalToBzz, stampBzzToTtl } from '@autoswarm/common/src/swarm/stamp';
import { BUCKET_DEPTH, CHUNK_SIZE } from '@autoswarm/common/src/constants/constants';
import { utilsNBalToTtl } from '@autoswarm/common/src/swarm/utils';

test('BUCKET_DEPTH and CHUNK_SIZE', () => {
	expect(BUCKET_DEPTH).toBe(16);
	expect(CHUNK_SIZE).toBe(4_096n);
});

test('stampBzzToNBal should convert BZZ to NBal', () => {
	expect(stampBzzToNBal(1_000n, 0)).toBe(0n);
	expect(stampBzzToNBal(1_000n, 1)).toBe(1_000n * CHUNK_SIZE);
	expect(stampBzzToNBal(1_000n, 4)).toBe(250n * CHUNK_SIZE);

	expect(stampBzzToNBal(1_000n, 10)).toBe(100n * CHUNK_SIZE);
	expect(stampBzzToNBal(1_000n, 10)).toBe(409600n);

	expect(stampBzzToNBal(1_000n * 10n ** 9n, 20)).toBe(50n * 10n ** 9n * CHUNK_SIZE);
	expect(stampBzzToNBal(1_000n * 10n ** 9n, 20)).toBe(204_800_000_000_000n);

	// check integer division is done the right way
	expect(stampBzzToNBal(10n ** 16n, 24)).not.toBe((10n ** 16n / 24n) * CHUNK_SIZE);
	expect(stampBzzToNBal(10n ** 16n, 24)).not.toBe(10n ** 16n * (CHUNK_SIZE / 24n));
	expect(stampBzzToNBal(10n ** 16n, 24)).toBe((10n ** 16n * CHUNK_SIZE) / 24n);
	expect(stampBzzToNBal(10n ** 16n, 24)).toBe(1_706_666_666_666_666_666n);

	// with no rounding problems, shortcuts are allowed
	expect(stampBzzToNBal(10n ** 12n, 20)).toBe((1_000n / 20n) * 10n ** 9n * CHUNK_SIZE);
	expect(stampBzzToNBal(10n ** 12n, 20)).toBe(204_800_000_000_000n);
});

test('stampNBalToBzz should convert NBal to BZZ', () => {
	expect(stampNBalToBzz(1_000n, 2)).toBe(2000n / CHUNK_SIZE);
	expect(stampNBalToBzz(24_000_000n, 2)).toBe(48_000_000n / CHUNK_SIZE);
	expect(stampNBalToBzz(24_000_000n, 2)).toBe(11718n);

	expect(stampNBalToBzz(204_800_000_000_000n, 20)).toBe(10n ** 12n);
	expect(stampNBalToBzz(1_706_666_666_666_666_667n, 24)).toBe(10n ** 16n);
});

test('stampBzzToTtl should convert BZZ to TTL', () => {
	expect(stampBzzToNBal(1_000n, 10)).toBe(409_600n);
	expect(utilsNBalToTtl(409_600n, 24_000n)).toBe(85n);
	expect(stampBzzToTtl(1_000n, 10, 24_000n)).toBe(85n);

	expect(stampBzzToTtl(1_000_000n, 10, 1_000n)).toBe(2_048_000n);
	expect(stampBzzToTtl(2_000_000n, 20, 24_000n)).toBe(85_330n);

	// 1 Bzz ttl for 100Ko at price 24 000 Plur/block
	expect(stampBzzToNBal(10n ** 16n, 100_000)).toBe(409_600_000_000_000n);
	expect(utilsNBalToTtl(409_600_000_000_000n, 24_000n)).toBe(85_333_333_330n);
	expect(stampBzzToTtl(10n ** 16n, 100_000, 24_000n)).toBe(85_333_333_330n);
});

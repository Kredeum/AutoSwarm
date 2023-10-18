import { expect, test } from 'vitest';

import {
	utilsBzzToNBal,
	utilsNBalToBzz,
	utilsBzzToTtl,
	utilsNBalToTtl,
	utilsTtlToNBal
} from '$lib/ts/utils';
import { BUCKET_DEPTH, BUCKET_SIZE } from '$lib/ts/constants';

test('BUCKET_DEPTH and BUCKET_SIZE', () => {
	expect(BUCKET_DEPTH).toBe(16);
	expect(BUCKET_SIZE).toBe(4_096n);
});

test('pow pow', () => {
	expect(0n ** 2n).toBe(0n);
	expect(1n ** 2n).toBe(1n);
	expect(10n ** 2n).toBe(100n);
	expect(10n ** 3n).toBe(1_000n);

	expect(2n ** 16n).toBe(65_536n);
	expect(2n ** 17n).toBe(131_072n);
	expect(2n ** 20n).toBe(1_048_576n);
	expect(2n ** 23n).toBe(8_388_608n);

	expect(5n * 10n ** 3n).toBe(5_000n);
	expect(50n ** 3n).toBe(125_000n);

	expect(50n ** 3n).toBe(BigInt(Math.pow(50, 3)));
});

test('utilsBzzToNBal should convert BZZ to balance', () => {
	expect(utilsBzzToNBal(1n, 0)).toBe(0n);
	expect(utilsBzzToNBal(1n, 16)).toBe(0n);
	expect(utilsBzzToNBal(10n ** 9n, 18)).toBe(3814n);
	expect(utilsBzzToNBal(10n ** 9n, 23)).toBe(119n);
	expect(utilsBzzToNBal(10n ** 16n, 30)).toBe(9313225n);
});

test('utilsNBalToBzz should convert balance to BZZ', () => {
	expect(utilsNBalToBzz(119n, 23)).toBe(998244352n);
});

test('utilsBzzToTtl should convert BZZ to TTL', () => {
	expect(utilsBzzToTtl(10n ** 16n, 24_000n, 17)).toBe(15894571n);
});

test('utilsNBalToTtl should convert balance to TTL', () => {
	expect(utilsNBalToTtl(100000n, 24_000n)).toBe(20n);
});

test('utilsTtlToNBal should convert TTL to balance', () => {
	expect(utilsTtlToNBal(200n, 10n)).toBe(400n);
});

import { expect, test } from 'vitest';

import {
	utilsBzzToNBal,
	utilsNBalToBzz,
	utilsBzzToTtl,
	utilsNBalToTtl,
	utilsTtlToBalance
} from '$lib/ts/utils';

test('utilsBzzToNBal should convert BZZ to balance', () => {
	expect(utilsBzzToNBal(1000n, 0)).toBe(1000n);
	expect(utilsBzzToNBal(1000n, 2)).toBe(250n);
	expect(utilsBzzToNBal(1000n, 4)).toBe(62n);
	expect(utilsBzzToNBal(10n ** 9n, 20)).toBe(953n);
	expect(utilsBzzToNBal(10n ** 16n, 24)).toBe(596046447n);
});

test('utilsNBalToBzz should convert balance to BZZ', () => {
	expect(utilsNBalToBzz(25n, 2)).toBe(100n);
});

test('utilsBzzToTtl should convert BZZ to TTL', () => {
	expect(utilsBzzToTtl(100n, 10n, 2)).toBe(200n);
});

test('utilsNBalToTtl should convert balance to TTL', () => {
	expect(utilsNBalToTtl(100000n, 2400n)).toBe(208n);
});

test('utilsTtlToBalance should convert TTL to balance', () => {
	expect(utilsTtlToBalance(200n, 10n)).toBe(400n);
});

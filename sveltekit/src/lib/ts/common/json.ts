import type { BzzChainIdType } from './chains';

import jsonFile from '$addresses';

type JsonType = Record<string, string>;

///////////////////////////////////////////////////////////////////////////////////////////////////
// GET : offline functions, returns data
///////////////////////////////////////////////////////////////////////////////////////////////////

// jsons Map used as cache
const _jsons: Map<BzzChainIdType, JsonType> = new Map();

const _jsonGet = (chainId: number): JsonType => {
	const json = jsonFile[chainId as BzzChainIdType];
	_jsons.set(chainId as BzzChainIdType, json);

	return json;
};

const jsonGet = (chainId: number): JsonType =>
	_jsons.get(chainId as BzzChainIdType) || _jsonGet(chainId);

const jsonGetField = (chainId: number, field: string): string =>
	(jsonGet(chainId) as JsonType)[field] || '';

export { jsonGet, jsonGetField };

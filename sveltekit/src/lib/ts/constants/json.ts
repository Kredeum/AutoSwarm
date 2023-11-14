import type { BzzChainIdType } from './chains';

import jsonFile from '$addresses';

///////////////////////////////////////////////////////////////////////////////////////////////////
// GET : offline functions, returns data
///////////////////////////////////////////////////////////////////////////////////////////////////

const jsonGet = (chainId: number) => {
	return jsonFile[chainId as BzzChainIdType];
};

const jsonGetBatchId = (chainId: number): string => {
	const json = jsonGet(chainId as BzzChainIdType);
	return 'batchId' in json ? json.batchId : '';
};

export { jsonGet, jsonGetBatchId };

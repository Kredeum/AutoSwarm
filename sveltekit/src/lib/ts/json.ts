import type { ChainIdType } from './chains';

import jsonFile from '$addresses';

///////////////////////////////////////////////////////////////////////////////////////////////////
// GET : offline functions, returns data
///////////////////////////////////////////////////////////////////////////////////////////////////

const jsonGet = (chainId: number) => {
	return jsonFile[chainId as ChainIdType];
};

const jsonGetBatchId = (chainId: number): string => {
	const json = jsonGet(chainId as ChainIdType);
	return 'batchId' in json ? json.batchId : '';
};

export { jsonGet, jsonGetBatchId };

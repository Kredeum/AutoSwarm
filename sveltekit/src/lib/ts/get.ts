import jsonFile from '$addresses';

///////////////////////////////////////////////////////////////////////////////////////////////////
// GET : offline functions, returns data
///////////////////////////////////////////////////////////////////////////////////////////////////

enum ChainIdInJson {
	'gnosis' = 100,
	'sepolia' = 11155111,
	'localhost' = 1337
}

const getJson = (chainId: ChainIdInJson) => {
	return jsonFile[chainId];
};
const getBatchId = (chainId: ChainIdInJson): string => {
	return getJson(chainId).batchId;
};

export { getJson, getBatchId, type ChainIdInJson };

import {
	BEE_API_DEFAULT,
	BEE_GATEWAY_DEFAULT,
	CHAIN_ID_DEFAULT,
	BEE_BATCHID_DEFAULT
} from '../constants/constants';

const localConfigGet = (field: string): string | null => {
	try {
		return localStorage.getItem(`autoswarm.${field}`);
	} catch (e) {
		return null;
	}
};

const localConfigSet = (field: string, value: string): void =>
	localStorage?.setItem(`autoswarm.${field}`, value);

const localConfigInit = (): void => {
	if (localConfigGet('api') === null) localConfigSet('api', BEE_API_DEFAULT);
	if (localConfigGet('gateway') === null) localConfigSet('api', BEE_GATEWAY_DEFAULT);
	if (localConfigGet('batchId') === null) localConfigSet('batchId', BEE_BATCHID_DEFAULT);
	if (localConfigGet('chainId') === null) localConfigSet('chainId', CHAIN_ID_DEFAULT);
};

export { localConfigInit, localConfigGet, localConfigSet };

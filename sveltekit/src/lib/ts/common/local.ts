import {
	BEE_API_DEFAULT,
	BEE_GATEWAY_DEFAULT,
	BZZ_CHAIN_ID_DEFAULT,
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
	console.log('localConfigInit');
	if (!localConfigGet('api')) localConfigSet('api', BEE_API_DEFAULT);
	if (!localConfigGet('gateway')) localConfigSet('gateway', BEE_GATEWAY_DEFAULT);
	if (!localConfigGet('batchId')) localConfigSet('batchId', BEE_BATCHID_DEFAULT);
	if (!localConfigGet('bzzChainId')) localConfigSet('bzzChainId', BZZ_CHAIN_ID_DEFAULT);
};

export { localConfigInit, localConfigGet, localConfigSet };

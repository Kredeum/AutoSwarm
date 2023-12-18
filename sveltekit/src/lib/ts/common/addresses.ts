import type { BzzChainIdType } from './chains';
import type { AddressesType } from '../constants/types';

import addressesFile from '$addresses';

///////////////////////////////////////////////////////////////////////////////////////////////////
// GET : offline functions, returns data
///////////////////////////////////////////////////////////////////////////////////////////////////

// _addresses Map used as cache
const _addresses: Map<BzzChainIdType, AddressesType> = new Map();

const _addressesGet = (chainId: number): AddressesType => {
	const json = addressesFile[chainId as BzzChainIdType];
	_addresses.set(chainId as BzzChainIdType, json);

	return json;
};

const addressesGet = (chainId: number): AddressesType =>
	_addresses.get(chainId as BzzChainIdType) || _addressesGet(chainId);

const addressesGetField = (chainId: number, field: string): string =>
	(addressesGet(chainId) as AddressesType)[field] || '';

export { addressesGet, addressesGetField };

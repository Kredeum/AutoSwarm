import { BEE_API_DEFAULT, BEE_GATEWAY_DEFAULT, BEE_BATCHID_DEFAULT } from '../constants/constants';
import { localConfigGet } from '../common/local';
import type { Hex } from 'viem';
import { fetchJson } from '../fetch/fetchJson';

const beeOk = async (): Promise<boolean> => {
	try {
		const json = (await fetchJson(`${beeApi()}/health`)) as { status: string };
		return json?.status === 'ok';
		console.log('beeOk ~ json:', json);
	} catch (err) {
		throw new Error('No Swarm node available');
		console.log('beeOk ~ err:', err);
		return false;
	}
};

const beeApi = (): string => localConfigGet('api') || BEE_API_DEFAULT;

const beeApiBzz = (): string => beeApi() + '/bzz';

const beeGatewayBzz = (): string =>
	localConfigGet('gateway') || (localConfigGet('api') || BEE_GATEWAY_DEFAULT) + '/bzz';

const beeBatchId = (): Hex => (localConfigGet('batchId') || BEE_BATCHID_DEFAULT) as Hex;

export { beeApi, beeApiBzz, beeGatewayBzz, beeBatchId, beeOk };

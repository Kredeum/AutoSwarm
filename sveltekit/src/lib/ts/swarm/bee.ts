import { BEE_API_DEFAULT, BEE_GATEWAY_DEFAULT, BEE_BATCHID_DEFAULT } from '../constants/constants';
import { localConfigGet } from '../common/local';
import type { Hex } from 'viem';

const beeApi = (): string => localConfigGet('api') || BEE_API_DEFAULT;

const beeApiBzz = (): string => beeApi() + '/bzz';

const beeGatewayBzz = (): string =>
	(localConfigGet('gateway') || localConfigGet('api') || BEE_GATEWAY_DEFAULT) + '/bzz';

const beeBatchId = (): Hex => (localConfigGet('batchId') || BEE_BATCHID_DEFAULT) as Hex;

export { beeApi, beeApiBzz, beeGatewayBzz, beeBatchId };

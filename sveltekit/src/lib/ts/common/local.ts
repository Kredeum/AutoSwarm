import { SWARM_DEFAULT_API, SWARM_DEFAULT_BATCHID } from '../constants/constants';

const localConfigGet = (field: string): string | null => {
	try {
		return localStorage.getItem(`swarm.${field}`);
	} catch (e) {
		return null;
	}
};

const localConfigSet = (field: string, value: string): void =>
	localStorage?.setItem(`swarm.${field}`, value);

const localConfigInit = (): void => {
	if (localConfigGet('api') === null) localConfigSet('api', SWARM_DEFAULT_API);
	if (localConfigGet('batchId') === null) localConfigSet('batchId', SWARM_DEFAULT_BATCHID);
};

export { localConfigInit, localConfigGet, localConfigSet };

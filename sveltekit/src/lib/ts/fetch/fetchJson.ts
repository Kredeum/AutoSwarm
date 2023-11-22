import { utilsError } from '../swarm/utils';

const fetchJson = async (url: URL): Promise<unknown | undefined> => {
	// console.info('fetchJson', url);

	try {
		const json = await (await fetch(url)).json();
		// console.info('fetchJson', url, '\n', json);
		return json;
	} catch (e) {
		utilsError(`fetchJson failed with error ${url}`, e);
	}
};

export { fetchJson };

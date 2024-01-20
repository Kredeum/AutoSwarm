import { fetchUrl } from './fetch';

const fetchJson = async (url: URL | string | undefined): Promise<unknown | undefined> => {
	// console.info('fetchJson', url);
	const response = await fetchUrl(url);
	if (!response) return;

	return await response.json();
};

export { fetchJson };

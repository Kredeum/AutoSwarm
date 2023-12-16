import { fetchUrl } from './fetch';

const fetchSizeHead = async (url: URL | string | undefined): Promise<number | undefined> => {
	// console.info('fetchSizeHead', url);
	const response = await fetchUrl(url, 'HEAD');
	if (!response) return;

	if (response?.headers.has('Content-Length'))
		return Number(response.headers.get('Content-Length'));
};

const fetchSizeGet = async (url: URL | string | undefined): Promise<number | undefined> => {
	// console.info('fetchSizeGet', url);
	const response = await fetchUrl(url);
	if (!response) return;

	const blob = await response.blob();
	const data = new Uint8Array(await blob.arrayBuffer());

	return data.length;
};

const fetchSize = async (url: URL | string | undefined): Promise<number | undefined> => {
	// console.info('fetchSize', url);
	return (await fetchSizeHead(url)) || (await fetchSizeGet(url));
};

export { fetchSize, fetchSizeGet, fetchSizeHead };

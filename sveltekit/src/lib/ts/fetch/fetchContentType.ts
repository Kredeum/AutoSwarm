import { fetchUrl } from './fetch';

const fetchContentTypeHead = async (url: URL | string | undefined): Promise<string | undefined> => {
	// console.info('fetchContentTypeHead', url);
	const response = await fetchUrl(url, 'HEAD');
	if (!response) return;

	return response.headers.get('Content-Type') || 'text';
};

// eslint-disable-next-line @typescript-eslint/no-unused-vars
const fetchContentTypeGet = async (url: URL | string | undefined): Promise<string | undefined> => {
	// console.info('fetchContentTypeGet', url);
	const response = await fetchUrl(url);
	if (!response) return;

	return (await response.blob()).type;
};

const fetchContentType = async (url: URL | string | undefined): Promise<string | undefined> => {
	// console.info('fetchContentType', url);
	return (await fetchContentTypeHead(url)) || (await fetchContentTypeGet(url));
};

export { fetchContentType, fetchContentTypeHead, fetchContentTypeGet };

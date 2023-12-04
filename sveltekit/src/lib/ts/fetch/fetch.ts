import { urlToUrl, urlToUrlAlt } from '../common/url';

const fetchSuccess = (status: number): boolean => status >= 200 && status < 300;

const fetchUrl = async (
	url: URL | string | undefined,
	method = 'GET'
): Promise<Response | undefined> => {
	// console.info('fetchUrl:', method, url);
	if (!url) return;

	try {
		// const response = await fetch(url, { method });
		const response = await fetch(url, { method, mode: 'cors' });
		if (fetchSuccess(response.status)) {
			return response;
		} else {
			console.warn('fetchUrl: response.status', response.status, url, '\n', response);
		}
	} catch (err) {
		console.error('fetchUrl: ERROR', method, url, '\n', err);
	}
};

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

const fetchUrlOkHead = async (url: URL | string | undefined): Promise<boolean> => {
	// console.info('fetchUrlOkHead', url);
	return (
		Boolean(url) &&
		(Boolean(await fetchContentTypeHead(url)) || ((await fetchSizeHead(url)) || 0) > 0)
	);
};

const fetchUrlOkGet = async (url: URL | string | undefined): Promise<boolean> => {
	// console.info('fetchUrlOkGet', url);
	return (
		Boolean(url) &&
		(Boolean(await fetchContentTypeGet(url)) || ((await fetchSizeGet(url)) || 0) > 0)
	);
};

const fetchUrlOk = async (url: URL | string | undefined): Promise<boolean> => {
	// console.info('fetchUrlOk', url);
	return (await fetchUrlOkHead(url)) || (await fetchUrlOkGet(url));
};

const fetchUriOk = async (url: URL | string | undefined): Promise<boolean> => {
	// console.info('fetchUriOk', url);
	return await fetchUrlOk(urlToUrl(url));
};

const fetchUrlAltOk = async (url: URL | string | undefined): Promise<boolean> => {
	// console.info('fetchUrlAltOk', url);
	return await fetchUrlOk(urlToUrlAlt(url));
};
export {
	fetchUrl,
	fetchSuccess,
	fetchSize,
	fetchContentType,
	fetchUrlOk,
	fetchUriOk,
	fetchUrlAltOk
};

import { urlToUrl, urlToUrlAlt } from '../common/url';

const fetchSuccess = (status: number): boolean => status >= 200 && status < 300;

const fetchUrl = async (
	url: URL | string | undefined,
	method = 'GET'
): Promise<Response | undefined> => {
	if (!url) return;

	const response = await fetch(url, { method });
	if (fetchSuccess(response.status)) {
		return response;
	} else {
		console.log('fetchSizeHead: response.status', response.status, url);
	}
};

const fetchSizeHead = async (url: URL | string | undefined): Promise<number | undefined> => {
	const response = await fetchUrl(url, 'HEAD');
	if (!response) return;

	if (response?.headers.has('Content-Length'))
		return Number(response.headers.get('Content-Length'));
};

const fetchSizeGet = async (url: URL | string | undefined): Promise<number | undefined> => {
	const response = await fetchUrl(url);
	if (!response) return;

	const blob = await response.blob();
	const data = new Uint8Array(await blob.arrayBuffer());

	return data.length;
};

const fetchSize = async (url: URL | string | undefined): Promise<number | undefined> =>
	(await fetchSizeHead(url)) || (await fetchSizeGet(url));

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

const fetchContentType = async (url: URL | string | undefined): Promise<string | undefined> =>
	fetchContentTypeHead(url); // TO USE WITH SERVER WITHOUT HEAD => // || fetchContentTypeGet(url);

const fetchUrlOkHead = async (url: URL | string | undefined): Promise<boolean> =>
	Boolean(url) && Boolean(await fetchContentType(url));

// eslint-disable-next-line @typescript-eslint/no-unused-vars
const fetchUrlOkGet = async (url: URL | string | undefined): Promise<boolean> =>
	Boolean(url) && ((await fetchSizeGet(url)) || 0) > 0;

const fetchUrlOk = async (url: URL | string | undefined): Promise<boolean> => fetchUrlOkHead(url); // TO USE WITH SERVER WITHOUT HEAD => //  || fetchUrlOkGet(url);

const fetchUriOk = async (url: URL | string | undefined): Promise<boolean> =>
	fetchUrlOk(urlToUrl(url));

const fetchUrlAltOk = async (url: URL | string | undefined): Promise<boolean> =>
	fetchUrlOk(urlToUrlAlt(url));

export {
	fetchUrl,
	fetchSuccess,
	fetchSize,
	fetchContentType,
	fetchUrlOk,
	fetchUriOk,
	fetchUrlAltOk
};

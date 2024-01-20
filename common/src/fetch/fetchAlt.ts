import { urlToUrl, urlToUrlAlt } from '../common/url';
import { fetchUrl } from './fetch';
import { fetchOkUrl } from './fetchOk';

const fetchAltUrl = async (url: URL | string | undefined): Promise<string | undefined> => {
	// console.info('fetchAltUrl  IN', url);
	const tryUrl = urlToUrl(url);
	if (tryUrl && (await fetchOkUrl(tryUrl))) return tryUrl;

	const tryUrlAlt = urlToUrlAlt(url);
	if (tryUrlAlt && tryUrlAlt !== tryUrl && (await fetchOkUrl(tryUrlAlt))) return tryUrlAlt;

	// console.info('fetchAltUrl OUT');
	return url?.toString();
};

const fetchAltUrlToBlob = async (url: URL | string | undefined): Promise<Blob> => {
	const urlAlt = await fetchAltUrl(url);
	if (!urlAlt) throw new Error(`fetchAltUrlToBlob: Bad URL ${url}`);

	const response = await fetchUrl(urlAlt);
	if (!response) throw new Error(`fetchAltUrlToBlob: Bad URL ${urlAlt}`);

	return response.blob();
};

const fetchAltUrlToUint8Array = async (url: URL | string | undefined): Promise<Uint8Array> =>
	new Uint8Array(await (await fetchAltUrlToBlob(url)).arrayBuffer());

export { fetchAltUrl, fetchAltUrlToBlob, fetchAltUrlToUint8Array };

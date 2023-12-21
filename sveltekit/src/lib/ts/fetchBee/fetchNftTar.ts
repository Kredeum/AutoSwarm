import { makeTar, type Collection, type CollectionEntry } from '$lib/ts/swarm/tar';
import { INDEX_HTML, LIST_JSON } from '../constants/constants';
import { fetchAltUrlToBlob, fetchAltUrlToUint8Array } from '../fetch/fetchAlt';

const _fetchBlobFilename = (blob: Blob): [string, string, string] => {
	const mimeType = blob.type;
	const [type, subType] = mimeType.split('/');

	let ext = subType;
	if (type === 'text' && (!subType || subType === 'plain')) ext = 'txt';

	return [`${type}.${ext}`, type, subType];
};

const fetchNftTarCollection = async (urls: (URL | string | undefined)[]): Promise<Collection> => {
	console.log('fetchNftTarCollection', urls);

	const collection: Collection = [];
	let imageName: string;
	let imageMainType: string;

	{
		const metadataData = await fetchAltUrlToUint8Array(urls[1]);
		collection.push({ data: metadataData, path: 'metadata.json' });
	}

	{
		const contentBlob: Blob = await fetchAltUrlToBlob(urls[0]);
		const contentData = new Uint8Array(await contentBlob.arrayBuffer());
		[imageName, imageMainType] = _fetchBlobFilename(contentBlob);
		collection.push({ data: contentData, path: imageName });
	}

	{
		let html = '<html><body><h1>AutoSwarm</h1>';
		if (imageMainType == 'image') {
			html += `<img width="150" src="${imageName}"><br/><br/>`;
		}
		html += `<a href="${imageName}">${imageName}</a></li><br/><br/>`;
		html += `<a href="metadata.json">metadata.json</a><br/><br/></body></html>`;
		html += '</body></html>';
		const indexHtml = new TextEncoder().encode(html);
		collection.push({ data: indexHtml, path: INDEX_HTML });
	}

	{
		const json = `{"image": "${imageName}", "metadata": "metadata.json"}`;
		const listJson = new TextEncoder().encode(json);
		collection.push({ data: listJson, path: LIST_JSON });
	}

	return collection;
};

// const fetchNftTarHash = async (urls: (URL | string | undefined)[]): Promise<Hex> => {};

const fetchNftTar = async (urls: (URL | string | undefined)[]): Promise<[Uint8Array, string]> => {
	console.log('fetchNftTar', urls);

	const collection = await fetchNftTarCollection(urls);
	const imageName = collection[1].path;

	return [makeTar(collection), imageName];
};

export { fetchNftTar };

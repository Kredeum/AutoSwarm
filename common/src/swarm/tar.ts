import Tar from 'tar-js';

interface CollectionEntry {
	data: Uint8Array;
	path: string;
}
type Collection = Array<CollectionEntry>;

interface _StringLike {
	readonly length: number;
	charCodeAt: (index: number) => number;
}

const _fixUnicodePath = (path: string): _StringLike => {
	const codes = new TextEncoder().encode(path);

	return {
		length: codes.length,
		charCodeAt: (index) => codes[index]
	};
};

const makeTar = (data: Collection): Uint8Array => {
	const tar = new Tar(1);
	for (const entry of data) {
		const path = _fixUnicodePath(entry.path);
		tar.append(path as string, entry.data);
	}

	return tar.out;
};

export { makeTar };
export type { CollectionEntry, Collection };

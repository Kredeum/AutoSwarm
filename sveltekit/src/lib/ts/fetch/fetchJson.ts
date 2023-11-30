
const fetchJson = async (url: URL | string | undefined): Promise<unknown | undefined> => {
	// console.info('fetchJson', url);
	if (!url) return;

	try {
		const json = await (await fetch(url)).json();
		return json;
	} catch (e) {
		throw new Error(`fetchJson: ${url} ${e}`);
	}
};

export { fetchJson };

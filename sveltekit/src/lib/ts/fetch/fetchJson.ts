const fetchJson = async (url: string): Promise<unknown | undefined> => {
	// console.info('fetchJson', url);

	try {
		const json = await (await fetch(url)).json();
		console.log('fetchJson', url, '\n', json);
		return json;
	} catch (e) {
		console.log('fetchJson failed with error', e, url);
	}
};

export { fetchJson };

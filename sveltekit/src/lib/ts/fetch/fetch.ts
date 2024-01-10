const fetchSuccess = (status: number): boolean => status >= 200 && status < 300;

const fetchUrl = async (
	url: URL | string | undefined,
	method = 'GET'
): Promise<Response | undefined> => {
	// console.info('fetchUrl:', method, url);
	if (!url) throw new Error('fetchUrl: No url defined!');

	const response = await fetch(url, { method });

	if (fetchSuccess(response.status)) {
		return response;
	} else {
		console.info('fetchUrl: Error status', response.status, url, '\n', response);
		throw new Error(`fetchUrl: Error status ${response.status} on ${url}`);
	}
};

export { fetchUrl, fetchSuccess };

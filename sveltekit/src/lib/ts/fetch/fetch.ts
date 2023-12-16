const fetchSuccess = (status: number): boolean => status >= 200 && status < 300;

const fetchUrl = async (
	url: URL | string | undefined,
	method = 'GET'
): Promise<Response | undefined> => {
	// console.info('fetchUrl:', method, url);
	if (!url) return;

	try {
		const response = await fetch(url, { method });
		// const response = await fetch(url, { method, mode: 'cors' });
		if (fetchSuccess(response.status)) {
			return response;
		} else {
			console.warn('fetchUrl: response.status', response.status, url, '\n', response);
		}
	} catch (err) {
		console.error('fetchUrl: ERROR', method, url, '\n', err);
	}
};

export { fetchUrl, fetchSuccess };

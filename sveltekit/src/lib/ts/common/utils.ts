import { BUCKET_DEPTH, SECONDS_PER_BLOCK } from '../constants/constants';

const utilsError = (label: string, err?: unknown) => {
	const message = `${label} : ${err}`;
	console.error(message);
	// alert(message);
};

export { utilsError };

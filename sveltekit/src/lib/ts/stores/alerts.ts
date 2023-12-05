import type { Writable } from 'svelte/store';
import { writable } from 'svelte/store';

type AlertMessage = {
	status: string;
	message: string;
};

const alertMessage: Writable<AlertMessage> = writable({ status: '', message: '' });

export type { AlertMessage };
export { alertMessage };

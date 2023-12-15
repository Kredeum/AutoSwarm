import type { Writable } from 'svelte/store';
import { writable } from 'svelte/store';

type AlertMessage = {
	status?: string;
	title?: string;
	detail?: unknown;
};

const alertMessage: Writable<AlertMessage> = writable();

const alertInfo = (title: string) => alertMessage.set({ status: 'info', title });
const alertSuccess = (title: string) => alertMessage.set({ status: 'success', title });
const alertError = (title: string, err: unknown) =>
	alertMessage.set({ status: 'error', title, detail: err });

export { type AlertMessage, alertMessage, alertInfo, alertSuccess, alertError };

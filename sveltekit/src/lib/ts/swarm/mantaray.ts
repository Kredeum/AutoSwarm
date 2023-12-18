import { MantarayNode } from 'mantaray-js';
import { SWARM_DEFAULT_API } from '../constants/constants';
import { localConfigGet } from '../common/local';
import { bzzTrim } from './bzz';

const _uint8ArrayToHexString = (byteArray: Uint8Array): string =>
	Array.from(byteArray).reduce((str, byte) => str + byte.toString(16).padStart(2, '0'), '');

const _uint8ArrayToString = (byteArray: Uint8Array): string => new TextDecoder().decode(byteArray);

const _logNode = (node: MantarayNode, reference: string, path: string): void => {
	const logPath = path === '' ? '' : '/' + path.replace(/^\//, '');
	console.log(reference, logPath, node.getMetadata || '');
	// console.log(node);
};

const _logForks = async (node: MantarayNode, path = ''): Promise<void> => {
	for (const fork of Object.values(node.forks || {})) {
		const reference = _uint8ArrayToHexString(fork.node.getEntry!);
		const newPath = path + _uint8ArrayToString(fork.prefix);

		if (fork.node.isValueType()) _logNode(fork.node, reference, newPath);
		if (fork.node.isEdgeType()) await mantarayLog(reference, newPath);
	}
};

const mantarayLog = async (reference: string, path = ''): Promise<void> => {
	console.log('mantarayLog', reference);
	const ref = bzzTrim(reference);

	const beeUrl = localConfigGet('api') || SWARM_DEFAULT_API;
	const res = await fetch(`${beeUrl}/bytes/${ref}`);
	const data = new Uint8Array(await res.arrayBuffer());
	const node = new MantarayNode();
	node.deserialize(data);

	// _logNode(node, ref, path);
	await _logForks(node, path);
};

export { mantarayLog };

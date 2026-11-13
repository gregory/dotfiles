// node --test bin/heat.test.mjs
import assert from 'node:assert/strict';
import { test } from 'node:test';
import {
  MAIN,
  SCRATCHPADS,
  dirOf,
  etimeSeconds,
  inScope,
  isGhost,
  lineage,
  locate,
  ownerProfile,
  parseProcesses,
  programLabel,
  programsOf,
  profileOf,
  resolveProfile,
  testProcesses,
  testRunner,
  topPrograms,
} from './heat.mjs';

const SRC = '/Users/me/src';
const ADB = `${SRC}/github.com/acme/adb`;
const BRITY = `${SRC}/github.com/acme/brity`;
const TREE = `${ADB}/.claude/worktrees/feat-x`;
const onDisk = new Set([`${ADB}/.git`, `${BRITY}/.git`, `${TREE}/.git`, TREE]);
const ctx = { src: SRC, exists: path => onDisk.has(path) };
const at = (command, cwd = '') => locate({ command, cwd }, ctx);
const SESSION = (profile, tail = '') =>
  `/Users/me/Library/Application Support/${profile}/claude-code/2.1/abc/claude.app/Contents/MacOS/claude --x ${tail}`;

test('etimeSeconds reads the three ps formats', () => {
  assert.equal(etimeSeconds('07:12'), 432);
  assert.equal(etimeSeconds('01:02:03'), 3723);
  assert.equal(etimeSeconds('2-00:00:01'), 172801);
});

test('parseProcesses joins ps with the lsof working directories', () => {
  const [first, second] = parseProcesses(
    '  12  1  3.5  1024  00:10 node x.js\nnoise\n 13 12 0.0 1 00:01 ls\n',
    `p12\nfcwd\nn${TREE}\n`
  );
  assert.deepEqual(first, { pid: 12, ppid: 1, cpu: 3.5, rss: 1024 ** 2, age: 10, command: 'node x.js', cwd: TREE });
  assert.equal(second.cwd, '');
});

test('profileOf reads the profile of a session, and only of a session', () => {
  assert.equal(profileOf({ command: SESSION('ClaudeLC') }), 'ClaudeLC');
  assert.equal(profileOf({ command: `/Applications/Claude.app/Contents/Helpers/disclaimer -- ${SESSION('ClaudeLC')}` }), 'ClaudeLC');
  assert.equal(profileOf({ command: 'node x.js' }), null);
});

test('locate finds the repo and worktree from the program, then the cwd', () => {
  assert.deepEqual(at(`node ${TREE}/x.js`), { root: ADB, worktree: 'feat-x' });
  assert.deepEqual(at('node ./vitest', `${TREE}/apps/ui`), { root: ADB, worktree: 'feat-x' });
  assert.deepEqual(at('node ./x', `${BRITY}/services`), { root: BRITY, worktree: MAIN });
  assert.deepEqual(at(`node ${ADB}/.claude/worktrees/gone/x.js`), { root: ADB, worktree: 'gone' });
});

test('locate leaves out what is not a process of a repo', () => {
  assert.equal(at('node /opt/homebrew/x.js', '/opt/homebrew'), null);
  assert.equal(at(`/bin/zsh -c cd ${TREE} && ls`), null, 'a shell only mentions the path');
  assert.equal(at('node ./x', `${SRC}/github.com/acme`), null, 'no .git up the tree');
  assert.equal(at(`${SESSION('ClaudeM', `--project-config-root ${ADB}`)}`, ADB), null);
  assert.equal(at(`/Applications/Claude.app/Contents/Helpers/disclaimer --pgroup -- ${TREE}/x`), null);
});

test('locate groups scratchpads apart, under their worktree', () => {
  const dir = '/tmp/claude-501/-Users-me-adb--claude-worktrees-feat-x/abc-1/scratchpad/main';
  assert.deepEqual(at('node ./x', `${dir}/apps`), {
    root: SCRATCHPADS,
    worktree: 'feat-x ↳ main',
    dir: `/private${dir}`,
  });
  assert.equal(at('node ./x', '/tmp/claude-501/-Users-me-adb/abc-1/scratchpad/cmp').worktree, 'adb ↳ cmp');
});

test('dirOf gives the directory of each kind of location', () => {
  assert.equal(dirOf({ root: ADB, worktree: MAIN }), ADB);
  assert.equal(dirOf({ root: ADB, worktree: 'feat-x' }), TREE);
  assert.equal(dirOf({ root: SCRATCHPADS, worktree: 'a ↳ b', dir: '/d' }), '/d');
});

test('testRunner names the main process of a run, not its wrappers', () => {
  assert.equal(testRunner({ command: `node ${TREE}/vitest/vitest.mjs run` }), 'vitest');
  assert.equal(testRunner({ command: `/opt/node ${TREE}/playwright/cli.js test` }), 'playwright');
  assert.equal(testRunner({ command: `node ${TREE}/@playwright/test/cli.js show-report` }), null);
  assert.equal(testRunner({ command: 'npm exec vitest run' }), null);
});

test('isGhost picks orphaned workerd and deleted worktrees, nothing else', () => {
  const exists = ctx.exists;
  const workerd = `${TREE}/node_modules/bin/workerd serve`;
  const where = { root: ADB, worktree: 'feat-x' };
  const orphan = { ppid: 1, age: 16 * 60, command: workerd, where };
  assert.equal(isGhost(orphan, exists), true);
  assert.equal(isGhost({ ...orphan, age: 60 }, exists), false);
  assert.equal(isGhost({ ...orphan, ppid: 9 }, exists), false);
  const gone = { ppid: 5, age: 9999, command: `node ${ADB}/.claude/worktrees/gone/x`, where: { root: ADB, worktree: 'gone' } };
  assert.equal(isGhost(gone, exists), true);
  assert.equal(isGhost({ ...gone, age: 60 }, exists), false);
  assert.equal(isGhost({ ...orphan, where: null }, exists), false);
  assert.equal(isGhost({ ...orphan, where: { root: SCRATCHPADS, worktree: 'a' } }, exists), false);
  assert.equal(isGhost({ ...gone, command: 'node ./x' }, exists), false, 'only a cwd: no proof it runs from there');
});

test('testProcesses keeps located runs and their direct children', () => {
  const where = { root: ADB, worktree: MAIN };
  const rows = [
    { pid: 10, ppid: 5, command: 'node /a/vitest.mjs run', where },
    { pid: 11, ppid: 10, command: 'workerd', where },
    { pid: 12, ppid: 5, command: 'node server.js', where },
    { pid: 13, ppid: 5, command: 'node /a/vitest.mjs run', where: null },
  ];
  assert.deepEqual(testProcesses(rows).map(row => row.pid), [10, 11]);
});

test('inScope keeps one repo by name or path, or all located rows', () => {
  const rows = [
    { pid: 1, where: { root: ADB } },
    { pid: 2, where: { root: BRITY } },
    { pid: 3, where: null },
  ];
  const pids = scope => inScope(rows, scope).map(row => row.pid);
  assert.deepEqual(pids({ repo: 'adb' }), [1]);
  assert.deepEqual(pids({ repo: BRITY }), [2]);
  assert.deepEqual(pids({ all: true }), [1, 2]);
});

test('lineage walks up to init, unknown parents and cycles included', () => {
  const rows = [
    { pid: 30, ppid: 20 },
    { pid: 20, ppid: 1 },
    { pid: 8, ppid: 9 },
    { pid: 9, ppid: 8 },
    { pid: 7, ppid: 6 },
  ];
  assert.deepEqual([...lineage(rows, 30)], [30, 20]);
  assert.deepEqual([...lineage(rows, 8)], [8, 9]);
  assert.deepEqual([...lineage(rows, 7)], [7, 6]);
});

test('ownerProfile finds the session a process descends from', () => {
  const rows = [
    { pid: 2, ppid: 1, command: SESSION('ClaudeM') },
    { pid: 3, ppid: 2, command: 'zsh' },
    { pid: 4, ppid: 3, command: 'node x.js' },
    { pid: 5, ppid: 1, command: 'node y.js' },
  ];
  assert.equal(ownerProfile(rows, 4), 'ClaudeM');
  assert.equal(ownerProfile(rows, 5), null);
});

test('programsOf gives the pid to kill, its tree summed, skipping npm wrappers', () => {
  const row = (pid, ppid, cpu, command) => ({ pid, ppid, cpu, rss: 1, command });
  const rows = [
    row(1, 900, 0, 'npm exec vitest run'),
    row(2, 1, 10, `node ${TREE}/vitest/vitest.mjs run`),
    row(3, 2, 30, 'node fork.js'),
    row(4, 3, 5, `${TREE}/bin/workerd serve`),
    row(5, 900, 50, 'node server.js'),
    row(6, 900, 0, 'node /x/pnpm/bin/pnpm.cjs dev'),
  ];
  const programs = programsOf(rows).map(p => [p.row.pid, p.cpu, p.rss]);
  assert.deepEqual(programs, [[5, 50, 1], [2, 45, 3], [6, 0, 1]]);
});

test('programLabel names a program in a few words', () => {
  const label = (command, cwd = '') => programLabel({ command, cwd }, TREE);
  assert.equal(label(`node ${TREE}/vitest/vitest.mjs run`, `${TREE}/apps/ui`), 'vitest apps/ui');
  assert.equal(label(`node ${TREE}/vitest/vitest.mjs run`, TREE), 'vitest .');
  assert.equal(label(`/opt/bin/node --flag ${TREE}/bin/wrangler.js dev --port 1`), 'wrangler.js dev');
  assert.equal(label(`${TREE}/bin/workerd serve`), 'workerd serve');
  assert.equal(label(`node ${TREE}/a.js ${TREE}/b.js`), 'a.js');
  assert.equal(label('node'), 'node');
});

test('topPrograms ranks across worktrees, cuts at n, leaves out unlocated rows', () => {
  const a = { root: ADB, worktree: 'a' };
  const b = { root: ADB, worktree: 'b' };
  const row = (pid, cpu, where) => ({ pid, ppid: 900, cpu, rss: 1, command: 'node x.js', where });
  const rows = [row(1, 5, a), row(2, 50, b), row(3, 20, a), row(4, 99, null)];
  assert.deepEqual(topPrograms(rows, 2).map(p => p.row.pid), [2, 3]);
});

test('resolveProfile takes a 1-based rank or a name', () => {
  const names = ['ClaudeInfra', 'ClaudeLC', 'ClaudeM', 'ClaudePierre'];
  assert.equal(resolveProfile('4', names), 'ClaudePierre');
  assert.equal(resolveProfile('claudepierre', names), 'ClaudePierre');
  assert.equal(resolveProfile('0', names), null);
  assert.equal(resolveProfile('5', names), null);
  assert.equal(resolveProfile('nope', names), null);
});

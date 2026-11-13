#!/usr/bin/env node
// Who heats the Mac, and stop it, across every repo under ~/src and every Claude profile.
//   heat                            → load, CPU/RAM per profile, then repo › worktree › branch with
//                                     its session and each program's pid, CPU, RAM and age; ghosts
//   heat for:<n>                    → the same, for one Claude profile: its alphabetical rank or name
//   heat top [n]                    → the n programs of the repos eating the most CPU (default 10)
//   heat kill <worktree>            → stops everything running from that worktree (name or prefix)
//   heat kill --ghosts              → orphaned workerd and processes of deleted worktrees
//   heat kill --tests               → the Vitest and Playwright runs, and the ghosts
//     --tests and --ghosts act on the repo you stand in; --repo <name> picks another, --all all
//   heat kill … --dry-run           → prints what it would stop, stops nothing
// Claude sessions and shells are never stopped.
import { execFileSync } from 'node:child_process';
import { existsSync, readdirSync, readFileSync, realpathSync, statSync } from 'node:fs';
import { cpus, homedir, loadavg } from 'node:os';
import { basename, dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const ORPHAN_MIN_AGE = 15 * 60;
const DEAD_WORKTREE_MIN_AGE = 2 * 60;
const SEPARATOR = '/.claude/worktrees/';
export const MAIN = '(main checkout)';
export const SCRATCHPADS = '(scratchpads)';

/** `[[dd-]hh:]mm:ss` (ps etime) → seconds. */
export function etimeSeconds(etime) {
  const [days, rest] = etime.includes('-') ? etime.split('-') : ['0', etime];
  const parts = rest.split(':').map(Number);
  while (parts.length < 3) parts.unshift(0);
  const [h, m, s] = parts;
  return Number(days) * 86400 + h * 3600 + m * 60 + s;
}

/** `ps -Ao pid=,ppid=,%cpu=,rss=,etime=,command=` plus `lsof -d cwd -Fpn` → process rows. */
export function parseProcesses(ps, lsof) {
  const cwd = new Map();
  let at = null;
  for (const line of lsof.split('\n')) {
    if (line.startsWith('p')) at = Number(line.slice(1));
    else if (line.startsWith('n') && at) cwd.set(at, line.slice(1));
  }
  return ps
    .split('\n')
    .map(line => line.trim().match(/^(\d+)\s+(\d+)\s+([\d.]+)\s+(\d+)\s+(\S+)\s+(.*)$/))
    .filter(Boolean)
    .map(([, pid, ppid, cpu, rss, etime, command]) => ({
      pid: Number(pid),
      ppid: Number(ppid),
      cpu: Number(cpu),
      rss: Number(rss) * 1024,
      age: etimeSeconds(etime),
      command,
      cwd: cwd.get(Number(pid)) ?? '',
    }));
}

/** The Claude app profile of a session process, null for anything else. */
export function profileOf({ command }) {
  return command.match(/Application Support\/(Claude\w*)\/claude-code\/.*\/MacOS\/claude(\s|$)/)?.[1] ?? null;
}

const isClaude = ({ command }) => profileOf({ command }) || /\/Helpers\/disclaimer /.test(command);

/** The nearest directory holding a `.git`, from `path` up, stopping at `src`. */
function gitTop(path, src, exists) {
  for (let dir = path; dir.startsWith(`${src}/`); dir = dirname(dir)) {
    if (exists(join(dir, '.git'))) return dir;
  }
  return null;
}

/** { root, worktree } of a path under `src`: `.git` is a file in a worktree, so a live one stops the walk. */
function locatePath(path, src, exists) {
  const top = gitTop(path, src, exists);
  if (!top) return null;
  const root = top.split(SEPARATOR)[0];
  const rest = path.startsWith(`${root}${SEPARATOR}`) ? path.slice(root.length + SEPARATOR.length) : '';
  return { root, worktree: rest.split('/')[0] || MAIN };
}

/**
 * Where a process runs from: its executable or script (the first three words), else its working
 * directory. A shell that merely mentions a path is never taken for a process running from it.
 * shortcut: a scratchpad's project name is an encoded path we cannot decode, so scratchpads form
 * their own group and `--repo` does not reach them; decode it if that ever matters.
 */
export function locate(row, { src, exists }) {
  if (isClaude(row)) return null;
  const scratch = `${row.cwd} ${row.command.split(/\s+/).slice(0, 3).join(' ')}`.match(
    /(\/(?:private\/)?tmp\/claude-\d+\/(-[^/\s]+)\/[\w-]+\/scratchpad\/([^/\s]+))/
  );
  if (scratch) {
    const [, dir, project, sub] = scratch;
    const owner = project.split('--claude-worktrees-')[1] ?? project.split('-').pop();
    return { root: SCRATCHPADS, worktree: `${owner} ↳ ${sub}`, dir: dir.replace(/^\/tmp\//, '/private/tmp/') };
  }
  const program = row.command.split(/\s+/).slice(0, 3).find(word => word.startsWith(`${src}/`));
  return (
    (program && locatePath(program, src, exists)) ||
    (row.cwd && locatePath(row.cwd, src, exists)) ||
    null
  );
}

/** The main process of a test run (not its workers, not the npm / pnpm wrapper), else null. */
export function testRunner({ command }) {
  const match = command.match(/^\S*node \S*(vitest\.mjs|playwright(?:\/test)?\/cli\.js test)\b/);
  if (!match) return null;
  return match[1] === 'vitest.mjs' ? 'vitest' : 'playwright';
}

/** The directory of a located process. */
export const dirOf = ({ root, worktree, dir }) =>
  dir ?? (worktree === MAIN ? root : `${root}${SEPARATOR}${worktree}`);

/** Located rows only: orphaned workerd, and processes of a worktree no longer on disk. */
export function isGhost(row, exists) {
  const { where } = row;
  if (!where || where.root === SCRATCHPADS) return false;
  const running = row.command.split(/\s+/)[0].startsWith(`${where.root}/`) || row.command.includes(`${where.root}/`);
  if (!running) return false;
  if (where.worktree !== MAIN && row.age >= DEAD_WORKTREE_MIN_AGE && !exists(dirOf(where))) return true;
  return row.ppid === 1 && row.age >= ORPHAN_MIN_AGE && /\/bin\/workerd(\s|$)/.test(row.command);
}

/** Located test runs and their direct children (forks, workerd, Playwright workers). */
export function testProcesses(rows) {
  const runs = new Set(rows.filter(row => row.where && testRunner(row)).map(row => row.pid));
  return rows.filter(row => runs.has(row.pid) || runs.has(row.ppid));
}

/** `pid` and its ancestors, nearest first. */
export function lineage(rows, pid) {
  const parents = new Map(rows.map(row => [row.pid, row.ppid]));
  const seen = new Set();
  for (let at = pid; at > 1 && !seen.has(at); at = parents.get(at)) seen.add(at);
  return seen;
}

/** The profile of the session a process descends from, null for one launched by hand. */
export function ownerProfile(rows, pid) {
  const byPid = new Map(rows.map(row => [row.pid, row]));
  for (const at of lineage(rows, pid)) {
    const profile = byPid.get(at) && profileOf(byPid.get(at));
    if (profile) return profile;
  }
  return null;
}

const isWrapper = ({ command }) =>
  command.split(/\s+/).slice(0, 2).some(word => /^(npm|npx|pnpm)(\.c?js)?$/.test(basename(word)));

/**
 * What runs in a group of rows: each top process, its pid the one to `kill`, with the CPU and RAM of
 * its whole tree. An npm / pnpm wrapper is skipped for the program it started.
 */
export function programsOf(rows) {
  const group = new Map(rows.map(row => [row.pid, row]));
  const hasChild = new Set(rows.map(row => row.ppid));
  const programs = new Map();
  for (const row of rows) {
    const chain = [...lineage(rows, row.pid)].map(pid => group.get(pid)).filter(Boolean);
    const top = chain.filter(link => !isWrapper(link)).at(-1) ?? (hasChild.has(row.pid) ? null : row);
    if (!top) continue;
    const program = programs.get(top.pid) ?? { row: top, cpu: 0, rss: 0 };
    program.cpu += row.cpu;
    program.rss += row.rss;
    programs.set(top.pid, program);
  }
  return [...programs.values()].sort((a, b) => b.cpu - a.cpu);
}

/** The `n` hungriest programs of all located rows, worktree by worktree so trees stay whole. */
export function topPrograms(rows, n) {
  const groups = Map.groupBy(rows.filter(row => row.where), row => dirOf(row.where));
  return [...groups.values()]
    .flatMap(programsOf)
    .sort((a, b) => b.cpu - a.cpu)
    .slice(0, n);
}

/** A short name: `vitest apps/ui`, `wrangler.js dev`, `workerd serve`. */
export function programLabel(row, dir) {
  const runner = testRunner(row);
  if (runner) {
    const base = `${dir}/`;
    return `${runner} ${row.cwd.includes(base) ? row.cwd.split(base)[1] : '.'}`;
  }
  const words = row.command.split(/\s+/);
  const args = words.slice(1).filter(word => !word.startsWith('-'));
  const [script, next] = basename(words[0]) === 'node' && args.length ? args : [words[0], args[0]];
  return next && !next.includes('/') ? `${basename(script)} ${next}` : basename(script);
}

/** The profile a `for:` argument names: its 1-based index in `names`, or its name in any case. */
export function resolveProfile(arg, names) {
  return names[Number(arg) - 1] ?? names.find(name => name.toLowerCase() === arg.toLowerCase()) ?? null;
}

/** Keeps the rows of `repo` (name or full path), of every repo with `all`. */
export function inScope(rows, { repo, all }) {
  if (all) return rows.filter(row => row.where);
  return rows.filter(
    row => row.where && (row.where.root === repo || basename(row.where.root) === repo)
  );
}

function sh(cmd, args) {
  try {
    return execFileSync(cmd, args, { encoding: 'utf8', stdio: ['ignore', 'pipe', 'ignore'] });
  } catch (error) {
    return error.stdout ?? '';
  }
}

const SRC = join(homedir(), 'src');

/** Every process, located. lsof stays on the runtimes: a shell gets no cwd, so it is never a victim. */
function processes() {
  const rows = parseProcesses(
    sh('ps', ['-Ao', 'pid=,ppid=,%cpu=,rss=,etime=,command=']),
    sh('lsof', ['-a', '-d', 'cwd', '-c', 'node', '-c', 'workerd', '-c', 'java', '-c', 'python', '-c', 'esbuild', '-Fpn'])
  );
  return rows.map(row => ({ ...row, where: locate(row, { src: SRC, exists: existsSync }) }));
}

/** The profiles installed on this Mac, alphabetical: their rank is the `for:` shortcut. */
function installedProfiles() {
  const support = join(homedir(), 'Library/Application Support');
  return readdirSync(support)
    .filter(name => /^Claude\w*$/.test(name) && existsSync(join(support, name, 'claude-code')))
    .sort((a, b) => a.localeCompare(b));
}

function branchOf(where) {
  const dir = dirOf(where);
  if (!existsSync(dir)) return where.dir ? 'scratch deleted' : 'worktree deleted';
  return sh('git', ['-C', dir, 'branch', '--show-current']).trim() || '(detached)';
}

/**
 * The title of the latest Claude conversation of a worktree: Claude Code keeps it in
 * `~/.claude/projects/<path with / and . as ->/<session>/custom-title.json`.
 */
function sessionTitle(where) {
  const project = join(homedir(), '.claude/projects', dirOf(where).replace(/[/.]/g, '-'));
  let latest = null;
  try {
    for (const session of readdirSync(project, { withFileTypes: true })) {
      if (!session.isDirectory()) continue;
      const file = join(project, session.name, 'custom-title.json');
      try {
        const at = statSync(file).mtimeMs;
        if (!latest || at > latest.at) latest = { file, at };
      } catch {
        // no title for this session
      }
    }
    return latest ? JSON.parse(readFileSync(latest.file, 'utf8')).customTitle : null;
  } catch {
    return null;
  }
}

/**
 * The conversation that launched a sub-agent: its transcript sits in
 * `~/.claude/projects/<parent's project>/<parent session>/subagents/<worktree>.meta.json`.
 */
function parentTitle({ root, worktree }) {
  const projects = join(homedir(), '.claude/projects');
  const prefix = root.replace(/[/.]/g, '-');
  try {
    for (const project of readdirSync(projects)) {
      if (!project.startsWith(prefix)) continue;
      for (const session of readdirSync(join(projects, project))) {
        const dir = join(projects, project, session);
        if (existsSync(join(dir, 'subagents', `${worktree}.meta.json`))) {
          const title = JSON.parse(readFileSync(join(dir, 'custom-title.json'), 'utf8'));
          return `sub-agent of « ${title.customTitle} »`;
        }
      }
    }
  } catch {
    // no title for the parent
  }
  return 'sub-agent of a session';
}

const gb = bytes => `${(bytes / 1024 ** 3).toFixed(1)} GB`;
const pct = cpu => `${Math.round(cpu)} %`;
const age = seconds =>
  seconds < 5400 ? `${Math.round(seconds / 60)} min` : `${(seconds / 3600).toFixed(1)} h`;
const stats = (cpu, rss) => `${pct(cpu).padStart(6)} ${gb(rss).padStart(8)}`;

function report(only) {
  const rows = processes();
  const names = installedProfiles();
  const groups = new Map();
  const profiles = new Map();
  const tally = (map, key, row) => {
    const entry = map.get(key) ?? { cpu: 0, rss: 0, count: 0, sessions: 0, rows: [], profiles: new Set() };
    entry.cpu += row.cpu;
    entry.rss += row.rss;
    entry.count += 1;
    map.set(key, entry);
    return entry;
  };
  for (const row of rows) {
    const profile = ownerProfile(rows, row.pid);
    if (only && profile !== only) continue;
    if (profile) {
      const entry = tally(profiles, profile, row);
      if (profileOf(row)) entry.sessions += 1;
    }
    if (!row.where) continue;
    const key = `${row.where.root} ${row.where.worktree}`;
    const group = tally(groups, key, row);
    group.where = row.where;
    group.rows.push(row);
    if (profile) group.profiles.add(profile);
  }
  const [one, five, fifteen] = loadavg().map(n => n.toFixed(1));
  console.log(`Load ${one} / ${five} / ${fifteen} (1 / 5 / 15 min) on ${cpus().length} cores\n`);
  for (const [i, profile] of names.entries()) {
    const entry = profiles.get(profile);
    if (entry) console.log(`${stats(entry.cpu, entry.rss)}  ${i + 1}: ${profile} (${entry.sessions} sessions)`);
  }
  if (profiles.size) console.log('');
  if (!groups.size) console.log('No process of a repo.\n');
  for (const group of [...groups.values()].sort((a, b) => b.cpu - a.cpu)) {
    const { where } = group;
    const repo = where.root === SCRATCHPADS ? where.root : basename(where.root);
    console.log(`[${pct(group.cpu)}, ${gb(group.rss)}] ${repo} › ${where.worktree} › ${branchOf(where)}`);
    const title = where.root === SCRATCHPADS ? null : sessionTitle(where);
    const label = title
      ? `« ${title} »`
      : where.worktree.startsWith('agent-')
        ? parentTitle(where)
        : null;
    const about = [...group.profiles, label].filter(Boolean).join(' · ');
    if (about) console.log(`  ${about}`);
    for (const { row, cpu, rss } of programsOf(group.rows)) {
      console.log(
        `${String(row.pid).padStart(8)}${stats(cpu, rss)} ${age(row.age).padStart(8)}  ${programLabel(row, dirOf(where))}`
      );
    }
    console.log('');
  }
  const ghosts = rows.filter(row => isGhost(row, existsSync));
  if (!only && ghosts.length) {
    console.log(`${ghosts.length} ghost(s), ${gb(ghosts.reduce((sum, g) => sum + g.rss, 0))}: heat kill --ghosts --all`);
  }
  if (groups.size) console.log('Stop one: kill <pid>   A whole worktree: heat kill <worktree>');
}

function top(n, only) {
  const rows = processes();
  const owned = only ? rows.filter(row => ownerProfile(rows, row.pid) === only) : rows;
  for (const { row, cpu, rss } of topPrograms(owned, n)) {
    const { where } = row;
    const repo = where.root === SCRATCHPADS ? where.root : basename(where.root);
    console.log(
      `${String(row.pid).padStart(8)}${stats(cpu, rss)} ${age(row.age).padStart(8)}  ${programLabel(row, dirOf(where))}  (${repo} › ${where.worktree})`
    );
  }
}

function kill(args) {
  const flag = name => {
    const at = args.indexOf(name);
    return at >= 0 ? args[at + 1] : undefined;
  };
  const dryRun = args.includes('--dry-run');
  const all = args.includes('--all');
  const named = flag('--repo');
  const target = args.find((arg, i) => !arg.startsWith('--') && args[i - 1] !== '--repo');
  const rows = processes();
  const self = lineage(rows, process.pid);
  const here = locatePathOfCwd();
  const scope = () => {
    if (!all && !named && !here) {
      console.error('Not in a repo: pass --repo <name> or --all');
      process.exit(1);
    }
    return inScope(rows, { repo: named ?? here, all });
  };
  let victims;
  if (args.includes('--ghosts')) {
    victims = scope().filter(row => isGhost(row, existsSync));
  } else if (args.includes('--tests')) {
    const scoped = scope();
    const pids = new Set(scoped.map(row => row.pid));
    victims = [
      ...testProcesses(rows).filter(row => pids.has(row.pid)),
      ...scoped.filter(row => isGhost(row, existsSync)),
    ];
  } else if (target) {
    const pool = named ? inScope(rows, { repo: named }) : rows.filter(row => row.where);
    const label = ({ where }) => `${basename(where.root)}/${where.worktree}`;
    const hits = pool.filter(row => row.where.worktree === target || row.where.worktree.startsWith(target));
    // a worktree and the checkouts its session made in its scratchpad go together
    const owners = new Set(hits.map(row => `${row.where.root} ${row.where.worktree.split(' ↳ ')[0]}`));
    if (owners.size !== 1) {
      console.error(
        owners.size
          ? `« ${target} » matches several worktrees: ${[...new Set(hits.map(label))].join(', ')}`
          : `No process in a worktree « ${target} ». See: heat`
      );
      process.exit(1);
    }
    victims = hits;
  } else {
    console.error('Usage: heat kill <worktree> | --ghosts | --tests [--repo <name> | --all] [--dry-run]');
    process.exit(1);
  }
  victims = [...new Map(victims.map(v => [v.pid, v])).values()].filter(v => !self.has(v.pid));
  for (const victim of victims) {
    if (dryRun) {
      console.log(`${victim.pid}\t${victim.command.slice(0, 110)}`);
    } else {
      try {
        process.kill(victim.pid, 'SIGTERM');
      } catch {
        // already gone
      }
    }
  }
  if (dryRun || !victims.length) {
    console.log(victims.length ? `${victims.length} processes (nothing stopped)` : 'Nothing to stop.');
    return;
  }
  // a wrangler dev ignores SIGTERM sometimes: SIGKILL what is still there after 3 s
  setTimeout(() => {
    let forced = 0;
    for (const victim of victims) {
      try {
        process.kill(victim.pid, 0);
        process.kill(victim.pid, 'SIGKILL');
        forced += 1;
      } catch {
        // stopped
      }
    }
    console.log(
      `${victims.length} processes stopped${forced ? ` (${forced} forced)` : ''}, ${gb(victims.reduce((sum, v) => sum + v.rss, 0))} freed.`
    );
  }, 3000);
}

const locatePathOfCwd = () => locatePath(process.cwd(), SRC, existsSync)?.root ?? null;

if (process.argv[1] && realpathSync(process.argv[1]) === fileURLToPath(import.meta.url)) {
  const args = process.argv.slice(2);
  const scope = args.find(arg => arg.startsWith('for:'));
  const [command, ...rest] = args.filter(arg => arg !== scope);
  const names = installedProfiles();
  const only = scope ? resolveProfile(scope.slice(4), names) : null;
  if (scope && !only) {
    console.error(`Unknown profile « ${scope} ». ${names.map((name, i) => `${i + 1}: ${name}`).join(', ')}`);
    process.exit(1);
  }
  if (command === 'kill') kill(rest);
  else if (command === 'top') top(Number(rest[0]) || 10, only);
  else report(only);
}

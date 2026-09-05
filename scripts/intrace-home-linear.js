#!/usr/bin/env node

// Read-only Linear query for the Neovim title card. It intentionally has no
// package dependencies and never writes credentials or cache files.
const fs = require("node:fs");
const os = require("node:os");
const path = require("node:path");

function loadEnv() {
  const envPath = path.join(os.homedir(), ".pi", "agent", ".env");
  if (!fs.existsSync(envPath)) return;
  for (const line of fs.readFileSync(envPath, "utf8").split(/\r?\n/)) {
    const match = line.trim().match(/^([A-Za-z_][A-Za-z0-9_]*)=(.*)$/);
    if (!match || process.env[match[1]] !== undefined) continue;
    process.env[match[1]] = match[2].replace(/^["']|["']$/g, "");
  }
}

function transitionAt(issue) {
  const transitions = (issue.history?.nodes || [])
    .filter((item) => item.toState?.name === issue.state.name)
    .map((item) => item.createdAt)
    .sort()
    .reverse();
  return transitions[0] || issue.completedAt || issue.updatedAt || issue.createdAt;
}

function rank(status) {
  return { "In Review": 1, "In Progress": 2, Done: 3, Todo: 4 }[status] || 9;
}

function summarize(issue) {
  return {
    identifier: issue.identifier,
    title: issue.title,
    url: issue.url,
    status: issue.state.name,
    statusColor: issue.state.color,
    priority: issue.priority,
    dueDate: issue.dueDate,
    transitionAt: transitionAt(issue),
  };
}

async function main() {
  loadEnv();
  const token = process.env.LINEAR_API_KEY;
  if (!token) process.exit(2);

  const query = `
    query HomeActivity($active: IssueFilter, $fallback: IssueFilter) {
      active: issues(first: 100, filter: $active, orderBy: updatedAt) {
        nodes {
          id identifier title url priority createdAt updatedAt completedAt dueDate
          state { name type color }
          assignee { name displayName }
          history(first: 25) { nodes { createdAt fromState { name } toState { name } } }
        }
      }
      fallback: issues(first: 100, filter: $fallback, orderBy: updatedAt) {
        nodes {
          id identifier title url priority createdAt updatedAt completedAt dueDate
          state { name type color }
          assignee { name displayName }
          history(first: 25) { nodes { createdAt fromState { name } toState { name } } }
        }
      }
    }`;

  const team = { team: { name: { eq: process.env.INTRACE_LINEAR_TEAM || "Dev" } } };
  const variables = {
    active: { and: [team, { state: { name: { in: ["In Review", "In Progress"] } } }] },
    fallback: { and: [team, { state: { name: { in: ["Done", "Todo"] } } }] },
  };

  const response = await fetch("https://api.linear.app/graphql", {
    method: "POST",
    headers: { Authorization: token, "Content-Type": "application/json" },
    body: JSON.stringify({ query, variables }),
    signal: AbortSignal.timeout(7000),
  });
  const payload = await response.json();
  if (!response.ok || payload.errors?.length) process.exit(3);

  const now = Date.now();
  const recentDoneCutoff = now - 14 * 24 * 60 * 60 * 1000;
  const all = [...payload.data.active.nodes, ...payload.data.fallback.nodes]
    .filter((issue) => issue.assignee?.name)
    .filter((issue) => issue.state.name !== "Done" || Date.parse(issue.completedAt || issue.updatedAt) >= recentDoneCutoff);

  const byPerson = new Map();
  for (const issue of all) {
    const name = issue.assignee.name;
    if (!byPerson.has(name)) byPerson.set(name, []);
    byPerson.get(name).push(summarize(issue));
  }

  const groups = [...byPerson.entries()].map(([assignee, issues]) => {
    issues.sort((a, b) => rank(a.status) - rank(b.status) || Date.parse(b.transitionAt) - Date.parse(a.transitionAt));
    return {
      assignee,
      hasActive: issues.some((issue) => issue.status === "In Review" || issue.status === "In Progress"),
      issues: issues.slice(0, 4),
    };
  });

  groups.sort((a, b) => {
    if (a.hasActive !== b.hasActive) return a.hasActive ? -1 : 1;
    const ar = rank(a.issues[0]?.status);
    const br = rank(b.issues[0]?.status);
    return ar - br || Date.parse(b.issues[0]?.transitionAt || 0) - Date.parse(a.issues[0]?.transitionAt || 0);
  });

  process.stdout.write(JSON.stringify({ fetchedAt: new Date().toISOString(), groups }));
}

main().catch(() => process.exit(4));

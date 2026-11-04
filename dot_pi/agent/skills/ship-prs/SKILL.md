---
name: ship-prs
description: Turn a topic into the smallest independently-shippable PRs, with parallel builds for independent slices and review follow-up through approval.
disable-model-invocation: true
---

# Ship PRs

Take the topic the user gave and ship it as **slices**: the smallest PRs that each merge to `main` on their own. Each slice runs its own build-and-open cycle; independent slices may run in parallel.

A **slice** is one PR that is independently shippable: it merges to `main` alone, without waiting for any later slice, and merging it never breaks prod. Every PR must contain no more than **300 changed lines** (insertions plus deletions), counting production code, tests, migrations, and configuration. This is a hard limit, not a target: if a slice would exceed 300 changed lines, split it into additional independently shippable slices before building. Do not exceed the limit because of urgency, dependencies, migrations, tests, or review convenience. Prefer many small slices over one large PR — small is easier to review. Slices may **stack** (branch off the previous slice's branch instead of `main`) when one genuinely depends on another; a stacked slice is still scoped so its own merge is safe.

## 1. Grill the topic

Load and follow the `grilling` skill on the topic the user passed in. Ask grilling questions strictly one at a time: wait for the user's answer before asking the next question, and never batch multiple questions in one message. Resolve every design branch and dependency before moving on.

Before writing code, confirm new vocabulary (type, package, and port names) with the user. Naming found elsewhere in the codebase is not approval for newly introduced vocabulary. Confirm any new names that emerge during implementation before using them.

**Done when:** you and the user share a clear, complete understanding of what's being built and agree on the new vocabulary identified so far.

## 2. Propose the slice plan

Break the work into the smallest independently shippable slices. Minimize the scope of each PR, not the number of PRs. For each, the merge-safety test must hold: it ships to `main` alone and merging it can't break prod. Decide which slices stack and which are independent and can be built in parallel.

Present the plan to the user: the number of slices, each slice's scope in one line, and its branch base (`main` or the slice it stacks on). If the whole topic is already small and clear, propose a single slice and say so.

**Done when:** the user has signed off on the number of slices and their scope. Do not build before sign-off.

## 3. Choose the implementation workflow

After the user signs off on the slice plan, and before isolating or building any slice, ask explicitly:

> Do you want to enable `subagent-driven-development` for this run? Reply yes or no.

Wait for an explicit answer. Do not infer the choice from urgency, previous preferences, or approval of the slice plan. Apply the answer to every approved slice unless the user asks to change it.

**Done when:** the user has answered yes or no.

## 4. Build and open each slice

Schedule the approved slices by dependency. Independent slices may be built in parallel when separate workers and worktrees are available and the user's workflow choice permits subagents. Otherwise, build sequentially. A stacked slice starts after its base slice's PR is open; it need not wait for that PR's approval.

Each slice follows its own cycle:

1. **Isolate.** Load and follow `using-git-worktrees` to create a dedicated worktree so parallel agents never collide. Branch off `main` for an independent slice, off its planned base branch for a stacked one.
2. **Build.** If enabled, load and follow `subagent-driven-development`, treating this slice's scope as its plan — fresh implementer subagent per task, TDD, task review, and the final whole-branch review. If disabled, skip `subagent-driven-development` and implement directly in the isolated worktree while preserving the repository's testing and review requirements. (This `create-pr` step replaces SDD's finishing-a-development-branch.)
3. **Open the PR.** Load and follow `create-pr` to open the slice's pull request **as a draft** (`gh pr create --draft`). Leave it for the user to mark ready for review.
4. **Record and share** the slice's PR title, link, and one-line summary immediately, and start its review watch from step 5. Each slice's agent brief includes building, opening, watching reviews, handling findings, and maintaining its stack.

**Done when:** every approved slice has an open PR and an active review watch or approval on its latest head.

**Never batch.** Open each slice's PR as soon as its build and checks pass, without waiting for other slices to finish. Parallelism overlaps independent cycles; it does not defer PR creation to the end of a batch.

## 5. Follow reviews and maintain stacks

### Review findings

After opening each PR and after every push, watch review comments until `reviewDecision` is `APPROVED` on the latest head. Approval on an earlier commit does not complete the watch. Drafts remain drafts until the user marks them ready for review; keep the watch active while waiting.

- Use one background loop per PR. Record review, PR comment, and inline comment counts at start; exit when any count changes or the PR is approved. A background command wakes the responsible agent when it exits. Handle new findings, then restart the watch if the latest head is not approved. Stop the previous loop before starting another.
- Apply a fix only when the finding is relevant to the agreed design and prior decisions; otherwise reply with why. Re-verify fixes before pushing. Resolve each thread with a short answer after handling its finding.
- If an agent hands back before approval, the coordinator checks that its watch is still running and restarts it through the agent if needed.

### Stacked PRs

- A stacked PR tracks the current head of its base branch. Whenever the base gets a new commit, immediately rebase the stacked PR onto it, re-verify, and push with `--force-with-lease`.
- Propagate each changed base through the stack from bottom to top before continuing dependent work. The coordinator ensures that a push to a base also triggers its dependent PR's agent to rebase, re-verify, and push.
- After a base PR is squash-merged, rebase the next PR's own commits onto `main`, excluding the base commits already squash-merged, and retarget that PR to `main`. Re-verify and push with `--force-with-lease`, then update any PRs stacked above it in the same bottom-up order.

**Done when:** every PR is approved on its latest head, all review findings are handled and threads resolved, and stacked branches are up to date and verified.

## 6. Report

For every PR opened, output one block:

- **Title** — the PR title
- **Link** — the PR URL
- **What it does** — one line
- **Review status** — approval on the latest head, or pending review with an active watch in an interim report

<!-- Install as: <each code repo> -> .github/pull_request_template.md -->

## What this does

<!-- Behaviour change, in plain language. -->

## Why

<!-- Link the change request: Closes control-theory/docs#<n>. Every planned change
     carries one — it is what ties this merge back to an approved request.

     Emergency change with no prior CR? Write EMERGENCY on the line below and ship it,
     then open the change request straight after and come back and link it. The Change
     Management Policy explicitly allows post-implementation registration where time
     constraints prevent registering first. Do not sit on a production fix waiting for
     a ticket number. -->

CR: control-theory/docs#

## Depends on

<!-- Other PRs that must merge first, in order. Delete if none. -->

## Evidence

<!-- Test output, CI run link, screenshots, or the command you ran and its result.
     "Tests pass" on its own is not evidence — link the run. -->

## Deployment notes

<!-- Migrations, backfills, feature flags, config/values changes, ordering
     constraints, or anything that is not "ships with the next chart release".
     Include how to back this out. Delete if none. -->

## Reviewer checklist

<!-- A human approving review is required to merge into main; the approver is never the
     author. Copilot code review is optional -- request it from the Reviewers panel when
     it would help. If Copilot (or anyone) leaves review comments, every thread must be
     resolved or answered before the merge unblocks. -->

- [ ] The description above matches the code that is actually merging (no stale design notes)
- [ ] Tests cover the change, and CI is green on the final commit
- [ ] Security/privacy implications considered (auth on new endpoints, secrets handling, tenant isolation, data in logs)
- [ ] Any review comments left on this PR -- human or automated (Copilot) -- are resolved or answered in-thread
- [ ] Approver is not the author

# Contributing to Netersoft projects

This guide applies to every repository in the organization.

## Git workflow

Netersoft projects follow **GitHub Flow**: `master` is the only long-lived
branch and is always deployable. There's no `develop`, `release`, or
long-lived environment branch.

1. Branch from `master` (see naming convention below).
2. Keep branches short-lived — open a PR as soon as there's something
   reviewable rather than letting a branch accumulate a large diff.
3. Merge back into `master` via PR once CI is green and approved.
4. Hotfixes follow the exact same path — branch from `master`, PR, merge.
   There's no separate hotfix process; urgency is handled through review
   priority, not by skipping CI or review.
5. Delete the branch once merged.

## Branches

- `feature/<short-name>` — new feature
- `fix/<short-name>` — bug fix
- `chore/<short-name>` — technical task with no functional impact

## Commits

Short, explicit, type + description:

```text
feat: add login screen
fix: correct pagination on the orders list
chore: bump dependencies
```

## Package manager

JS/TS dependencies are managed with **pnpm** — do not use `npm install` or `yarn add`, and don't commit `package-lock.json`/`yarn.lock`.

## Code style

- PHP (Laravel): [Pint](https://laravel.com/docs/pint) must pass before merge
- JS/TS (AdonisJS, Vue, React): ESLint + Prettier must pass before merge
- Dart (Flutter): `flutter analyze` and `dart format` must pass before merge

## Opening a Pull Request

1. Branch from `master` following the naming convention above.
2. Fill in the PR template — do not delete sections, mark items not applicable as N/A.
3. Make sure CI is green before requesting a review.
4. At least one approval is required before merging (see branch protection rules).
5. Squash-merge once approved, unless the repo's README says otherwise.

## Reporting a bug / requesting a feature

Use the issue templates — they ask for the information reviewers need to act quickly. Issues without enough context to reproduce or evaluate may be closed and asked to use the template.

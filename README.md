# Cocogitto github action

This action uses [cocogitto](https://github.com/oknozor/cocogitto) to check 
your repository is [conventional commit](https://conventionalcommits.org/) and perform auto-release.

## Requirement
-
1. Before running this action you need to call checkout action with `fetch-depth: 0`. This is mandatory, otherwise not all commit 
will be fetched and cocogitto will fail to execute (see [actions/checkout](https://github.com/actions/checkout#checkout-v2) for more info).

2. Cocogitto assumes you are running on a x86 linux runner.

## Example 

```yaml
on: [push]

jobs:
  cog_check_job:
    runs-on: ubuntu-latest
    name: check conventional commit compliance
    steps:
      - uses: actions/checkout@v2
        with:
          fetch-depth: 0

      - name: Conventional commit check
        uses: oknozor/cocogitto-action@v1
```

If you are familiar with cocogitto this will run `cog check` and nothing else.

## Check commits since latest tag 

In some case you might want to perform check only since the latest tagged version.
If your repository has not alway been conventional commit compliant, then you probably want to 
use this option. 

```yaml
      - name: Conventional commit check
        uses: oknozor/cocogitto-action@v1
        with:
          check-latest-tag-only: true
```

Let us assume the following git history : 

```
* 9b609bc - (HEAD -> main) WIP: feat unfinished work
* d832ca4 - feat: working on feature A
* d5ce110 - (tag: 0.1.0) chore: release 0.1.0
* 8f25a4b - chore: a commit before tag 0.1.0
```

Using `check-latest-tag-only: true` here would make cocogitto check for the two commits made since
tag `0.1.0`, the action would fail on *HEAD* which contains the non conventional commit
type 'WIP'.

## Performing release

You can also use this action to perform releases (calling `cog bump --auto` under the hood) 
(see: [cocogitto's auto bump](https://github.com/oknozor/cocogitto#auto-bump)).

```yaml
      - name: Semver release
        uses: oknozor/cocogitto-action@v1
        id: release
        with:
          release: true
          git-user: 'Cog Bot'
          git-user-email: 'mycoolproject@org.org'

      # The version number is accessible as a github action output
      - name: Print version
        run: "echo '${{ steps.release.outputs.version }}'"
```

Note that you probably want to set the `git-user` and `git-user-email` options to override the default the git signature for the release commit. 
If you are not familiar with how cocogitto perform release, you might want to read the [auto bump](https://github.com/oknozor/cocogitto#auto-bump)
and [hook](https://github.com/oknozor/cocogitto#auto-bump) sections on cocogitto's documentation.

##  Reference 

Here are all the inputs available through `with`:

| Input                   | Description                                                                | Default    |
| -------------------     | -------------------------------------------------------------------------- | -------    |
| `check`                 | Check conventional commit compliance with `cog check`                      |   `true`   |
| `check-latest-tag-only` | Check conventional commit compliance with `cog check --from-latest-tag`    |   `false`  |
| `release`               | Perform a release using `cog bump --auto`                                  |   `false`  |
| `git-user`              | Set the git `user.name` to use for the release commit                      |   `cog-bot`|
| `git-user-email`        | Set the git `user.email` to use for the release commit                      |  `cog@demo.org`|






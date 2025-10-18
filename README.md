# Cocogitto github action

This action uses [cocogitto](https://github.com/cocogitto/cocogitto) to check
your repository is [conventional commit](https://conventionalcommits.org/) and perform auto-release.

## Requirement

Before running this action you need to call checkout action with `fetch-depth: 0`. This is mandatory, otherwise not all commit
will be fetched and cocogitto will fail to execute (see [actions/checkout](https://github.com/actions/checkout#checkout-v4) for more info).

## Example

```yaml
on: [push]

jobs:
  cog_check_job:
    runs-on: ubuntu-latest
    name: check conventional commit compliance
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Conventional commit check
        uses: cocogitto/cocogitto-action@v4
        with:
          command: check
```

If you are running your workflow `on: [pull_request]`,
additional setup for `actions/checkout` is needed to checkout the right commit:

```yaml
on: [pull_request]

jobs:
  cog_check_job:
    runs-on: ubuntu-latest
    name: check conventional commit compliance
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
          # pick the pr HEAD instead of the merge commit
          ref: ${{ github.event.pull_request.head.sha }}

      - name: Conventional commit check
        uses: cocogitto/cocogitto-action@v4
        with:
          command: check
```

## Check commits since latest tag

In some case you might want to perform check only since the latest tagged version.
If your repository has not always been conventional commits compliant, then you probably want to
use this option.

```yaml
      - name: Conventional commit check
        uses: cocogitto/cocogitto-action@v4
        with:
          command: check
          args: --from-latest-tag
```

Let us assume the following git history :

```
* 9b609bc - (HEAD -> main) WIP: feat unfinished work
* d832ca4 - feat: working on feature A
* d5ce110 - (tag: 0.1.0) chore: release 0.1.0
* 8f25a4b - chore: a commit before tag 0.1.0
```

Using `args: --from-latest-tag` here would make cocogitto check for the two commits made since
tag `0.1.0`, the action would fail on *HEAD* which contains the non-conventional commit
type 'WIP'.

## Performing release

You can also use this action to perform releases (calling `cog bump --auto` under the hood)
(see: [cocogitto's auto bump](https://github.com/cocogitto/cocogitto#auto-bump)).

```yaml
      - name: Semver release
        uses: cocogitto/cocogitto-action@v4
        id: release
        with:
          command: bump
          args: --auto
          git-user: 'Cog Bot'
          git-user-email: 'mycoolproject@org.org'

      # The version number is accessible as a github action output
      - name: Print version
        run: "echo '${{ steps.release.outputs.version }}'"
```

Note that you probably want to set the `git-user` and `git-user-email` options to override the default the git signature for the release commit.
If you are not familiar with how cocogitto perform release, you might want to read the [auto bump](https://github.com/cocogitto/cocogitto#auto-bump)
and [hook](https://github.com/cocogitto/cocogitto#auto-bump) sections on cocogitto's documentation.

## Generating a Changelog

You can also use this action to generate a changelog for your releases.

Here's an example of how to set up a GitHub Actions workflow to generate a changelog when a new tag is pushed:

```yaml
name: Create Release

on:
  push:
    tags:
      - "v*.*.*"

jobs:
  create_release:
    name: Publish release
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: SemVer release
        id: release
        uses: cocogitto/cocogitto-action@main
        with:
          command: changelog
          args: --at ${{ github.ref_name }}

      - name: Upload github release
        uses: softprops/action-gh-release@v2
        with:
          body: ${{ steps.release.outputs.stdout }}
          tag_name: ${{ github.ref_name }}
```

In this example, the workflow is triggered on a push event when a new tag matching the pattern `v*.*.*` is created. The `cocogitto-action` is used to generate a changelog for the release, and the `softprops/action-gh-release` action is used to create a GitHub release with the generated changelog as the release body.

## Post step run

Once the step is finished cocogitto's binary will be available in your path.

##  Reference

Here are all the inputs available through `with`:

| Input       | Description                                                                                      | Default        |
|-------------|--------------------------------------------------------------------------------------------------|----------------|
| `command`   | The cocogitto command to run (e.g., check, release)                                             | (required)     |
| `args`      | Additional arguments for the cocogitto command                                                  | `""`           |

The following outputs are available through the GitHub `steps.<step_id>.outputs` context:

| Output      | Description                                                                                      | Default        |
|-------------|--------------------------------------------------------------------------------------------------|----------------|
| `version`   | The new version number after a successful release                                                | `""`           |
| `stdout`    | The standard output from the cocogitto command                                                   | `""`           |

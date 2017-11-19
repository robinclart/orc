# Orc

`orc` (the name is a tribute to `arc` from which this is inspired) is a tool that helps you create, list, review and in general work with pull requests from the comfort of the command line. The utlimate aims being to reduce the amount of time spent reviewing and help you do better reviews since you will be doing it from the comfort of your favorite editor, diff tool, etc.

## Commands

### Creating a Pull Request

```
orc pr [BASE_BRANCH]
```

Create a pull request on GitHub based on the supplied base branch or using default base branch in the config file. This command will open your $EDITOR. The first line is to be used as the title of the PR and the rest will be used as the body. If a PR already exist for the current branch the url for the existing PR will be returned the same as if it had just been created but note that the PR title and body won't be overwritten. An empty title and body will abort the command.

### Amend the Remote Branch

```
orc amend
```

Git push force the current branch.

### List Authors & Counts

```
orc authors
```

List all authors that currently have a PR open. Example:

```
francois (3)
ton (4)
tommy (2)
```

### List Pull Requests

```
orc list [AUTHOR]
```

List all PRs for the given AUTHOR. Or list all PRs if no AUTHOR was given.

### Read Pull Request Description

```
orc read [PR]
```

Read the description for a given PR number or for the current branch.

### Review a Pull Request

```
orc review PR
```

Checkout the branch for the given PR number and display the PR title and body. Note that if we're already on the right branch this will do nothing.

### Add Label to a Pull Request

```
orc label [--pr NUMBER] NAME [NAME...]
```

Add the given labels to the current branch's PR or to the PR that was supplied as option.

## TODO

### Add a Comment

```
orc comment PATH:LINE
```

Open your `$EDITOR` for you to provide a comment. The comment will be saved until you call one of `orc-comments`, `orc-request-changes` or `orc-approve` upon which it will be sent along every other comments you have written.

### Submit Comments

```
orc comments
```

Submit all comments and create review in `COMMENT` state.

### Submit Comments & Request Changes

```
orc request-changes
```

Submit all comments and create a review in `REQUEST_CHANGES` state.

### Submit Comments & Approve Pull Request

```
orc approve
```

Submit all comments and create a review in `APPROVE` state.

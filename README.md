# Orc

`orc` (the name is a tribute to `arc` from which this is inspired) is a tool that helps you create, list, review and in general work with pull requests from the comfort of the command line. The utlimate aims being to reduce the amount of time spent reviewing and help you do better reviews since you will be doing it from the comfort of your favorite editor, diff tool, etc.

`orc pr`

Push the current branch. Create a file called PULL_REQUEST. Open the file in `$EDITOR`. Once the file is saved and the editor closed, create a PR with the content of the PULL_REQUEST file where the first line will be the title and add the `pr:review` label. Finally remove the PULL_REQUEST file.

`orc amend`

Git push force the current branch or the branch associated with a given PR number if given.

`orc authors`

List all authors that currently have a PR open. Example:

    francois (3)
    ton (4)
    tommy (2)
    ...

`orc list AUTHOR`

List all PRs for the given AUTHOR.

`orc read PR`

Read the description for a given PR number.

`orc review PR`

Checkout the branch for the given PR number and display the PR description. If we're already on the right branch do nothing.

`orc comment some/file.rb:387`

Create a file called COMMENT and open in `$EDITOR`. Upon release create a file called COMMENTS and add the content of COMMENT or append it if COMMENTS already exist. File should be a JSON ready to sent to the GitHub API.

`orc comments [PR]`

Submit all comments and create review in `COMMENT` state.

`orc request-changes [PR]`

Submit all comments and create a review in `REQUEST_CHANGES` state.

`orc approve [PR]`

Submit all comments and create a review in `APPROVE` state.

`orc merge [PR]`

Merge the given PR or to the PR associated to the current branch.

`orc label NAME [PR]`

Add the given label to the current branch PR or to the given PR number.

`orc rebuild [PR]`

Force rebuild the current branch on jenkins or the branch associated to the given PR number.

`orc gist PATH`

Create a gist with the content of the given file (or through stdin) and return the url.

## This is only a dream

Now time to make it real.

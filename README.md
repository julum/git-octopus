# git-octopus
![logo](image.jpeg)

Update all repositories in target directory with one command.

Do you have a lot of repositories which are dependent to each other like microservice components you are developing? 
Update now alle repositories with one command!

Iterates over all subdirectories and performs a Git Fetch & Merge operation if the directory is a Git directory.

## Installation
Install it via Bash:
```
sh -c $(curl -fSsL https://raw.githubusercontent.com/julum/git-octopus/master/tools/install.sh)
```

This will clone Git-Octopus to `~/.git-octopus` and appends
`source ~/.git-octopus/git-octopus.sh` to your default Shell `rc`-File (e.g. 
`~/.bashrc` or `~/.zshrc`). You can speficy the target RC-File with:

```
export RC_FILE="target_rc-file-name"
sh -c $(curl -fSsL https://raw.githubusercontent.com/julum/git-octopus/master/    tools/install.sh)
```

The default of the `RC_FILE` variable is set to '~/.zshrc'

## Usage
### Show branches
```
git-octopus branches
```
List all subdirectories which are Git repositories and prints the current branch:
```
$> git-octopus branches
my-repo1 ➜ master
my-repo2 ➜ feature/ISSUE-45
my-repo3 ➜ master
my-repo4 ➜ feature/ISSUE-123
```
### Update projects
```
git-octopus [<pattern>]
```
Iterates over all subdirectories containing `<pattern>` of current directory,
fetches from all remotes and then merges into current branch but only **if fast forward is possible**

It does not perform any merge commits.

#### Example
*Update all Repositories in current directory*

```
$> git-octopus
Updating Git repositories...

WARNING: Only merges fast forward merges. Only possible remote is origin

=========================
my-repo1
==========================

Current branch is master
> git fetch --all --force --prune --progress
> git merge --ff-only
Done.

=========================
my-repo2
==========================

Current branch is master
> git fetch --all --force --prune --progress
> git merge --ff-only
Done.

Summary:
✔ my-repo1
✔ my-repo2

```

*Update all repositories containing `repo2` in currenct directory*:
```
$> git-octopus
Updating Git repositories...

WARNING: Only merges fast forward merges. Only possible remote is origin

=========================
my-repo2
==========================

Current branch is master
> git fetch --all --force --prune --progress
> git merge --ff-only
Done.

Summary:
✔ my-repo2
```

*Do not update a repository if it has uncommitted changes*:
```
$> git-octopus
=========================
my-repo1
==========================

Already on 'master'
Your branch is up to date with 'origin/master'.
Already up to date.


=========================
my-repo2
==========================

error: Your local changes to the following files would be overwritten by checkout:
	package.json
Please commit your changes or stash them before you switch branches.
Aborting

Summary:
✔ my-repo1
X my-repo2

```

### Checkout master branch in every repository
Checkout the master branch and update it if possible. Do not a checkout if changes would be overwritten.

```
$> git-octopus checkout-master
 =========================
 my-repo1
 ==========================

 Already on 'master'
 Your branch is up to date with 'origin/master'.
 Already up to date.


 =========================
 my-repo2
 ==========================

 error: Your local changes to the following files would be overwritten by checkout:
     package.json
 Please commit your changes or stash them before you switch branches.
 Aborting

=========================
  my-repo3
==========================

 Switched to branch 'master'
Your branch is up to date with 'origin/master'.
Already up to date.

=========================
my-repo4
==========================

Already on 'master'
Your branch is up to date with 'origin/master'.
Already up to date.


Summary:
 ✔ my-repo1
 X my-repo2
 ✔ my-repo3
 ✔ my-repo4
```

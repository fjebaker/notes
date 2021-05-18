# Git Reference

As everyone with git, there is a tendency to use the same idioms over and over. Here are some of the ones I don't use frequently enough to have committed to memmory, but still use frequently enough that researching how to do them again is a nuisance.

<!--BEGIN TOC-->
## Table of Contents
1. [`format-patch`](#format-patch)
2. [`am`](#am)
3. [`apply`](#apply)
4. [`stash`](#stash)
5. [`rebase`](#rebase)
    1. [Changing Author](#changing-author)
    2. [Merging commits with `rebase`](#merging-commits-with-rebase)
6. [`cherry-pick`](#cherry-pick)
    1. [Keeping commit references](#keeping-commit-references)
    2. [Multi-branch operations](#multi-branch-operations)
7. [Recipes](#recipes)
    1. [Adding aliases](#adding-aliases)
    2. [Reverting to a given commit](#reverting-to-a-given-commit)
8. [Tagging](#tagging)
9. [GitHub action recipes](#github-action-recipes)
10. [Triangular workflow](#triangular-workflow)
11. [Configuration](#configuration)
    1. [Editor configuration](#editor-configuration)
    2. [Authentication](#authentication)
12. [Using SSH](#using-ssh)
    1. [Generating keypairs](#generating-keypairs)
    2. [Uploading public keys](#uploading-public-keys)
    3. [Changing repository origin](#changing-repository-origin)

<!--END TOC-->

## `format-patch`
Used for exporting commits to send as text. This command has a whole [series of options](https://git-scm.com/docs/git-format-patch), including automated patch delivery via email.

The simplest application is
```bash
git format-patch [commit_hash]
```
with the argument `-[n]` for number of commits to include (e.g. for 3 commits, `-3`).

Another useful variant is
```bash
git format-patch origin
```
for extracting all commits in the current branch but not in the origin repository.

For extracting commits between two revisions
```bash
git format-patch [R1]..[R2]
```

If the intention is to apply with tools like `git am`, the `-k` flag can be used to keep the subject.

## `am`
[Applies from mailbox](https://git-scm.com/docs/git-am) patches onto the current tree, e.g.
```bash
git am *.patch
```

In contrast to [`apply`](#apply), `am` adds the commits into the working tree.

## `apply`
[Applies](https://git-scm.com/docs/git-apply) patches onto the current working directory, but does not add the commits to the tree
```bash
git apply [patchfile]
```

## `stash`
Temporarily storing modifications may be done with [`git stash`](https://www.git-scm.com/docs/git-stash). To stash the changes made, and revert back to `HEAD`, simply
```bash
git stash
```
which is equivalent to `stash push`.

To pop these changes back onto the current `HEAD`
```bash
git stash apply
```
`apply` is very similar to the `stash pop` command, except it doesn't remove the item from the stash list.

You can list all stashes with
```bash
git stash list
```
and inspect details with
```bash
git stash show [stash]
```

To remove a stash from the list, use
```bash
git stash drop
```
Stashing is best used when either pulling a conflicting branch, or handling an interrupted workflow.

## `rebase`
Different recipes and use-cases for `git rebase`.

### Changing Author
Use
```bash
git rebase -i -p [commit hash]
```
where the commit hash is the last "good" commit. From there, preprend `edit` to the commits you want to alter, and follow the instructions:


Use 
```bash
git commit --amend --author "username <email@addr.com>"
```
to change the author for the specific commit, followed by 
```bash
git rebase --continue
```
until you are back at the top of the tree. Check the changes were successful with
```bash
git log
```

### Merging commits with `rebase`
We can use e.g.
```bash
git rebase -i HEAD~3
```
to modify information relating to the last 3 commits, and use either `squash` or `fixup` to merge commits, depending whether we want to hold onto the commit message or not.

Changes must be *forced* pushed.

## `cherry-pick`
Used to pick commits from one branch to another (see [documentation page](https://git-scm.com/docs/git-cherry-pick)).

Cherry pick takes commits and applies them to the `HEAD`. As such, checkout the branch of interest:
- to pick a single commit (by hash, or from the tip of another branch)
```bash
git cherry-pick <commit|branch>
```
- to pick a range of commits `A` through `B`, not including `A`
```bash
git cherry-pick A..B
```
To include `A` use `A^`.
- apply the e.g. 4th commit from a branch
```bash
git cherry-pick A~3
```

### Keeping commit references
By default, `cherry-pick` will create a new commit in the current branch. To keep the commit reference, use the `-x` flag
```bash
git cherry-pick -x <commit>
```

### Multi-branch operations
To apply commits from `branch1` or `branch2` but not if they are present in `branch3`
```bash
git cherry-pick branch1 branch2 ^branch3
```
In the case
```
branch1   branch2   branch3
A         A         A
B         D         B
C         E         E
```
the above command will only apply `C` and `D`.

## Recipes
Solutions to common problems.

### Adding aliases
You can add an alias to git using the configuration options: for example, a common use case would be to alias the command
```
alias.logadog=log --all --decorate --oneline --graph
```
which can either be done by adding the above to your git configuration file, or using
```bash
git config --add alias.logadog "log --all --decorate --oneline --graph"
```

To unset aliases, simply remove the line from the config file, or use 
```bash
git config --unset alias.[aliasname]
```

### Reverting to a given commit
Reverting a single file (or the whole branch) can be done with `checkout`, see [docs](https://git-scm.com/docs/git-checkout). It may be used
```bash
git checkout [commit/branch] [file, ...]
```
You can preview the changes with the [`diff` command](https://git-scm.com/docs/git-diff):
```bash
git diff [commit/branch] [file, ...]
```

You can also use the [`reset` command](https://git-scm.com/docs/git-reset) to reset the `HEAD` to a specific commit, using different modes
```bash
git reset [--mode] [commit]
```
Commonly used modes are `--hard`, which discards all changes in the working tree, `--merge`, which will essentially perform a merge of the current tree into the destination tree, and `--keep`, which updates files in the working tree that differ.

## Tagging
We can add tags to our local repository with
```bash
git tag -a v1.0 -m "message"
```
where we use the `-a` flag to annotate the tag. We have to push tags individually to the remote, which can be done with
```bash
git push origin [tag_name]
```
or, to push all
```bash
git push origin --tags
```

For more information, [see the docs](https://git-scm.com/book/en/v2/Git-Basics-Tagging).


## GitHub action recipes

Building and deploying a vue static webpage to github pages can be achieved with use of the [`JamesIves/github-pages-deploy-action` action](https://github.com/JamesIves/github-pages-deploy-action). We can specify a artifact generator and consumer in a `build` and `deploy` approach:
```yml
jobs:

  build:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    # install deps and build
    - run: |
        npm i
        npm run build
    - name: Caching dist directory
      # upload as artifact
      uses: actions/upload-artifact@v2
      with:
        name: dist
        path: dist
        if-no-files-found: error

  deploy:
      needs: build # dependency / chaining
      runs-on: ubuntu-latest
      steps:

      # consume artifact
      - uses: actions/download-artifact@v2
        with:
          name: dist

      - name: Deploy to gh-pages branch
        uses: JamesIves/github-pages-deploy-action@3.7.1
        with:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          BRANCH: gh-pages
          FOLDER: .
          CLEAN: true
          SINGLE_COMMMIT: true
```
This is a little contrived, and maybe there is an argument to be made as making the deployment job part of the build. However, for posterity if nothing else, this method works as well.


## Triangular workflow
When working on a fork of a project you wish to keep updated, it is useful to add the original repository as an upstream remote, so that you can update your master branch if you've left it stale for too long, without having to open a PR on your fork:
```bash
git remote add upstream [upstream-url]
git fetch upstream/master

# and to rebase master HEAD; make sure you're on your local master  
git checkout master
git rebase upstream/master


# and push changes to the remote fork
git push -f origin master
```

## Configuration
Configuring `git`.

### Editor configuration
```bash
git config --global core.editor "vim"
```

### Authentication
To configure global authentication locally, use
```bash
git config --global user.name "username"

git config --global user.email "email@addr.com"
```


## Using SSH
Overview of using SSH for Git(Hub) interaction.

### Generating keypairs
Using the email associated with your Git identity:
```bash
ssh-keygen -t ed25519 -C "your@email.com"
```
You may wish to name this file along the lines of `id_git` so that it's easy to remember what it's for.

### Uploading public keys
- GitHub
Under Account Settings, SSH and GPG keys, add a new SSH, give it a memorable name, and then copy the contents of 
```bash
~/.ssh/id_[yourkey].pub
```
i.e. your public key, into the text field and save.

### Changing repository origin
To change your git client to use SSH over HTTP(s), simply change the origin url to the general format
```bash
git remote set-url origin git@github.com:<uname>/<repository>.git
```
# Git Reference

As everyone with git, there is a tendency to use the same idioms over and over. Here are some of the ones I don't use frequently enough to have committed to memmory, but still use frequently enough that researching how to do them again is a nuisance.

<!--BEGIN TOC-->
## Table of Contents
1. [GitHub action recipes](#toc-sub-tag-0)
2. [Triangular work ethic](#toc-sub-tag-1)
3. [Using `rebase`](#toc-sub-tag-2)
	1. [Changing Author](#toc-sub-tag-3)
	2. [Merging commits with `rebase`](#toc-sub-tag-4)
4. [Reverting to a given commit](#toc-sub-tag-5)
5. [Tagging](#toc-sub-tag-6)
6. [Authentication](#toc-sub-tag-7)
7. [Editor configuration](#toc-sub-tag-8)
<!--END TOC-->

## GitHub action recipes <a name="toc-sub-tag-0"></a>

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


## Triangular work ethic <a name="toc-sub-tag-1"></a>
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

## Using `rebase` <a name="toc-sub-tag-2"></a>

### Changing Author <a name="toc-sub-tag-3"></a>
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

### Merging commits with `rebase` <a name="toc-sub-tag-4"></a>
We can use e.g.
```bash
git rebase -i HEAD~3
```
to modify information relating to the last 3 commits, and use either `squash` or `fixup` to merge commits, depending whether we want to hold onto the commit message or not.

Changes must be *forced* pushed.

## Reverting to a given commit <a name="toc-sub-tag-5"></a>
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

## Tagging <a name="toc-sub-tag-6"></a>
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


## Authentication <a name="toc-sub-tag-7"></a>
To configure global authentication locally, use
```bash
git config --global user.name "username"

git config --global user.email "email@addr.com"
```

## Editor configuration <a name="toc-sub-tag-8"></a>
```bash
git config --global core.editor "vim"
```
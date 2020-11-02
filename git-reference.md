# Git Reference

As everyone with git, there is a tendency to use the same idioms over and over. Here are some of the ones I don't use frequently enough to have committed to memmory, but still use frequently enough that researching how to do them again is a nuisance.


## Triangular workflows
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

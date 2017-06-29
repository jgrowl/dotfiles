# Git

## Checkout by date

https://stackoverflow.com/a/6990682/127280

### You can checkout a commit by a specific date using rev-parse like this

`git checkout 'master@{1979-02-26 18:30:00}'`

### Checkout out by date using rev-list 

``git checkout `git rev-list -n 1 --before="2009-07-27 13:37" master```

## Add in chunks

https://stackoverflow.com/a/1085191/127280
http://nuclearsquid.com/writings/git-add/

`git add --patch <filename>`

```
y stage this hunk for the next commit
n do not stage this hunk for the next commit
q quit; do not stage this hunk or any of the remaining hunks
a stage this hunk and all later hunks in the file
d do not stage this hunk or any of the later hunks in the file
g select a hunk to go to
/ search for a hunk matching the given regex
j leave this hunk undecided, see next undecided hunk
J leave this hunk undecided, see next hunk
k leave this hunk undecided, see previous undecided hunk
K leave this hunk undecided, see previous hunk
s split the current hunk into smaller hunks
e manually edit the current hunk
? print hunk help
```

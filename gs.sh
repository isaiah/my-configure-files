#!/bin/sh

#TRUNK_HASH=`git show-ref --hash master`
TRUNK_HASH=`git show-ref --hash remotes/git-svn`
REV=`git svn find-rev "$TRUNK_HASH"`

if [ "$#" -eq 0 ]
then
HASHES="$TRUNK_HASH"
#HASHES="$TRUNK_HASH..HEAD"
else
HASHES="$1"
fi

INDEX_SEPARATOR="==================================================================="
SRC_PREFIX="REVIEWBOARD-SRC-PREFIX"
DST_PREFIX="REVIEWBOARD-DST-PREFIX"

# Note: removed the $* to support passing a hash as the first argument
git diff --src-prefix="${SRC_PREFIX}" --dst-prefix="${DST_PREFIX}" "$HASHES" |
sed "
# New files have /dev/null as their original path
/^--- \/dev\/null/{
# Read a line into the pattern space
N
# Do a multiline substitution
s/^--- \/dev\/null\n+++ ${DST_PREFIX}\(.*\)$/--- \1\t(revision 0)\n+++ \1\t (working copy)/
# Jump to the end of the script. This skips the next two substitutions
b end
}
/^diff --git /{
# Read a line into the pattern space
N
# In case there is no 'new file mode' line
/^diff --git ${SRC_PREFIX}\(.*\) ${DST_PREFIX}.*\nindex .*$/{
s/^diff --git ${SRC_PREFIX}\(.*\) ${DST_PREFIX}.*\nindex .*$/Index: \1\n${INDEX_SEPARATOR}/
b end
}
# There is a 'new file mode' line
# Read a third line
N
# In case there is a 'new file mode' line
/^diff --git ${SRC_PREFIX}\(.*\) ${DST_PREFIX}.*\nnew file mode .*\nindex .*$/{
# Do a multiline substitution
s/^diff --git ${SRC_PREFIX}\(.*\) ${DST_PREFIX}.*\nnew file mode .*\nindex .*$/Index: \1\n${INDEX_SEPARATOR}/
b end
}
# In case there is a 'deleted file mode' line
/^diff --git ${SRC_PREFIX}\(.*\) ${DST_PREFIX}.*\ndeleted file mode .*\nindex .*$/{
# Do a multiline substitution
s/^diff --git ${SRC_PREFIX}\(.*\) ${DST_PREFIX}.*\ndeleted file mode .*\nindex .*$/Index: \1\n${INDEX_SEPARATOR}/
b end
}
# There is an 'old mode' line
# Read a forth line
N
# Do a multiline substitution
s/^diff --git ${SRC_PREFIX}\(.*\) ${DST_PREFIX}.*\nold mode .*\nnew mode .*\nindex .*$/Index: \1\n${INDEX_SEPARATOR}/
b end

}
/^--- ${SRC_PREFIX}\(.*\)/{
# Read a line into the pattern space
N
# Do a multiline substitution
s/^--- ${SRC_PREFIX}\(.*\)\n+++ .*$/--- \1\t(revision ${REV})\n+++ \1\t (working copy)/
# Jump to the end of the script. This skips the next two substitutions
b end
}
: end
"

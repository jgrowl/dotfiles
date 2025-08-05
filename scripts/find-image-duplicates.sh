#!/bin/bash

# Default to current directory if not provided
DIR="${1:-.}"

# Only process common image formats
find "$DIR" -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.gif' -o -iname '*.bmp' -o -iname '*.webp' \) \
  -print0 | xargs -0 sha256sum | sort | awk '
{
    hash = $1
    file = substr($0, index($0, $2))
    hashes[hash] = hashes[hash] ? hashes[hash] "\n" file : file
}
END {
    for (h in hashes) {
        split(hashes[h], files, "\n")
        if (length(files) > 1) {
            print "🔁 Duplicate group (hash: " h "):"
            for (i in files) print "  " files[i]
            print ""
        }
    }
}
'


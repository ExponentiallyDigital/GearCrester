#!/usr/bin/env bash
set -e

echo "Generating local release_history.txt preview..."
echo

git log \
  --pretty=format:"COMMIT %ad%n%B" \
  --date=short \
  --numstat \
  | awk '
    /^COMMIT / {
        if (started) print "";
        started=1;
        sub(/^COMMIT /, "— ");
        print;
        in_message=1;
        next;
    }

    # Blank line inside commit message
    in_message && NF==0 {
        print "    ";
        next;
    }

    # Commit message lines (non-numstat)
    in_message && !($1 ~ /^[0-9-]+$/ && $2 ~ /^[0-9-]+$/) {
        print "    " $0;
        next;
    }

    # File stats: real numstat lines only
    ($1 ~ /^[0-9-]+$/ && $2 ~ /^[0-9-]+$/) {
        in_message=0;
        ins=$1; del=$2;
        file=$3;
        for (i=4; i<=NF; i++) file = file " " $i;

        if (ins=="-" && del=="-") {
            printf "    %s | added\n", file;
            next;
        }

        printf "    %s | %s insertion%s, %s deletion%s\n",
            file,
            ins, (ins=="1"?"":"s"),
            del, (del=="1"?"":"s");
        next;
    }
  ' > release_history.txt

echo "Done. Output written to release_history.txt"
echo
echo "Preview:"
echo "----------------------------------------"
cat release_history.txt
echo "----------------------------------------"

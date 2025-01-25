#!/bin/bash
################## SKELETON: DO NOT TOUCH THESE 2 LINES
EXEDIR=`dirname "$0"`; BASENAME=`basename "$0" .sh`; TAB='	'; NL='
'
#################### ADD YOUR USAGE MESSAGE HERE, and the rest of your code after END OF SKELETON ##################
USAGE="USAGE: $BASENAME input-edge-list
PURPOSE: take a (weighted or unweighted) directed edge list and for each edge, if both directions exist then print only
    the edge with the higher weight (be sure to remove any header line yourself)."

################## SKELETON: DO NOT TOUCH CODE HERE
# check that you really did add a usage message above
USAGE=${USAGE:?"$0 should have a USAGE message before sourcing skel.sh"}
die(){ echo "$USAGE${NL}FATAL ERROR in $BASENAME:" "$@" >&2; exit 1; }
[ "$BASENAME" == skel ] && die "$0 is a skeleton Bourne Shell script; your scripts should source it, not run it"
echo "$BASENAME" | grep "[ $TAB]" && die "Shell script names really REALLY shouldn't contain spaces or tabs"
[ $BASENAME == "$BASENAME" ] || die "something weird with filename in '$BASENAME'"
warn(){ (echo "WARNING: $@")>&2; }
not(){ if eval "$@"; then return 1; else return 0; fi; }
newlines(){ awk '{for(i=1; i<=NF;i++)print $i}' "$@"; }
parse(){ awk "BEGIN{print $*}" </dev/null; }
which(){ echo "$PATH" | tr : "$NL" | awk '!seen[$0]{print}{++seen[$0]}' | while read d; do eval /bin/ls $d/$N; done 2>/dev/null | newlines; }

#################### END OF SKELETON, ADD YOUR CODE BELOW THIS LINE

[ $# -le 1 ] || die "expecting at most one filename [otherwise use stdin]"

# Basic idea: every node is split into TWO nodes: one takes all incoming edges (%s.i) and one all outgoing (%.o).
# Then, we pair them with "heavy" edge, to ensure they remain paired.
HEAVY_EDGE=10000
sed 's///' "$@" | fgrep -v ' ' | tr , "$TAB" | # the tr is to allow CSV files as input
    hawk '{ASSERT(NF==3,"network must be weighted with 3 columns"); ASSERT(1*$3,"third column is not a number");}
	{ASSERT('$HEAVY_EDGE'>9*$3, "Found an edge too big for heavy edge to be 9x the biggest");}
	$1!=$2{++D[$1];++D[$2]; printf "%s.o\t%s.i\t%s\n",$1,$2,$3}
	END{for(v in D)printf "%s.i\t%s.o\t10000\n",v,v}'

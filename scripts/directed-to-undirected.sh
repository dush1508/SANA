#!/bin/bash
################## SKELETON: DO NOT TOUCH THESE 2 LINES
EXEDIR=`dirname "$0"`; BASENAME=`basename "$0" .sh`; TAB='	'; NL='
'
#################### ADD YOUR USAGE MESSAGE HERE, and the rest of your code after END OF SKELETON ##################
USAGE="USAGE: $BASENAME input-edge-list
PURPOSE: take a (weighted or unweighted) directed edge list and for each edge, if both directions exist then print only
    the edge with the higher weight (be sure to remove any header line yourself). Self-loops are also removed."

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

sed 's///' "$@" | tr , "$TAB" | awk '$1!=$2' |
    hawk '{ASSERT(NF==2||NF==3,"must have 2 or 3 columns");if(NF==3)ASSERT(1*$3,"third column is not a number");}
	($2 in edge) && ($1 in edge[$2]){
	    if(ABS($3)>ABS(edge[$2][$1]))
		delete edge[$2][$1]; #delete the other one and continue to the next block to assign THIS one
	    else
		next; # otherwise keep the other one and skip the assignment in the next block
	}
	{edge[$1][$2]=$3}
	END{
	    for(u in edge)for(v in edge[u]) printf "%s\t%s\t%s\n",u,v,edge[u][v]
	}'

#!/bin/sh

usage() {
    echo "$0 <issue> [-n] file.tex [file...]"
    echo
    echo -e 'Issues:'
    echo -e ' - opts-paper-font\tremove fontsize and add a4paper class options'
    echo -e ' - tabular-center \tAdd \\centerline around \\begin{tabular}...\\end{tabular}'
    echo -e ' - cite           \tReplace \\cite with \\citep'
    echo -e ' - quotes         \tReplace "..." with \\say{...}'
    echo -e ' - contractions   \tExpand contractions'
    echo
    echo -e 'Arguments:'
    echo -e ' -n\tDo not modify source files, instead print the result to STDOUT.'
    echo -e '   \tThis argument can also be used without input files, in which case the input is taken from STDIN.'
}

if (( $# < 2 )); then
    usage
    exit 1
fi

SED=$(shell which gsed 2>/dev/null || which sed)

issue="$1"
shift

if [ "$1" = "-n" ]; then
    shift
    SED_OPTS=""
else
    SED_OPTS="-i"
fi

case $issue in
    opts-paper-font)
        $SED $SED_OPTS 's/[0-9]\+pt, *\(% *8-20pt *possible.*\)\?/a4paper,/' $@;;
    tabular-center)
        $SED $SED_OPTS 's/\\begin{tabular}/\\centerline{\\begin/g' $@
        $SED $SED_OPTS 's/\\end{tabular}/\\end{tabular}}/g' $@;;
    caption-period)
        $SED $SED_OPTS 's/\\caption{\(.*[^.]\)}/\\caption{\1.}/g' $@;;
    cite)
         $SED $SED_OPTS 's/\\cite *{/\\citep{/g' $@;;
    quotes)
         $SED $SED_OPTS 's/"\([^"]*\)"/\\say{\1}/g' $@;;
    contractions)
         $SED $SED_OPTS \
              "s/\(do\|does\|is\)n't/\1 not/gi;
               s/\(can\)'t/\1not/gi;
               s/\(w\)on't/\1ill not/gi;
               s/\(let\)'s/\1 us/gi;" $@;;
    *)
        echo "ERROR: Invalid issue: $issue"
        echo
        usage
        exit 1;;
esac

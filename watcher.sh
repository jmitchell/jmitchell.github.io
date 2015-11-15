#!/bin/bash

PREPROC_DIR=$1
PUB_DIR=$2

PORT=8888
URL="http://localhost:$PORT"

function monitor {
    (fswatch -r -t -o "$PREPROC_DIR" | xargs -n1 -I{} make refresh_preview) &
    jobs+=($!)
}

function serve {
    pushd "$PUB_DIR" > /dev/null
    python -m SimpleHTTPServer "$PORT" >/dev/null 2>&1 &
    jobs+=($!)
    popd > /dev/null
}

function view {
    sleep 1 && open -a "Google Chrome" $URL
}

function cleanup {
    kill -15 $jobs >/dev/null 2>&1
    pkill -f SimpleHTTPServer >/dev/null 2>&1
}

trap cleanup EXIT HUP TERM INT
monitor && serve && view
wait

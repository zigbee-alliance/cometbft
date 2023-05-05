#!/usr/bin/env bash

declare -a tests=("EmptyCache" "NonEmptyCache")

MAIN_TLA_FILE="MempoolV0MC.tla"
TRACE_MAX_LENGTH=5
MAX_ERRORS=10
TRACES_ROOT_DIR="./traces"

for TEST in "${tests[@]}"; do
    echo "Sampling $TEST on $MAIN_TLA_FILE..."
    OUT_DIR=./_apalache-out/$TEST
    NEGATED_TEST=Not$TEST
    time apalache-mc check --features=no-rows \
        --cinit=ConstInit --length=$TRACE_MAX_LENGTH --max-error=$MAX_ERRORS --view=View \
        --inv="$NEGATED_TEST" \
        --out-dir="$OUT_DIR" \
        "$MAIN_TLA_FILE"
    
    LAST_GENERATED_DIR=$(ls -rt "$OUT_DIR/$MAIN_TLA_FILE/" | tail -1)
    OUT_DIR="$OUT_DIR/$MAIN_TLA_FILE/$LAST_GENERATED_DIR"

    TRACES_DIR="$TRACES_ROOT_DIR/$TEST"
    mkdir -p "$TRACES_DIR"
    rm -f "$TRACES_DIR/*.itf.json"

    echo "cp $OUT_DIR/*.itf.json $TRACES_DIR"
    cp "$OUT_DIR/*.itf.json" "$TRACES_DIR"
    rm "$TRACES_DIR/violation.itf.json"

    ls -a "$TRACES_DIR/*.itf.json" | xargs -I{} bash -c "mv $0 ${0/violation/sample}" {}
done
#!/bin/bash

DALIAS_ROOT=""
DALIAS_DIR=""
OLD_DALIAS_ROOT=""
OLD_DALIAS_DIR=""
OLD_PATH=""

setup() {
	TEST_DIR=$(mktemp -d)
	mkdir -p $TEST_DIR/dalias_root
	mkdir -p $TEST_DIR/dalias_dir
	OLD_DALIAS_ROOT="$DALIAS_ROOT"
	OLD_DALIAS_DIR="$DALIAS_DIR"
	DALIAS_ROOT="$TEST_DIR/dalias_root"
	export DALIAS_ROOT
	DALIAS_DIR="$TEST_DIR/dalias_dir"
	export DALIAS_DIR
	OLD_PATH=$PATH
	PATH=$DALIAS_ROOT/bin:$PATH
	export PATH
	ln -sf "$PWD/../bin" $DALIAS_ROOT/bin
}

teardown() {
	rm -rf $TEST_DIR
	DALIAS_ROOT="$OLD_DALIAS_ROOT"
	export DALIAS_ROOT
	DALIAS_DIR="$OLD_DALIAS_DIR"
	export DALIAS_DIR
	PATH=$OLD_PATH
	export PATH
}

test_creates_global_shim() {
	res=0
	setup
	../bin/dalias add foo bar
	[[ -x $DALIAS_ROOT/shims/foo ]] || res=1
	teardown
	return $res
}

test_creates_local_alias_script() {
	res=0
	setup
	../bin/dalias add foo bar
	[[ -x $DALIAS_DIR/foo ]] || res=1
	teardown
	return $res
}

test_fails_with_existing_alias() {
	res=0
	setup
	touch $DALIAS_DIR/foo
	chmod +x $DALIAS_DIR/foo
	../bin/dalias add foo bar 2>/dev/null
	[[ $? -eq 0 ]] && res=1
	teardown
	return $res
}

declare -a TEST_FUNCS
TEST_FUNCS[0]="test_creates_global_shim"
TEST_FUNCS[1]="test_creates_local_alias_script"
TEST_FUNCS[2]="test_fails_with_existing_alias"

for i in "${!TEST_FUNCS[@]}"; do
	echo -n "${TEST_FUNCS[$i]}: "
	${TEST_FUNCS[$i]}
	res=$?
	if [[ $res -eq 0 ]]; then
		echo "PASS"
	else
		echo "FAIL"
	fi
done

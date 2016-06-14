#!/usr/bin/env bats

load test_helper

@test "creates global shim" {
	assert [ ! -x "${DALIAS_ROOT}/shims/dalias-exec-shim" ]
	run dalias-add foo bar
	assert_success
	assert [ -x "${DALIAS_ROOT}/shims/dalias-exec-shim" ]
}

@test "creates global symlink" {
	assert [ ! -h "${DALIAS_ROOT}/shims/foo" ]
	run dalias-add foo bar
	assert_success
	assert [ -h "${DALIAS_ROOT}/shims/foo" ]
}

@test "creates the local alias directory" {
	assert [ ! -d "${DALIAS_LOCAL}" ]
	run dalias-add foo bar
	assert_success
	assert [ -d "${DALIAS_LOCAL}" ]
}

@test "creates local alias script" {
	assert [ ! -x "${DALIAS_LOCAL}/foo" ]
	run dalias-add foo bar
	assert_success
	assert [ -x "${DALIAS_LOCAL}/foo" ]
}

@test "fails with existing local alias" {
	mkdir -p "${DALIAS_LOCAL}"
	touch "${DALIAS_LOCAL}/foo"
	chmod +x "${DALIAS_LOCAL}/foo"
	run dalias-add foo bar
	assert_failure
}

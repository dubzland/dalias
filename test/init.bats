#!/usr/bin/env bats

load test_helper

@test "creates shims directory" {
	assert [ ! -d "${DALIAS_ROOT}/shims" ]
	run dalias-init
	assert_success
	assert [ -d "${DALIAS_ROOT}/shims" ]
}

@test "creates links directory" {
	assert [ ! -d "${DALIAS_ROOT}/links" ]
	run dalias-init
	assert_success
	assert [ -d "${DALIAS_ROOT}/links" ]
}

@test "adds shims directory to the path" {
	export PATH="${BATS_TEST_DIRNAME}/../libexec:/usr/bin:/bin:/usr/local/bin"
	run dalias-init
	assert_success
	assert_line 0 'export PATH="'${DALIAS_ROOT}'/shims:${PATH}"'
}


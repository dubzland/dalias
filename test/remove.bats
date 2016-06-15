#!/usr/bin/env bats

load test_helper

@test "deletes local alias" {
	make_dir "${DALIAS_LOCAL}"
	touch "${DALIAS_LOCAL}/foo" && chmod +x "${DALIAS_LOCAL}/foo"
	assert [ -x "${DALIAS_LOCAL}/foo" ]
	run dalias-remove foo
	assert_success
	assert [ ! -x "${DALIAS_LOCAL}/foo" ]
}

@test "deletes the global shim symlink when no other aliases exist" {
	make_dir "${DALIAS_ROOT}/shims"
	ln -s "${DALIAS_ROOT}/shims/dalias-exec-shim" "${DALIAS_ROOT}/shims/foo"
	echo -e "foo,${DALIAS_LOCAL}/foo" > "${DALIAS_ROOT}/links.csv"
	run dalias-remove foo
	assert_success
	assert [ ! -h "${DALIAS_ROOT}/shims/foo" ]
}

@test "leaves the global symlink when other aliases exist" {
	make_dir "${DALIAS_ROOT}/shims" "${DALIAS_LOCAL}"
	ln -s "${DALIAS_ROOT}/shims/dalias-exec-shim" "${DALIAS_ROOT}/shims/foo"
	touch "${DALIAS_LOCAL}/foo" && chmod +x "${DALIAS_LOCAL}/foo"
	touch "${DALIAS_LOCAL}/bar" && chmod +x "${DALIAS_LOCAL}/bar"
	echo -e "foo,${DALIAS_LOCAL}/foo\nfoo,${DALIAS_LOCAL}/bar" > "${DALIAS_ROOT}/links.csv"
	run dalias-remove foo
	assert_success
	assert [ -h "${DALIAS_ROOT}/shims/foo" ]
}

@test "removes the entry from the store" {
	make_dir "${DALIAS_ROOT}"
	echo "foo,${DALIAS_LOCAL}/foo" > "${DALIAS_ROOT}/links.csv"
	run dalias-remove foo
	assert_success
	assert_equal 0 $(grep -c "foo," "${DALIAS_ROOT}/links.csv" || true)
}

@test "leaves other aliases without the -g flag" {
	make_dir "${DALIAS_ROOT}" "${DALIAS_LOCAL}"
	touch "${DALIAS_LOCAL}/foo" && chmod +x "${DALIAS_LOCAL}/foo"
	touch "${DALIAS_LOCAL}/bar" && chmod +x "${DALIAS_LOCAL}/bar"
	echo -e "foo,${DALIAS_LOCAL}/foo\nfoo,${DALIAS_LOCAL}/bar" > "${DALIAS_ROOT}/links.csv"
	run dalias-remove foo
	assert_success
	assert_equal 1 $(grep -c "foo," "${DALIAS_ROOT}/links.csv" || true)
	assert [ ! -f "${DALIAS_LOCAL}/foo" ]
	assert [ -f "${DALIAS_LOCAL}/bar" ]
}

@test "removes all aliases with the -g flag" {
	make_dir "${DALIAS_ROOT}" "${DALIAS_LOCAL}"
	touch "${DALIAS_LOCAL}/foo" && chmod +x "${DALIAS_LOCAL}/foo"
	touch "${DALIAS_LOCAL}/bar" && chmod +x "${DALIAS_LOCAL}/bar"
	echo -e "foo,${DALIAS_LOCAL}/foo\nfoo,${DALIAS_LOCAL}/bar" > "${DALIAS_ROOT}/links.csv"
	run dalias-remove -g foo
	assert_success
	assert_equal 0 $(grep -c "foo," "${DALIAS_ROOT}/links.csv" || true)
	assert [ ! -f "${DALIAS_LOCAL}/foo" ]
	assert [ ! -f "${DALIAS_LOCAL}/bar" ]
}

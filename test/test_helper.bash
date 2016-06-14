if [[ -z "${DALIAS_TEST_DIR}" ]]; then
	DALIAS_TEST_DIR="${BATS_TMPDIR}/dalias"
	export DALIAS_TEST_DIR="$(mktemp -d "${DALIAS_TEST_DIR}.XXX")" # 2>/dev/null || echo "$DALIAS_TEST_DIR")"
	export DALIAS_ROOT="${DALIAS_TEST_DIR}/root"
	export DALIAS_LOCAL="${DALIAS_TEST_DIR}/local"
	export HOME="${DALIAS_TEST_DIR}/home"

	PATH=/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin
	PATH="${DALIAS_TEST_DIR}/bin:$PATH"
	PATH="${BATS_TEST_DIRNAME}/../libexec:$PATH"
	PATH="${BATS_TEST_DIRNAME}/libexec:$PATH"
	PATH="${DALIAS_ROOT}/shims:$PATH"
	export PATH
fi

# setup() {
# 	return 0
# }

teardown() {
	rm -rf "${DALIAS_TEST_DIR}"
}

failit() {
	{ if [[ "$#" -eq 0 ]]; then cat -
		else echo "$@"
		fi
	} | sed "s:${DALIAS_TEST_DIR}:TEST_DIR:g" >&2
	return 1
}

assert() {
	if ! "$@"; then
		failit "failed: $@"
	fi
}

assert_output() {
	local expected
	if [[ $# -eq 0 ]]; then
		expected=$(cat -)
	else
		expected="$1"
	fi
	assert_equal "${expected}" "${output}"
}

assert_success() {
	if [[ "${status}" -ne 0 ]]; then
		failit "failed with status code ${status}"
	elif [[ "$#" -gt 0 ]]; then
		assert_output "$1"
	fi
}

assert_failure() {
	if [[ "${status}" -eq 0 ]]; then
		failit "expected failure, received success"
	else
		assert_output "$1"
	fi
}

assert_equal() {
	if [[ "$1" != "$2" ]]; then
		{ echo "expected: $1"
			echo "actual: $2"
		} | failit
	fi
}

assert_line() {
	if [[ "$1" -ge 0 ]] 2>/dev/null; then
		assert_equal "$2" "${lines[$1]}"
	else
		local line
		for line in "${lines[@]}"; do
			if [[ "${line}" = "$1" ]]; then return 0; fi
		done
		failit "did not find line: \`$1'"
	fi
}

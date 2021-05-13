#!/usr/bin/env bash

usage() {
	echo "Usage: ${script_name} build-dir in-file" >&2
}

on_exit() {
	local result=${1}

	local sec="${SECONDS}"

	set +x
	echo "${script_name}: Done: ${result}, ${sec} sec." >&2
}

on_err() {
	local f_name=${1}
	local line_no=${2}
	local err_no=${3}

	echo "${script_name}: ERROR: (${err_no}) at ${f_name}:${line_no}." >&2
	exit "${err_no}"
}

#===============================================================================
export PS4='\[\e[0;33m\]+ ${BASH_SOURCE##*/}:${LINENO}:(${FUNCNAME[0]:-main}):\[\e[0m\] '

script_name="${0##*/}"

SECONDS=0
start_time="$(date +%Y.%m.%d-%H.%M.%S)"

trap "on_exit 'Failed'" EXIT
trap 'on_err ${FUNCNAME[0]:-main} ${LINENO} ${?}' ERR

set -eE
set -o pipefail
set -o nounset

# TESTS_TOP="$(realpath "${BASH_SOURCE%/*}")"

build_dir="${1:-}"
flag="${2:-}"

if [[ "${build_dir}" == '-h' || "${build_dir}" == '--help' \
	|| "${flag}" == '-h' || "${flag}" == '--help' ]]; then
        usage
        exit 0
fi

if [[ ! -d "${build_dir}" ]]; then
        echo "${script_name}: ERROR: Bad build-dir: '${build_dir}'" >&2
        exit 1
fi

build_dir="$(realpath "${build_dir}")"
cd "${build_dir}"

in_file="${2}"

if [[ "${in_file}" == '-h' || "${in_file}" == '--help' ]]; then
        usage
        exit 0
fi

if [[ ! -f "${in_file}" ]]; then
        echo "${script_name}: ERROR: Bad in-file: '${in_file}'" >&2
        exit 1
fi

in_file="$(realpath "${in_file}")"
keys_dir="${build_dir}/test-out/sbu-keys"

if [ -o xtrace ]; then
    util_extra='--debug'
else
    util_extra=''
fi

{
	echo ''
	echo '==========================================='
	echo "${script_name} (sbu) - ${start_time}"
	echo '==========================================='
}

echo ''
echo '--- generate keys ---'

"${build_dir}/install/bin/sbu-generate-user-keys.sh" \
	${util_extra} \
	--verbose \
	--out-dir="${keys_dir}" \
	--force

echo ''
echo '--- sign file ---'

"${build_dir}/install/bin/sbu-sign-files.sh" \
	${util_extra} \
	--verbose \
	--out-dir="${build_dir}/test-out" \
	--signing-key="${keys_dir}/keys/db_key.pem" \
	--certificate="${keys_dir}/keys/db_cert.pem" \
	"${in_file}"

echo ''
echo '--- list sigs ---'

"${build_dir}/install/bin/sbu-list-sigs.sh" \
	${util_extra} \
	--verbose \
	"${build_dir}/test-out/${in_file##*/}.signed"

echo ''
echo '--- check sigs ---'

"${build_dir}/install/bin/sbu-check-sigs.sh" \
	${util_extra} \
	--verbose \
	--certificate="${keys_dir}/keys/db_cert.pem" \
	"${build_dir}/test-out/${in_file##*/}.signed"

echo ''
echo '--- Done ---'

trap "on_exit 'Success'" EXIT
exit 0

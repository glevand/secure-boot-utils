#!/usr/bin/env bash

usage() {
	echo "Usage: ${script_name} build-dir" >&2
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

TESTS_TOP="$(realpath "${BASH_SOURCE%/*}")"

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

host_arch="$(uname -m)"

case "${host_arch}" in
arm64|aarch64)
	stub_file="${stub_file:-"${TESTS_TOP}/data/linuxaa64.efi.stub"}"
	;;
x86_64)
	stub_file="${stub_file:-"${TESTS_TOP}/data/linuxx64.efi.stub"}"
	;;
*)
	echo "${script_name}: ERROR Unsupported host arch '${host_arch}'" >&2
	exit 1
	;;
esac

stub_file="$(realpath "${stub_file}")"

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
echo '--- make combo loader ---'

"${build_dir}/install/bin/sbu-make-combo-loader.sh" \
	${util_extra} \
	--verbose \
	--efi-stub="${stub_file}" \
	--linux="${TESTS_TOP}/data/bzImage" \
	--initrd="${TESTS_TOP}/data/initrd.cpio.gz" \
	--cmdline='root=/dev/ram0 console=ttyS0,115200 console=tty0' \
	--output-file="${build_dir}/test-out/combo-loader.efi"

echo ''
echo '--- Done ---'

trap "on_exit 'Success'" EXIT
exit 0

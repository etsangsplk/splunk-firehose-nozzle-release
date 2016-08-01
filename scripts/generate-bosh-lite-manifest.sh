#!/usr/bin/env bash

set -e

my_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
release_dir="$( cd "${my_dir}/.." && pwd )"

argument_error=false

function usage(){
  >&2 echo "
 Usage:
    $0 director-uuid

 Ex:
    $0 \`bosh status --uuid\`
"
  exit 1
}

if [ "$#" -ne 1 ]; then
    usage
fi

director_uuid=$1; shift

tmpdir=$(mktemp -d /tmp/splunk_manifest.XXXXX)
trap '{ rm -rf ${tmpdir}; }' EXIT

echo "
meta:
  director_uuid: $director_uuid
" > ${tmpdir}/director.yml

pushd "${release_dir}" > /dev/null

spiff merge \
    ./manifest-generation/splunk-template.yml \
   "${tmpdir}/director.yml" \
    ./manifest-generation/bosh-lite-iaas-settings.yml \
> cf-splunk.yml

popd > /dev/null

echo "Manifest was generated at ${release_dir}/cf-splunk.yml"

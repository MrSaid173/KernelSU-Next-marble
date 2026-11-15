#!/usr/bin/env bash
set -euo pipefail

KERNEL_DIR="${KERNEL_DIR:-kernel-source}"
ENABLE_NOMOUNT="${ENABLE_NOMOUNT:-false}"

if [[ "${ENABLE_NOMOUNT}" != "true" ]]; then
  echo "NoMount disabled"
  exit 0
fi

source config/marble.env
source release/resolved-refs.env

if [[ -z "${nomount_commit}" ]]; then
  echo "::error::NoMount resolution missing commit"
  exit 1
fi

pushd "${KERNEL_DIR}" >/dev/null

setup_url="https://raw.githubusercontent.com/${NOMOUNT_REPO}/${nomount_commit}/kernel/setup.sh"
echo "Applying NoMount from ${NOMOUNT_REPO}@${nomount_commit} (ref ${NOMOUNT_REF})"
curl -fsSL "${setup_url}" -o /tmp/nomount-setup.sh

# Pass the resolved commit (not the branch name) to setup.sh: it only uses the
# argument for `git checkout <commit-or-tag>` (see kernel/setup.sh in the nomount
# repo). This keeps the build on exactly the commit logged above even if the
# branch moves between the resolve step and this step.
bash /tmp/nomount-setup.sh "${nomount_commit}"

popd >/dev/null
echo "NoMount applied from ${nomount_commit}"

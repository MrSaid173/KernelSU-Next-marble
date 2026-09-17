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

# NOTE: published usage examples invoke this as `bash setup.sh <ref>`, passing a
# branch/tag name rather than a commit sha. We pin the *download* to an exact
# commit for reproducibility, but pass the human ref through as the argument
# in case the script uses it to fetch companion source files internally.
# Verify this against kernel/README.md in the nomount repo if the script
# errors out on the argument.
bash /tmp/nomount-setup.sh "${NOMOUNT_REF}"

popd >/dev/null
echo "NoMount applied from ${nomount_commit}"

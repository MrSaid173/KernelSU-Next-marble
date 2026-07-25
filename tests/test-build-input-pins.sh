#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${repo_root}"

source config/marble.env

[[ "${ANDROID_CLANG_REF_COMMIT:-}" =~ ^[0-9a-f]{40}$ ]] || {
  echo "FAIL: ANDROID_CLANG_REF_COMMIT must be a full commit SHA" >&2
  exit 1
}

[[ "${LLVM_22_1_8_SHA256:-}" =~ ^[0-9a-f]{64}$ ]] || {
  echo "FAIL: LLVM_22_1_8_SHA256 must be a full SHA-256 digest" >&2
  exit 1
}

[[ "${LLVM_22_1_8_URL:-}" == https://github.com/llvm/llvm-project/releases/download/llvmorg-22.1.8/LLVM-22.1.8-Linux-X64.tar.xz ]] || {
  echo "FAIL: LLVM 22.1.8 URL must point at the official Linux X64 release asset" >&2
  exit 1
}

for f in ak3/tools/ak3-core.sh ak3/tools/busybox ak3/tools/magiskboot \
         ak3/META-INF/com/google/android/update-binary \
         ak3/META-INF/com/google/android/updater-script \
         ak3/anykernel.sh; do
  [[ -f "$f" ]] || {
    echo "FAIL: missing bundled AK3 file: $f" >&2
    exit 1
  }
done

echo "Build input pin tests passed"

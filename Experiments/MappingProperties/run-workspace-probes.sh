#!/bin/sh
set -eu
cd "$(dirname "$0")"
products=${1:-/tmp/parser-map-investigation-build/Build/Products/Debug}
out=$(mktemp -d /tmp/parser-mapping-api.XXXXXX)
compile() {
    xcrun swiftc -swift-version 6 -enable-experimental-feature Lifetimes \
        -enable-experimental-feature MoveOnlyTuples -module-cache-path "$out/cache" \
        -I "$products" -whole-module-optimization -emit-sil \
        existing-api.swift self-property-alias.swift "$@" -o "$out/probe.sil"
}
compile
for condition in STORED_CALL DOUBLE_CONSUME CHAIN_FAILURE; do
    if compile -D "$condition" > "$out/$condition.log" 2>&1; then
        echo "UNEXPECTED PASS: $condition"
        exit 1
    fi
    echo "EXPECTED REJECTION: $condition"
    cat "$out/$condition.log"
done
developer=$(xcode-select -p)
compile -F "$developer/Platforms/MacOSX.platform/Developer/Library/Frameworks" \
    -plugin-path "$developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift/host/plugins/testing" \
    '../../../../swift-molecules/swift-optic-parser/Tests/Optic Parser Tests/Optic Parser Tests.swift'
echo "PASS: existing adapters, Self aliases, scoped values, and optic test-source compilation"
echo "Logs: $out"

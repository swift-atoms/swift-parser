#!/bin/sh
set -eu
cd "$(dirname "$0")"
out=$(mktemp -d /tmp/parser-mapping-probes.XXXXXX)
for file in generic-property generic-function-value unbound-nested-type; do
    if xcrun swiftc -swift-version 6 -module-cache-path "$out/cache" -typecheck "$file.swift" > "$out/$file.log" 2>&1; then
        echo "UNEXPECTED PASS: $file"
        exit 1
    fi
    echo "EXPECTED REJECTION: $file"
    cat "$out/$file.log"
done
xcrun swiftc -swift-version 6 -module-cache-path "$out/cache" self-reuse.swift -o "$out/self-reuse"
"$out/self-reuse"
echo "Logs: $out"

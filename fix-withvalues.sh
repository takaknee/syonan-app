#!/bin/bash

# withValues(alpha: X)をwithOpacity(X)に置換するスクリプト

echo "🔧 withValuesメソッドをwithOpacityに修正中..."

# libディレクトリ内のすべてのdartファイルを対象
find lib -name "*.dart" -type f | while read file; do
    # withValues(alpha: X)をwithOpacity(X)に置換
    if grep -q "withValues(alpha:" "$file"; then
        echo "修正中: $file"
        sed -i 's/\.withValues(alpha: \([^)]*\))/\.withOpacity(\1)/g' "$file"
    fi
done

echo "✅ 修正完了"

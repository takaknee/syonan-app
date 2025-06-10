#!/bin/bash

echo "🔧 withOpacityをwithValuesに戻しています..."

# libディレクトリ内のすべてのdartファイルを対象
find lib -name "*.dart" -type f | while read file; do
    # withOpacity(X)をwithValues(alpha: X)に置換
    if grep -q "withOpacity(" "$file"; then
        echo "修正中: $file"
        sed -i 's/\.withOpacity(\([^)]*\))/\.withValues(alpha: \1)/g' "$file"
    fi
done

echo "✅ 修正完了"

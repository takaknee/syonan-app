#!/bin/bash
# 高度な自動修正スクリプト

set -e

echo "🔧 高度な自動修正を開始..."

# 引数チェック
TARGET_FILES="$*"
if [ -z "$TARGET_FILES" ]; then
    TARGET_FILES=$(find lib test -name "*.dart" 2>/dev/null)
fi

if [ -z "$TARGET_FILES" ]; then
    echo "❌ 対象となるDartファイルが見つかりません"
    exit 1
fi

echo "📁 対象ファイル数: $(echo "$TARGET_FILES" | wc -w)"

# 1. フォーマット修正
echo ""
echo "1️⃣ コードフォーマット修正..."
dart format $TARGET_FILES
echo "✅ フォーマット完了"

# 2. インポート修正
echo ""
echo "2️⃣ インポート修正..."
for file in $TARGET_FILES; do
    if [ ! -f "$file" ]; then
        continue
    fi
    
    modified=false
    
    # Flutter/Material インポート
    if grep -q "Widget\|BuildContext\|StatelessWidget\|StatefulWidget" "$file" && ! grep -q "package:flutter/material.dart" "$file"; then
        echo "   Flutter import: $file"
        sed -i '1i import '\''package:flutter/material.dart'\'';' "$file"
        modified=true
    fi
    
    # MathOperationType インポート
    if grep -q "MathOperationType" "$file" && ! grep -q "../models/math_problem.dart\|package:.*math_problem.dart" "$file"; then
        echo "   MathProblem import: $file"
        sed -i '/^import.*\.dart.*;$/a import '\''../models/math_problem.dart'\'';' "$file"
        modified=true
    fi
    
    # Achievement インポート
    if grep -q "Achievement\|UserAchievement" "$file" && ! grep -q "../models/achievement.dart\|package:.*achievement.dart" "$file"; then
        echo "   Achievement import: $file"
        sed -i '/^import.*\.dart.*;$/a import '\''../models/achievement.dart'\'';' "$file"
        modified=true
    fi
    
    # ScoreRecord インポート
    if grep -q "ScoreRecord" "$file" && ! grep -q "../models/score_record.dart\|package:.*score_record.dart" "$file"; then
        echo "   ScoreRecord import: $file"
        sed -i '/^import.*\.dart.*;$/a import '\''../models/score_record.dart'\'';' "$file"
        modified=true
    fi
    
    if [ "$modified" = true ]; then
        # インポートの重複を削除
        awk '!seen[$0]++' "$file" > "$file.tmp" && mv "$file.tmp" "$file"
    fi
done
echo "✅ インポート修正完了"

# 3. const修正（安全なパターンのみ）
echo ""
echo "3️⃣ 安全なconst修正..."
for file in $TARGET_FILES; do
    if [ ! -f "$file" ]; then
        continue
    fi
    
    original_content=$(cat "$file")
    
    # 安全なconst追加パターン
    sed -i 's/\(return\s\+\)Text(/\1const Text(/g' "$file"
    sed -i 's/\(child:\s\+\)Text(/\1const Text(/g' "$file"
    sed -i 's/\(return\s\+\)SizedBox(/\1const SizedBox(/g' "$file"
    sed -i 's/\(child:\s\+\)SizedBox(/\1const SizedBox(/g' "$file"
    sed -i 's/\(return\s\+\)Padding(/\1const Padding(/g' "$file"
    sed -i 's/\(child:\s\+\)Padding(/\1const Padding(/g' "$file"
    
    # 問題のあるconstパターンを修正
    sed -i 's/const Text(\([^)]*\),\s*style: theme\./Text(\1, style: theme./g' "$file"
    sed -i 's/const SizedBox(\([^)]*\),\s*style: theme\./SizedBox(\1, style: theme./g' "$file"
    sed -i 's/const Container(\([^)]*\),\s*color: theme\./Container(\1, color: theme./g' "$file"
    
    # 変数を参照するconst問題を修正
    sed -i 's/const Text(\([^)]*\$[^)]*\)/Text(\1/g' "$file"
    sed -i 's/const SizedBox(\([^)]*\$[^)]*\)/SizedBox(\1/g' "$file"
    
    new_content=$(cat "$file")
    if [ "$original_content" != "$new_content" ]; then
        echo "   修正: $file"
    fi
done
echo "✅ const修正完了"

# 4. 最終フォーマット
echo ""
echo "4️⃣ 最終フォーマット..."
dart format $TARGET_FILES
echo "✅ 最終フォーマット完了"

# 5. 解析チェック
echo ""
echo "5️⃣ 解析チェック..."
if command -v flutter >/dev/null 2>&1; then
    if flutter analyze --no-preamble $TARGET_FILES; then
        echo "✅ 解析エラーなし"
    else
        echo "⚠️ 一部解析エラーが残っています（手動修正が必要な可能性があります）"
    fi
else
    echo "⚠️ Flutter利用不可 - 解析スキップ"
fi

echo ""
echo "🎉 自動修正完了！"

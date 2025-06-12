#!/bin/bash

# 安全な自動修正スクリプト（改善版）
# より精密で安全な修正を行う

set -e

echo "🔧 安全な自動修正を開始..."

# 対象ファイルの確認
DART_FILES=$(find lib test -name "*.dart" 2>/dev/null || true)
DART_COUNT=$(echo "$DART_FILES" | grep -c "^" || echo "0")

if [ "$DART_COUNT" -eq 0 ]; then
    echo "❌ 対象となるDartファイルが見つかりません"
    exit 1
fi

echo "📁 対象ファイル数: $DART_COUNT"

# 1. 基本フォーマット
echo ""
echo "1️⃣ 基本フォーマット..."
if dart format . --line-length=80 --set-exit-if-changed; then
    echo "✅ フォーマット完了（変更なし）"
else
    echo "✅ フォーマット完了（変更あり）"
fi

# 2. インポート修正（安全に）
echo ""
echo "2️⃣ インポート修正..."

# 一時的なバックアップディレクトリ
BACKUP_DIR=$(mktemp -d)
echo "   バックアップ作成: $BACKUP_DIR"

for file in $DART_FILES; do
    if [ ! -f "$file" ]; then
        continue
    fi
    
    # バックアップ作成
    cp "$file" "$BACKUP_DIR/$(basename "$file").bak"
    
    # インポート修正
    modified=false
    
    # MathOperationType参照があるのにインポートがない場合
    if grep -q "MathOperationType" "$file" && ! grep -q "math_problem.dart" "$file"; then
        echo "   MathProblem import 追加: $file"
        # 既存のimportの後に追加
        if grep -q "^import" "$file"; then
            sed -i "/^import.*\.dart';$/a import '../models/math_problem.dart';" "$file"
        else
            sed -i "1i import '../models/math_problem.dart';" "$file"
        fi
        modified=true
    fi
    
    # Achievement参照があるのにインポートがない場合
    if grep -q "Achievement\|UserAchievement" "$file" && ! grep -q "achievement.dart" "$file"; then
        echo "   Achievement import 追加: $file"
        if grep -q "^import" "$file"; then
            sed -i "/^import.*\.dart';$/a import '../models/achievement.dart';" "$file"
        else
            sed -i "1i import '../models/achievement.dart';" "$file"
        fi
        modified=true
    fi
    
    # 構文チェック
    if [ "$modified" = true ]; then
        if ! dart analyze "$file" > /dev/null 2>&1; then
            echo "   ⚠️ 構文エラー検出 - 元に戻します: $file"
            cp "$BACKUP_DIR/$(basename "$file").bak" "$file"
        else
            echo "   ✅ 修正成功: $file"
        fi
    fi
done

echo "✅ インポート修正完了"

# 3. 安全なconst修正
echo ""
echo "3️⃣ 安全なconst修正..."

for file in $DART_FILES; do
    if [ ! -f "$file" ]; then
        continue
    fi
    
    # バックアップから復元可能な状態を確保
    cp "$file" "$BACKUP_DIR/$(basename "$file").const_bak"
    
    modified=false
    
    # theme.*を含むconst Textの修正
    if grep -q "const Text.*theme\." "$file"; then
        echo "   const Text with theme修正: $file"
        sed -i 's/const Text(/Text(/g' "$file"
        modified=true
    fi
    
    # copyWithを含むconstの修正
    if grep -q "const.*copyWith" "$file"; then
        echo "   const copyWith修正: $file"
        sed -i '/copyWith/s/const //g' "$file"
        modified=true
    fi
    
    # 構文チェック
    if [ "$modified" = true ]; then
        if ! dart analyze "$file" > /dev/null 2>&1; then
            echo "   ⚠️ const修正で構文エラー - 元に戻します: $file"
            cp "$BACKUP_DIR/$(basename "$file").const_bak" "$file"
        else
            echo "   ✅ const修正成功: $file"
        fi
    fi
done

echo "✅ const修正完了"

# 4. 最終フォーマット
echo ""
echo "4️⃣ 最終フォーマット..."
dart format . --line-length=80 > /dev/null 2>&1 || echo "⚠️ フォーマットでエラーがありました"
echo "✅ 最終フォーマット完了"

# 5. 最終構文チェック
echo ""
echo "5️⃣ 最終構文チェック..."
ERROR_COUNT=0
for file in $DART_FILES; do
    if ! dart analyze "$file" > /dev/null 2>&1; then
        ERROR_COUNT=$((ERROR_COUNT + 1))
    fi
done

if [ "$ERROR_COUNT" -eq 0 ]; then
    echo "✅ 全ファイル構文エラーなし"
else
    echo "⚠️ $ERROR_COUNT 個のファイルに構文エラーが残っています"
fi

# バックアップ削除
rm -rf "$BACKUP_DIR"

echo ""
echo "🎉 安全な自動修正完了!"

#!/bin/bash

# 精密な自動修正スクリプト (Precise Auto-Fix Script)
# flutter analyze の結果を解析して、ピンポイントで修正を行う

set -e

echo "🎯 精密自動修正システム開始..."

# Step 1: フォーマット修正
echo ""
echo "1️⃣ コードフォーマット修正..."
if ! dart format --set-exit-if-changed . --dry-run >/dev/null 2>&1; then
    echo "⚠️ フォーマット問題を検出、修正中..."
    dart format .
    echo "✅ フォーマット修正完了"
else
    echo "✅ フォーマットは既に正しい"
fi

# Step 2: 解析とピンポイント修正
echo ""
echo "2️⃣ Flutter解析とピンポイント修正..."

# 解析実行
if flutter analyze --no-preamble > /tmp/analysis_output.txt 2>&1; then
    echo "✅ 解析エラーなし"
    exit 0
fi

echo "⚠️ 解析エラーを検出:"
cat /tmp/analysis_output.txt
echo ""

fixes_applied=false

# prefer_const_constructors の精密修正
if grep -q "prefer_const_constructors" /tmp/analysis_output.txt; then
    echo "🔧 const constructor エラーの精密修正中..."
    
    # 各エラー行を個別に処理
    grep "prefer_const_constructors" /tmp/analysis_output.txt | while IFS= read -r line; do
        # ファイル:行番号:列番号 の抽出
        if [[ $line =~ ([^[:space:]]+\.dart):([0-9]+):([0-9]+) ]]; then
            file="${BASH_REMATCH[1]}"
            line_num="${BASH_REMATCH[2]}"
            
            if [ -f "$file" ]; then
                echo "  → $file の $line_num 行目を修正中..."
                
                # 該当行を取得
                current_line=$(sed -n "${line_num}p" "$file")
                
                # インデントと内容を分離
                if [[ $current_line =~ ^([[:space:]]*)(.*)$ ]]; then
                    indent="${BASH_REMATCH[1]}"
                    content="${BASH_REMATCH[2]}"
                    
                    # const を追加するパターン
                    if [[ $content =~ ^(Icon|Text|SizedBox|Padding|Container|MaterialApp|Scaffold|Card|Column|Row|Center|Expanded|Flexible)\( ]] ||
                       [[ $content =~ ^([A-Z][a-zA-Z0-9_]*)\( ]]; then
                        
                        # 既に const がある場合はスキップ
                        if [[ ! $content =~ ^const[[:space:]] ]]; then
                            new_line="${indent}const ${content}"
                            sed -i "${line_num}s/.*/${new_line//\//\\/}/" "$file"
                            echo "    ✓ const を追加: ${content:0:50}..."
                            fixes_applied=true
                        fi
                    fi
                fi
            fi
        fi
    done
fi

# API互換性の修正
if grep -q "argument_type_not_assignable" /tmp/analysis_output.txt; then
    echo "🔧 Flutter API互換性の修正中..."
    
    # CardTheme -> CardThemeData
    if grep -q "CardTheme.*CardThemeData" /tmp/analysis_output.txt; then
        echo "  → CardTheme を CardThemeData に修正中..."
        find lib -name "*.dart" -exec sed -i 's/cardTheme: const CardTheme(/cardTheme: const CardThemeData(/g' {} \; || true
        find lib -name "*.dart" -exec sed -i 's/cardTheme: CardTheme(/cardTheme: CardThemeData(/g' {} \; || true
        fixes_applied=true
    fi
fi

# 修正結果の確認
if [ "$fixes_applied" = true ]; then
    echo ""
    echo "3️⃣ 修正後の再確認..."
    if flutter analyze --no-preamble; then
        echo "✅ すべてのエラーが修正されました！"
    else
        echo "⚠️ 一部のエラーが残っています（手動修正が必要な場合があります）"
    fi
else
    echo "ℹ️ 自動修正可能なエラーはありませんでした"
fi

echo ""
echo "🎯 精密自動修正完了"

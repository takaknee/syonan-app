#!/bin/bash

# Flutter自動セットアップスクリプト
# このスクリプトはFlutter SDKを自動でダウンロード・展開します

set -e

# 設定
FLUTTER_VERSION="3.27.1"  # より新しいバージョンを指定
FLUTTER_DIR="/opt/flutter"
FLUTTER_URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"
FLUTTER_ARCHIVE="flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"

echo "🚀 Flutter自動セットアップを開始します..."
echo "バージョン: ${FLUTTER_VERSION}"
echo "インストール先: ${FLUTTER_DIR}"

# 既存のFlutterディレクトリをチェック
if [ -d "$FLUTTER_DIR" ]; then
    echo "⚠️  既存のFlutterディレクトリが見つかりました: $FLUTTER_DIR"
    read -p "削除して再インストールしますか？ (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "🗑️  既存のFlutterディレクトリを削除します..."
        sudo rm -rf "$FLUTTER_DIR"
    else
        echo "✅ 既存のFlutterディレクトリを使用します"
        
        # Flutter バージョンを確認
        if [ -x "$FLUTTER_DIR/bin/flutter" ]; then
            echo "📋 現在のFlutterバージョン:"
            "$FLUTTER_DIR/bin/flutter" --version
            exit 0
        else
            echo "❌ Flutterの実行ファイルが見つかりません。再インストールします..."
            rm -rf "$FLUTTER_DIR"
        fi
    fi
fi

# 一時ディレクトリを作成
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

echo "⬇️  Flutter SDKをダウンロードしています..."
echo "URL: $FLUTTER_URL"

# ダウンロードを試行
download_success=false

# 方法1: wgetを使用
if command -v wget >/dev/null 2>&1; then
    echo "📥 wgetを使用してダウンロードします..."
    if wget -q --show-progress --tries=3 --timeout=60 -O "$FLUTTER_ARCHIVE" "$FLUTTER_URL"; then
        download_success=true
        echo "✅ wgetでのダウンロードが成功しました"
    else
        echo "❌ wgetでのダウンロードが失敗しました"
    fi
fi

# 方法2: curlを使用（wgetが失敗した場合）
if [ "$download_success" = false ] && command -v curl >/dev/null 2>&1; then
    echo "📥 curlを使用してダウンロードします..."
    if curl -L -o "$FLUTTER_ARCHIVE" "$FLUTTER_URL" --connect-timeout 60 --max-time 1200; then
        download_success=true
        echo "✅ curlでのダウンロードが成功しました"
    else
        echo "❌ curlでのダウンロードが失敗しました"
    fi
fi

# ダウンロードが失敗した場合
if [ "$download_success" = false ]; then
    echo "❌ Flutter SDKのダウンロードに失敗しました"
    echo "以下を確認してください："
    echo "  - インターネット接続"
    echo "  - ファイアウォール設定"
    echo "  - storage.googleapis.com へのアクセス"
    rm -rf "$TEMP_DIR"
    exit 1
fi

# ファイルサイズをチェック
file_size=$(stat -f%z "$FLUTTER_ARCHIVE" 2>/dev/null || stat -c%s "$FLUTTER_ARCHIVE" 2>/dev/null || echo "0")
if [ "$file_size" -lt 100000000 ]; then  # 100MB未満の場合は失敗と判断
    echo "❌ ダウンロードファイルのサイズが小さすぎます: ${file_size} bytes"
    echo "ダウンロードが不完全または失敗している可能性があります"
    rm -rf "$TEMP_DIR"
    exit 1
fi

echo "✅ ダウンロード完了 (サイズ: ${file_size} bytes)"

# 展開
echo "📦 Flutter SDKを展開しています..."
if tar -tf "$FLUTTER_ARCHIVE" >/dev/null 2>&1; then
    if tar -xf "$FLUTTER_ARCHIVE"; then
        echo "✅ 展開が完了しました"
    else
        echo "❌ 展開に失敗しました"
        rm -rf "$TEMP_DIR"
        exit 1
    fi
else
    echo "❌ アーカイブファイルが破損している可能性があります"
    rm -rf "$TEMP_DIR"
    exit 1
fi

# 元のディレクトリに移動
cd - >/dev/null

# Flutterディレクトリを移動
if [ -d "$TEMP_DIR/flutter" ]; then
    echo "📁 Flutterディレクトリを移動しています..."
    sudo mkdir -p "$(dirname "$FLUTTER_DIR")"
    sudo mv "$TEMP_DIR/flutter" "$FLUTTER_DIR"
    sudo chmod -R 755 "$FLUTTER_DIR"
    echo "✅ Flutter SDKが $FLUTTER_DIR にインストールされました"
else
    echo "❌ 展開されたFlutterディレクトリが見つかりません"
    rm -rf "$TEMP_DIR"
    exit 1
fi

# 一時ディレクトリを削除
rm -rf "$TEMP_DIR"

# 権限設定
chmod +x "$FLUTTER_DIR/bin/flutter"
chmod +x "$FLUTTER_DIR/bin/dart"

# PATH設定のガイダンス
echo ""
echo "🎉 Flutter セットアップが完了しました！"
echo ""
echo "📋 以下のコマンドでFlutterを使用できます："
echo "   $FLUTTER_DIR/bin/flutter --version"
echo ""
echo "💡 PATHに追加するには、以下のいずれかを実行してください："
echo ""
echo "   一時的に追加（現在のセッションのみ）:"
echo "   export PATH=\"$FLUTTER_DIR/bin:\$PATH\""
echo ""
echo "   永続的に追加（~/.bashrc または ~/.zshrc に追加）:"
echo "   echo 'export PATH=\"$FLUTTER_DIR/bin:\$PATH\"' >> ~/.bashrc"
echo "   source ~/.bashrc"
echo ""

# Flutter doctor を実行
echo "🔍 Flutter Doctor を実行しています..."
"$FLUTTER_DIR/bin/flutter" doctor -v

echo ""
echo "✅ セットアップ完了！"

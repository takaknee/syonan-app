#!/bin/bash

# Flutterビルド時にコンパイル時刻を環境変数として設定するスクリプト

# 現在の時刻をISO 8601形式で取得
COMPILED_TIME=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

echo "🕐 コンパイル時刻: $COMPILED_TIME"

# Flutter runやbuildコマンドに--dart-defineを追加してコンパイル時刻を設定
if [ "$1" = "run" ]; then
    echo "🚀 Flutter Webアプリを起動します..."
    flutter run -d web-server \
        --web-hostname 0.0.0.0 \
        --web-port 9100 \
        --dart-define=COMPILED_TIME="$COMPILED_TIME"
elif [ "$1" = "build-web" ]; then
    echo "🏗️ Flutter Webアプリをビルドします..."
    flutter build web --release \
        --dart-define=COMPILED_TIME="$COMPILED_TIME"
elif [ "$1" = "build-apk" ]; then
    echo "📱 Android APKをビルドします..."
    flutter build apk --debug \
        --dart-define=COMPILED_TIME="$COMPILED_TIME"
else
    echo "使用方法: $0 [run|build-web|build-apk]"
    echo "例: $0 run"
    exit 1
fi

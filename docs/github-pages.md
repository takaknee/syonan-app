# GitHub Pages デプロイメントガイド

## 概要

算数れんしゅうアプリはGitHub Pagesを使用してWebデモを提供しています。このドキュメントでは、GitHub Pagesの設定、デプロイメント、利用方法について説明します。

## 🌐 アクセス情報

### メインデモサイト
- **URL**: [https://takaknee.github.io/syonan-app/](https://takaknee.github.io/syonan-app/)
- **対象**: 一般ユーザー、テスター、フィードバック提供者
- **更新頻度**: mainブランチへのコミット時に自動更新

## 🛠️ Flutter SDK自動セットアップ

GitHub PagesのCI/CDパイプラインでは、Flutter SDKが自動的にセットアップされます。

### デプロイメント時のFlutter設定

デプロイワークフローは複数の方法でFlutterをセットアップします：

1. **公式Flutter Action**: `subosito/flutter-action@v2`を使用
2. **フォールバック方法**: 手動ダウンロード・展開
3. **キャッシュ機能**: ビルド時間短縮のためSDKをキャッシュ

### CI/CD環境でのFlutterセットアップ詳細

```yaml
# GitHub Actionsでの自動Flutter設定例
- name: Setup Flutter (Primary Method)
  uses: subosito/flutter-action@v2
  with:
    flutter-version: '3.24.3'
    channel: 'stable'
    cache: true

# フォールバック: 手動セットアップ
- name: Manual Flutter Setup
  if: failure()
  run: |
    FLUTTER_VERSION="3.24.3"
    wget -O flutter.tar.xz "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"
    tar -xf flutter.tar.xz
    echo "$PWD/flutter/bin" >> $GITHUB_PATH
```

### ファイアウォール問題への対処

企業環境などでファイアウォールによりFlutterのダウンロードが制限される場合：

1. **事前準備**: ローカルでFlutter SDKを準備
2. **手動アップロード**: アーティファクトとしてSDKをアップロード
3. **プライベートアクション**: 組織内でFlutterセットアップアクションを作成

詳細は [GitHub Actions Firewall Guide](github-actions-firewall.md) を参照してください。

## 🚀 デプロイメント

### 自動デプロイメント

GitHub Actionsワークフロー（`.github/workflows/deploy-github-pages.yml`）により、以下の条件で自動的にデプロイされます：

- `main`ブランチへのプッシュ
- 手動実行（GitHub Actions画面から）

### デプロイメントプロセス

1. **ビルド段階**
   - Flutter SDKのセットアップ
   - 依存関係のインストール (`flutter pub get`)
   - コード解析 (`flutter analyze`)
   - Webアプリのビルド (`flutter build web --release --base-href /syonan-app/`)

2. **デプロイ段階**
   - ビルド成果物をGitHub Pagesにデプロイ
   - 通常1-2分でライブサイトに反映

## 📱 対応ブラウザ・デバイス

### 推奨ブラウザ
- **Chrome**: 90+ (推奨)
- **Firefox**: 88+
- **Safari**: 14+
- **Edge**: 90+

### 対応デバイス
- **デスクトップ**: Windows、Mac、Linux
- **モバイル**: iOS Safari、Android Chrome
- **タブレット**: iPad、Android タブレット

## 🔧 ローカル開発でのWeb確認

開発中にローカルでWebアプリをテストする場合：

```bash
# 依存関係のインストール
flutter pub get

# Webアプリの起動（開発モード）
flutter run -d web-server --web-port 3000

# または、リリースビルドの確認
flutter build web --release
cd build/web
python -m http.server 8000
```

## 📊 パフォーマンス最適化

### ビルド最適化設定

- **リリースビルド**: `--release`フラグでサイズ最適化
- **ツリーシェイキング**: 未使用コードの自動削除
- **Web固有最適化**: Canvaskitレンダラーの使用

### ロード時間改善

- **プリローダー**: index.htmlにカスタムローディング画面
- **Progressive Web App**: manifest.jsonによるアプリライクな体験
- **キャッシュ戦略**: ブラウザキャッシュの活用

## 🔒 セキュリティ考慮事項

### データ保護
- **ローカルストレージのみ**: 外部サーバーへのデータ送信なし
- **プライバシー保護**: 個人情報の収集・送信なし
- **子供向け安全設計**: 外部リンクなし、安全なUI設計

### HTTPS配信
- GitHub Pagesは自動的にHTTPS通信を提供
- セキュアな環境でのアプリ実行を保証

## 🐛 トラブルシューティング

### よくある問題

#### 1. アプリが読み込まれない
- ブラウザのキャッシュをクリア
- 対応ブラウザを使用しているか確認
- JavaScript が有効になっているか確認

#### 2. データが保存されない
- ブラウザのローカルストレージが有効か確認
- プライベートブラウジングモードでは一部機能が制限される場合があります

#### 3. デプロイメントエラー
- GitHub Actionsのログを確認
- Flutter バージョンの互換性を確認
- ビルドエラーがないかコードを確認

### サポート

問題が解決しない場合は、以下の情報を含めてIssueを作成してください：

- 使用ブラウザとバージョン
- 使用デバイス（OS含む）
- 発生した問題の詳細
- 再現手順
- エラーメッセージ（あれば）

## 📈 今後の予定

### 予定されている改善

- **PWA機能拡張**: オフライン対応の強化
- **パフォーマンス向上**: 初回ロード時間の短縮
- **アニメーション追加**: より楽しいユーザー体験
- **統計ダッシュボード**: 学習進捗の可視化

### フィードバック歓迎

GitHub Pagesデモを使用してのご意見・ご感想をお待ちしています。Issueやディスカッションでお気軽にお知らせください。
## 公共交通オープンデータチャレンジ2024 JR東日本 OpenTripPlanner

JR東日本・JR東日本アイステーションズの運行情報とOpenStreetMapの地図情報を組み合わせ、リアルタイムな鉄道運行状況を反映した経路検索などができる OpenTripPlanner (OTP) を動かすコードです。

## 特徴

- Docker Composeを用いたシンプルな環境構築
- JR東日本のリアルタイム運行情報APIを活用
- OpenStreetMapの地図データと統合
- 経路検索APIを提供

## インストール

### 必要環境

- Docker
- Docker Compose

### 手順

1. **APIキーの取得**:  [ODPT](https://developer.odpt.org/registration/) からAPIキーを取得してください。
2. **APIキーの設定**:  `compose.yml` ファイルの `API_KEY` 環境変数を、取得したAPIキーに置き換えます。

   ```yaml
   version: '3'
   services:
     downloader:
       environment:
         - API_KEY=[取得したAPIキー] 
   ```

3. **Dockerコンテナの起動**:  プロジェクトのルートディレクトリで以下のコマンドを実行します。

   ```bash
   docker compose up downloader
   docker compose up otp
   ```

   これにより、以下の処理が実行されます。
   - `downloader` コンテナが起動し、必要なデータ (GTFS, OSM) をダウンロードします。
   - `router-config.template.json` から `router-config.json` が生成され、APIキーが埋め込まれます。
   - `otp` コンテナが起動し、OTPサーバーが起動し、グラフの構築とサーバの起動を行います。

4. **アクセス**: ブラウザで  `http://localhost:8080`  にアクセスします。OTPのインターフェースが表示され、経路検索などが行えます。

## ファイルツリーとプロジェクト構成

```
├── otp
│   └── router-config.template.json
├── compose.yml
├── initial.sh
└── LICENSE.md
```

- **`otp` ディレクトリ**: OTP関連のファイルを格納します。
    - `router-config.template.json`: OTPの設定ファイルのテンプレート (APIキーは含まれていません)
- **`compose.yml`**: Docker Composeの設定ファイルです。2つのサービス (`downloader`, `otp`) を定義しています。
- **`initial.sh`**: 初期化スクリプトです。必要なデータのダウンロード、`router-config.json` の生成などを行います。
- **`LICENSE.md`**:  MITライセンスの内容が記載されています。

### 各コンテナの役割

- **`downloader`**:  
    - 必要なデータ (GTFS, OSM) をダウンロードします。
    - `router-config.template.json` から `router-config.json` を生成し、`compose.yml` で設定した `API_KEY` 環境変数の値を埋め込みます。
- **`otp`**: 構築されたグラフを読み込み、経路検索APIを提供するOTPサーバーを起動します。 `downloader` コンテナでデータのダウンロードと設定ファイルの生成が完了するまで待機してから起動します。

### 2回目以降でグラフ構築を省略する場合

2回目以降の実行では、既にグラフが構築されている場合は `otp-builder` コンテナの実行を省略することができます。
`docker-compose.yml` ファイルを以下のように変更してください。

```yaml
version: '3'

services:
  otp:
    image: opentripplanner/opentripplanner:latest
    container_name: otp-container
    environment:
      - JAVA_OPTS=-Xmx8G
    volumes:
      - ./otp:/var/opentripplanner
    command: >
      --serve
      --load
    ports:
      - "8080:8080"
```

## 使用方法

### 経路検索

1. OTPのインターフェース (`http://localhost:8080`) にアクセスします。
2. 出発地と目的地を入力します。
3. 検索ボタンをクリックします。

## APIエンドポイント

OTPは、経路検索などの機能を提供するAPIエンドポイントを備えています。
詳細は、[OTPの公式ドキュメント](https://docs.opentripplanner.org/en/latest/) を参照してください。

## 設定ファイル

- `router-config.json`: OTPの設定ファイルです。 
    - `gtfsRealtimeAlertsUrl`, `gtfsRealtimeTripUpdatesUrl`, `gtfsRealtimeVehiclePositionsUrl` など、リアルタイム運行情報APIのエンドポイントが設定されています。
    - `transitServiceStart`, `transitServiceEnd` で、OTPが考慮する運行時間帯を設定できます。
    - `updaters` では、リアルタイム情報の更新頻度などを設定できます。
    - このファイルは、`downloader`コンテナによって`router-config.template.json`から生成されます。

## データ元

### 鉄道運行情報

- テキストベースの運行情報: `https://api-challenge2024.odpt.org/api/v4/gtfs/realtime/jreis_odpt_train_alert?acl:consumerKey=[APIキー]`
- 時刻表データ: `https://api-challenge2024.odpt.org/api/v4/files/JR-East/data/JR-East-Train-GTFS.zip?acl:consumerKey=[APIキー]`
- 各駅・各列車の時刻表更新情報: `https://api-challenge2024.odpt.org/api/v4/gtfs/realtime/jreast_odpt_train_trip_update?acl:consumerKey=[APIキー]`
- 列車位置情報: `https://api-challenge2024.odpt.org/api/v4/gtfs/realtime/jreast_odpt_train_vehicle?acl:consumerKey=[APIキー]`

### 地図情報

- 関東圏のOpenStreetMap: `https://download.geofabrik.de/asia/japan/kanto-latest.osm.pbf`

## ライセンス

このプロジェクトは、MITライセンスの下で配布されています。詳細については、LICENSEファイルを参照してください。
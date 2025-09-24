# ルーティング サンドボックス

Linux のルーティング機能を色々試すためのコンテナ環境を作成する雛形。

## 始め方

```sh
git clone https://github.com/ysjj/routing-sandbox.git
podman compose build
podman compose up -d
```

### サービス

- gw-host: ゲートウェイ コンテナ。ルーティング機能を nftables などで試す環境。
- int-host: 内部ホスト。gw-host をデフォルト ゲートウェイと構成した環境。
- ext-host: 外部ホスト。必要に応じて httpd などをサービスさせる環境。

### IP アドレス構成

| サービス | IPアドレス |
|----------|------------|
| ext-host | 172.16.1.10 |
| gw-host  | 172.16.1.250<br>192.168.1.250 |
| int-host | 192.168.1.10  |

gw-host から先の外部通信はコンテナ実行時に提供されるデフォルトゲートウェイ(172.16.1.1)に依る。

## トラブル

### gw-host が unhealthy で開始しない

gw-host が unhealthy で開始しない場合、
healthy で開始するまで `podman compose up -d --force-recreate` を繰り返す。

#### 背景

- WSL カーネル バージョン: 6.6.87.2-1[^require-fib-in-kernel]
- podman バージョン: 5.6.1
- docker-compose バージョン : 2.39.3

この組み合わせで、`podman compose up -d` 直後はコンテナ内から外へ通信できないことがある。
`podman compose restart` で解消するので作成されるネットワークが問題はないと考えている。

原因不明だが、対処療法として healthcheck を組み込んで発症を unhealthy として検出している。

# 脚注

[^require-fib-in-kernel]: [microsoft/WSL#13479](https://github.com/microsoft/wsl/issues/13479) Please enable Netfilter FIB lookup support in the default kernel

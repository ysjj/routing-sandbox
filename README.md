# ルーティング サンドボックス

Linux のルーティング機能を色々試すためのコンテナ環境。

feature/nginx-whois-gateway ブランチでは nginx による whois 中継を試す。

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

### gw-host が Error で開始しない

Windows において `git config core.autocrlf` が `true` の状態で git clone した場合、
改行コードが変換されて開始地点(/root/entry-point.sh)の実行に失敗する。

`podman compose logs -n 100 gw-host` で `'/root/entry-point.sh': No such file or directory` が
出ていれば上記の状況に該当する。

この場合 `git config --global core.autocrlf false` の実行後に git clone をやり直す。

## whois 中継

nginx の stream モジュールを用い、
ext-host:8043 から whois.jprs.jp:43 へ転送、
ext-host:8143 から whois.nic.ad.jp:43 へ転送する。

実行例1:

```
root@inthost:~# whois -h exthost -p 8043 yahoo.co.jp
[ JPRS database provides information on network administration. Its use is    ]
[ restricted to network administration purposes. For further information,     ]
[ use 'whois -h whois.jprs.jp help'. To suppress Japanese output, add'/e'     ]
[ at the end of command, e.g. 'whois -h whois.jprs.jp xxx/e'.                 ]
Domain Information: [ドメイン情報]
a. [ドメイン名]                 YAHOO.CO.JP
e. [そしきめい]                 らいんやふーかぶしきがいしゃ
f. [組織名]                     LINEヤフー株式会社
g. [Organization]               LY Corporation
k. [組織種別]                   株式会社
l. [Organization Type]          Corporation
m. [登録担当者]                 HT57990JP
n. [技術連絡担当者]             YY47022JP
p. [ネームサーバ]               ns01.yahoo.co.jp
p. [ネームサーバ]               ns02.yahoo.co.jp
p. [ネームサーバ]               ns11.yahoo.co.jp
p. [ネームサーバ]               ns12.yahoo.co.jp
s. [署名鍵]
[状態]                          Connected (2025/09/30)
[ロック状態]                    AgentChangeLocked
[登録年月日]                    2019/09/27
[接続年月日]                    2019/09/27
[最終更新]                      2024/10/01 01:00:44 (JST)
```

実行例2:

```
root@inthost:~# whois -h exthost -p 8143 "AS 2515" | iconv -f iso-2022-jp -t utf-8
[ JPNIC database provides information regarding IP address and ASN. Its use   ]
[ is restricted to network administration purposes. For further information,  ]
[ use 'whois -h whois.nic.ad.jp help'. To only display English output,        ]
[ add '/e' at the end of command, e.g. 'whois -h whois.nic.ad.jp xxx/e'.      ]

Autonomous System Information: [AS情報]
a. [AS番号]                     2515
b. [AS名]                       JPNIC
f. [組織名]                     一般社団法人 日本ネットワークインフォメーションセンター
g. [Organization]               Japan Network Information Center
m. [管理者連絡窓口]             SS54384JP
n. [技術連絡担当者]             YK11438JP
n. [技術連絡担当者]             EK6175JP
n. [技術連絡担当者]             TK74577JP
n. [技術連絡担当者]             NH27225JP
n. [技術連絡担当者]             KG13714JP
q. [Abuse]                      hostmaster@nic.ad.jp
o. [IMPORT]                     from AS2500 10 accept ANY
o. [IMPORT]                     from AS2497 10 accept ANY
p. [EXPORT]                     to AS2500 announce AS2515
p. [EXPORT]                     to AS2497 announce AS2515
[割当年月日]                    1994/11/21
[最終更新]                      2023/06/19 16:29:02(JST)
```

# 脚注

[^require-fib-in-kernel]: [microsoft/WSL#13479](https://github.com/microsoft/wsl/issues/13479) Please enable Netfilter FIB lookup support in the default kernel

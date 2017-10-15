# BCDice-API

BCDiceを提供するAPIサーバー (unicorn起動版)

[![Build Status](https://travis-ci.org/NKMR6194/bcdice-api.svg?branch=master)](https://travis-ci.org/NKMR6194/bcdice-api)

## Demo

https://bcdice.herokuapp.com (本家Demoでありunicornは関係ない)

## What is BCDice

BCDiceは日本のTRPGセッションツールにおいて、デファクトスタンダードとも言えるダイスロールエンジンです。
初めは、Faceless氏によってPerlを用いて作成されました。後に、たいたい竹流氏によってRubyへの移植され、現在までメンテナンスされています。

BCDiceは[どどんとふ](http://www.dodontof.com)をはじめとして、[TRPGオンラインセッションSNS](https://trpgsession.click)や[Onset!](https://github.com/kiridaruma/Onset)においてダイスロールエンジンとして使われています。

## Setup

```
$ git clone -b kmkb-unicorn https://github.com/kumakaba/bcdice-api.git
$ cd bcdice-api
$ git checkout `git describe --abbrev=0` #直近のリリースに移動
$ git submodule init
$ git submodule update
$ bundle install
$ cp unicorn.rb.sample unicorn.rb
$ bundle exec unicorn -l 127.0.0.1:9292 -c unicorn.rb -D

$ kill -QUIT `cat /tmp/bcdice-api.unicorn.pid`
```

本家ではPumaが入ってますが、こっちはunicornで動かしています。nginxを前段に置く運用が前提。

## API

Method                           | Description
-------------------------------- | ----- 
[/v1/version](/docs/api.md#version)   | BCDiceとAPIサーバーのバージョン
[/v1/systems](/docs/api.md#systems)   | ダイスボットのシステム名一覧
[/v1/systeminfo](/docs/api.md#systeminfo)   | ダイスボットのシステム情報取得
[/v1/diceroll](/docs/api.md#diceroll) | ダイスボットのコマンドを実行
[/v1/onset](/docs/api.md#onset)       | Onset!互換
[/v1/serial](/docs/api.md#serial)       | (追加) サーバー生成の連番を取得
[/v1/hashids](/docs/api.md#hashids)       | (追加) serialを元にして生成した文字列を取得

## Cases

- [discord-bcdicebot](https://shunshun94.github.io/discord-bcdicebot/)
- [Line botでダイスを振る - Qiita](http://qiita.com/violet2525/items/85607f2cc466a76cca07)
- [bcdice-api | 大ちゃんのいろいろ雑記](https://www.taruki.com/wp/?p=6507) : どどんとふ公式鯖による公開サーバー

## Donate

- [Amazonほしい物リスト](http://amzn.asia/gK5kW6A)
- [Amazonギフト券](https://www.amazon.co.jp/Amazonギフト券-Eメールタイプ/dp/BT00DHI8G) 宛先: donate@sakasin.net

## The Auther

Forked by くまかば (@kumakaba)

Original Auther 酒田　シンジ (@NKMR6194)


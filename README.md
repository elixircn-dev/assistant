# Assistant

Assistant 是以 `elixircn-dev` 的名义开发的以信息推送为主的项目，它是为 Elixir 中文开发者们设计的机器人助理。目前仅服务于 [@elixircn_dev](https://t.me/elixircn_dev) 群组。

## 介绍

Assistant 可以订阅多个来源的信息，包括 Elixir 官方论坛的帖子、GitHub 仓库和 Hex 包的动态。未来它会支持更多来源，但由于目前主要用于 Elixir 的生态，在它没有足够健壮前不考虑支持其它生态信息。

### Elixir 论坛主题订阅

Assistant 可以自动检测论坛的置顶主题（即帖子）动态，在发现有新的置顶主题时将它推送到 Telegram 群组。此外，如果置顶的主题中包含 `elixir-release` 标签，Assistant 会把关联的推送消息在群组中置顶。

### GitHub 仓库订阅

Assistant 可以订阅任何公开仓库，以及 [@Elixir-Assistant](https://github.com/Elixir-Assistant) 帐号具有访问权限的私有仓库。当订阅某个 GitHub 仓库时，Assistant 会自动运营 [@Elixir-Assistant](https://github.com/Elixir-Assistant) 帐号 watch 这个仓库。此后这个仓库有新的发布时，将推送相关消息到群组中。

### Hex 包订阅

Assistant 可以订阅 Hex.pm 上的任何公开包，并在它们有新的版本发布时推送相关消息到群组中。

## 未来计划

Assistant 目前还处于早期阶段，它的功能还很有限。未来我会添加对多群组独立订阅和使用的支持，并扩展到更多的技术生态中。值得一提的是我很看好 Assistant 和 ChatGPT 的集成，使用 ChatGPT 的总结和翻译能力为信息添砖加瓦。

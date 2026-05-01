# macOS-IME-Complete-Chars

![Version](https://img.shields.io/badge/version-v2.2.0-blue)
![Platform](https://img.shields.io/badge/platform-macOS%20Ventura%2B-lightgrey?logo=apple)
![Cannot Type](https://img.shields.io/badge/推荐版-79个-red)
![Radicals](https://img.shields.io/badge/偏旁部首-50个-orange)
![Rare Chars](https://img.shields.io/badge/生僻字-58个-green)
![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)

补全macOS原生简体拼音输入法中，《现代汉语词典》《通用规范汉字表》有、系统无的生僻字和偏旁部首，提供可直接导入的plist文件，无需安装第三方输入法，轻量便捷。

## 项目介绍
macOS原生简体拼音输入法存在部分常用偏旁、生僻字输入不便的问题：有些字符虽然能打出，但候选排名极靠后，需要翻页才能找到；另有少数字符（如攴、爿、罒、龸）原生输入法完全无法打出。本项目针对上述问题，收录常用偏旁部首及生僻字，生成可直接导入Mac自定义短语的plist文件，导入后对应字符将优先出现在候选列表中，无需安装第三方输入法。

### 项目目录

```
macOS-IME-Complete-Chars/
├── plist/                    # 可直接导入的plist文件
│   ├── cannot-type.plist     # 实测打不出的字符（39条，推荐）
│   ├── radicals.plist        # 偏旁部首完整版（52条）
│   ├── rare-chars.plist      # 生僻字完整版（59条）
│   ├── no-conflict.plist     # 无冲突合并版（70条）
│   ├── emoticons.plist       # 颜文字/符号（自动生成，未测试）
│   └── 符号和颜文字.plist     # 作者个人习惯文件，仅供参考
├── data/                     # 数据源文件
│   ├── chinese-xinhua.json   # 权威字表数据源（含实测结果）
│   ├── missing-radicals.csv  # 筛选后的偏旁列表
│   └── missing-chars.csv     # 筛选后的生僻字列表
├── docs/                     # 详细文档
│   ├── 安装使用.md            # 导入步骤、测试方法、常见问题
│   └── 贡献指南.md            # 如何参与贡献
├── tools/IMEChecker/         # 实测工具（Swift命令行）
├── README.md                 # 项目说明（本文件）
├── CONTENTS.md               # 完整收录内容及版本日志
├── emoticons.md              # 颜文字使用指南及素材列表
├── char-filter.py            # 数据筛选脚本
├── pinyin-data.csv           # 字符拼音对照表
└── plist-template.plist      # plist格式模板
```

## 适用范围
仅兼容macOS原生简体拼音输入法，支持macOS Ventura、macOS Sonoma及以上版本。

## 快速使用

### 方案一：精简版（推荐）
下载 [**cannot-type.plist**](plist/cannot-type.plist)，收录50个偏旁部首 + 29个常用生僻字，共79条，经实测验证均为原生输入法无法打出的字符。

### 方案二：完整版
分别下载 [**radicals.plist**](plist/radicals.plist)（50条偏旁）和 [**rare-chars.plist**](plist/rare-chars.plist)（58条生僻字）。

### 方案三：无冲突版
下载 [**no-conflict.plist**](plist/no-conflict.plist)，已移除与超高频字拼音冲突的条目。

导入方式：打开 Mac 系统设置 → 键盘 → 文本输入 → 编辑... → 自定义短语，将 plist 文件直接拖入列表。

## 文件说明

> **说明**：当前 plist 文件基于 IMEChecker 工具在清空自定义短语后的实测结果生成，数据较初版更为准确。由于 OCR 识别存在一定局限性，个别字符的判断结果可能与实际情况略有出入，欢迎通过 Issue 反馈。

- [**cannot-type.plist**](plist/cannot-type.plist)：**推荐导入**。收录50个实测打不出的偏旁部首 + 29个常用生僻字，共79条
- [**radicals.plist**](plist/radicals.plist)：收录50个实测打不出的偏旁部首（完整版）
- [**rare-chars.plist**](plist/rare-chars.plist)：收录58个实测打不出的生僻字（完整版）
- [**no-conflict.plist**](plist/no-conflict.plist)：移除与前100高频字拼音冲突的字符后合并保留的版本
- [**emoticons.plist**](plist/emoticons.plist)：根据 [emoticons.md](emoticons.md) 自动生成的颜文字和符号，**未经人工测试**
- 「符号和颜文字.plist」：**仓库作者个人习惯文件**，仅供参考

## 收录内容
完整的字符收录列表及版本更新记录，请查阅 [CONTENTS.md](CONTENTS.md)。

## 数据来源
- 权威字表：基于《现代汉语词典》《通用规范汉字表》整理
- 拼音数据：参考pinyin-pro开源项目，确保拼音准确性
- 感谢所有开源项目及权威资料的支持

## 贡献指南
1.  若发现有遗漏的字符（字典有、输入法无或候选靠后），可提交Issue，注明字符、拼音及出处
2.  若发现拼音错误、plist导入异常，可提交PR修正
3.  禁止提交原生已有的字符、无关短句及违规内容

不熟悉GitHub操作？可借助AI工具（推荐国内可用：[豆包](https://www.doubao.com)、[Kimi](https://kimi.moonshot.cn)、[DeepSeek](https://chat.deepseek.com)）生成plist条目、确认拼音、撰写Issue描述。详见 [docs/贡献指南.md](docs/贡献指南.md)。

## 版本说明
- v1.0.0（首次发布）：包含偏旁部首、生僻字的plist文件及相关文档，无装饰符号
- v1.1.0（后续更新）：补充装饰符号plist，优化字符筛选逻辑
- v2.0.0（未来可能）：创建用于实测Mac输入的相关小应用
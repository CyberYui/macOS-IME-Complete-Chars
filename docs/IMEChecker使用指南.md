# IMEChecker 使用指南：引导 Agent AI 进行实测

## 一、工具简介

IMEChecker 是一个 macOS 命令行工具，专为 **Agent AI** 设计，用于自动批量测试指定汉字是否能被 macOS 原生简体拼音输入法打出，输出结构化的实测结果。

**解决的问题**：macOS 输入法词库内嵌于系统二进制，无法直接读取。IMEChecker 通过模拟用户输入 + 截图 OCR 的方式，绕过这一限制，实现程序化实测。

---

## 二、工作原理

```
输入CSV → 切换输入法 → 激活TextEdit → 模拟键盘输入拼音
    → 截图全屏 → Vision OCR识别候选窗口 → 提取汉字候选
    → 判断目标字符是否在候选中 → 输出结果CSV
```

**核心技术栈**：
- `Carbon / TIS API`：切换系统输入法为简体拼音
- `CGEvent`：模拟键盘输入拼音字符串
- `NSAppleScript`：激活 TextEdit 作为输入目标
- `screencapture`：截取全屏
- `Vision / VNRecognizeTextRequest`：OCR 识别截图中的汉字候选

---

## 三、前置条件

在引导 Agent AI 使用前，需确认以下权限已开启：

| 权限 | 路径 | 说明 |
|------|------|------|
| 辅助功能 | 系统设置 → 隐私与安全性 → 辅助功能 | 允许终端模拟键盘输入 |
| 屏幕录制 | 系统设置 → 隐私与安全性 → 屏幕录制与系统录音 | 允许终端截图 |

> 授权后如提示需要重启终端，**无需重启**，直接运行即可。

---

## 四、编译工具

首次使用前需编译：

```bash
cd tools/IMEChecker
swift build
```

编译产物位于 `.build/debug/IMEChecker`。

---

## 五、使用方法

### 基本用法

```bash
cd tools/IMEChecker
.build/debug/IMEChecker --input <输入CSV> --output <输出CSV>
```

### 输入文件格式

CSV 文件，UTF-8 编码，包含 `字` 和 `拼音` 两列：

```csv
字,拼音
丷,ba
攴,pu
鹫,jiu
```

本项目的 `pinyin-data.csv` 可直接作为输入。

### 输出文件格式

```csv
字符,拼音,原生可打出
丷,ba,false
攴,pu,true
鹫,jiu,true
```

---

## 六、实测示例

以下是引导 Agent AI 完成一次完整实测的示例流程：

**步骤1**：准备输入文件
```bash
# 使用项目自带的拼音数据
cp ../../pinyin-data.csv /tmp/test-input.csv
```

**步骤2**：分批运行（每批约50条，避免超时）
```bash
# 第一批
sed -n '1p;2,51p' /tmp/test-input.csv > /tmp/batch1.csv
.build/debug/IMEChecker --input /tmp/batch1.csv --output /tmp/batch1-results.csv

# 第二批
sed -n '1p;52,102p' /tmp/test-input.csv > /tmp/batch2.csv
.build/debug/IMEChecker --input /tmp/batch2.csv --output /tmp/batch2-results.csv
```

**步骤3**：合并结果
```python
import csv

files = ['/tmp/batch1-results.csv', '/tmp/batch2-results.csv']
results = []
seen = set()
for f in files:
    with open(f, encoding='utf-8') as fp:
        for line in fp.readlines()[1:]:
            parts = line.strip().split(',')
            if len(parts) >= 3 and parts[0] not in seen:
                seen.add(parts[0])
                results.append(parts)

with open('/tmp/full-results.csv', 'w', encoding='utf-8') as f:
    f.write('字符,拼音,原生可打出\n')
    for r in results:
        f.write(','.join(r) + '\n')
```

**步骤4**：分析结果
```python
cannot = [(r[0], r[1]) for r in results if r[2] == 'false']
print(f"打不出的字符（{len(cannot)}条）：{[c for c,_ in cannot]}")
```

---

## 七、注意事项

1. **运行时不要操作鼠标键盘**：工具运行期间会模拟键盘输入，人工操作会干扰测试结果

2. **保持 TextEdit 在前台**：工具会自动激活 TextEdit，但如果其他应用抢占焦点，会导致输入失败（结果偏向 false）

3. **分批运行**：建议每批不超过 60 条，全量运行可能因超时或焦点丢失导致卡死

4. **OCR 误判**：截图 OCR 方案存在约 5-10% 的误判率，主要原因：
   - 屏幕上其他窗口的汉字被误识别为候选
   - 笔画极简的偏旁（如`丨``丶``丿`）OCR 识别率低，可能误判为 false
   - 建议对结果中存疑的字符进行人工二次确认

5. **macOS 版本差异**：不同 macOS 版本的输入法词库有差异，实测结果仅代表当前系统版本

6. **重新编译**：macOS 大版本更新后建议重新编译工具（`swift build`）

---

## 八、结果可信度说明

| 结果 | 可信度 | 说明 |
|------|--------|------|
| `false`（打不出） | 高 | 候选中未出现目标字符，基本可信 |
| `true`（可打出） | 中 | 候选中出现了目标字符，但存在 OCR 误识别的可能 |

建议将 `true` 结果中笔画少于4画的偏旁进行人工验证。

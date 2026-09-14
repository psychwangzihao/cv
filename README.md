# 王梓豪 CV（LaTeX 版）

## 这是什么
用 LaTeX 排版、可一键重新生成的学术简历。源文件**只有 `main.tex` 一个**，
数据都写在里面（不像 Word 那样靠大表格对齐，所以改内容不会把排版弄乱）。

## 怎么用
```bash
bash ~/cv/build.sh        # 编译，并自动把 PDF 装到个人主页的 assets/pdf/
python3 ~/deploy.py pp    # 发布到 https://psychwangzihao.github.io
```

## 改内容
所有文字都在 `main.tex` 里，结构一目了然：

| 想改什么 | 找哪里 |
|---|---|
| 姓名 / 联系方式 | `% ---------------- header ----------------` |
| 教育经历 | `\cvsec{EDUCATION}` |
| 研究兴趣与受训 | `\cvsec{RESEARCH INTERESTS \& TRAINING}` |
| 研究经历 | `\cvsec{RESEARCH EXPERIENCE}` |
| 社会服务 | `\cvsec{COMMUNITY SERVICE}` |
| 荣誉奖项 | `\cvsec{HONORS \& AWARDS}` |

> 按本人要求：**不设 References 与 Presentations 两节**（尚无专属学术报告）。
> 章节分类沿用本人原有方式；排版与措辞参考了两份学界 CV（O. Morgan；K. Fang）。

一条经历的标准写法（左边日期、右边内容）：
```latex
\entry{09/2026 -- 09/2028}%
  {条目标题（加粗）}{%
  \textit{副标题 / 机构}\\[1pt]
  \begin{itemize}
    \item 一条要点
  \end{itemize}}
```
注意 LaTeX 里 `&` 要写成 `\&`，`%` 要写成 `\%`。

## 环境
- 版式：**参考 Owen Morgan 的 LaTeX CV（github.com/opmorgan/cv）**——章节标题加粗 + 下方通栏横线；每条经历"左日期栏 → 短竖杠 → 正文"；标题加粗、机构斜体、细节 `\footnotesize`；整体黑白不加色。
- 编译器：**XeLaTeX**。本机用 [Tectonic](https://tectonic-typesetting.github.io)
  （已装：`brew install tectonic`），它会自动下载所需宏包，无需装 5GB 的 MacTeX。
- 字体：**TeX Gyre Heros**（Helvetica 风）。想换字体改 `\setmainfont` 即可，
  已在本机验证可用：`libertinus`、`fira`、`sourcesanspro`。
- 也能放 **Overleaf**：上传 `main.tex`，把编译器设为 XeLaTeX 即可。

## 历史版本
`legacy/` 里是旧的 Word 版和旧 PDF 备份（仅存档，勿再使用：
其中含已放弃的牛津访问生表述）。

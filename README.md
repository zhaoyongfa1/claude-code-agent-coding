# agent-auto-build-code 使用说明

## 简介

`agent-auto-build-code` 是一个全栈代码生成编排 Agent，输入 HTML 产品原型（可选搭配需求文档），自动输出可直接运行的完整前后端代码，包括数据库建表 SQL、Java 后端、Web 管理端、H5 移动端。

支持两种模式：
- **仅原型模式**：只提供 HTML 原型，Agent 从界面结构推断实体和接口
- **原型 + 需求文档模式**：额外提供需求文档，Agent 额外提取业务规则、状态机、权限矩阵，生成更完整的代码

---

## 前置条件

### 1. 目录结构准备

将 HTML 原型文件按端类型放入对应子目录，需求文档放入 `docs/` 目录：

```
C:\Users\QT-H001\Desktop\car\
├── web\          ← Web 管理端原型（可选）
│   ├── 首页.html
│   ├── 用户管理.html
│   └── ...
├── h5\           ← H5 移动端原型（可选）
│   ├── 首页.html
│   ├── 列表页.html
│   └── ...
└── docs\         ← 需求文档目录（可选，放 .md 或 .txt 文件）
    ├── 业务规则说明.md
    ├── 状态流转说明.md
    └── ...
```

> **说明**：
> - `web/` 和 `h5/` 至少提供其中一个，Agent 会自动检测并跳过不存在的端
> - `docs/` 为可选目录，不存在时自动跳过，不影响整体流程

### 2. 需求文档内容建议

`docs/` 目录中的文档应重点描述 HTML 原型无法体现的业务逻辑，例如：

- **业务规则**：截止时间限制、提交条件、禁止操作的场景
- **状态流转**：订单/审批/任务等实体的状态变更路径和触发条件
- **角色权限**：不同角色可访问哪些功能、可操作哪些数据
- **计算规则**：金额计算、自动填充、汇总逻辑
- **通知规则**：哪些事件触发消息推送，推送给谁

### 3. 脚手架准备

| 脚手架 | 路径 | 说明 |
|--------|------|------|
| Java 后端基础工程 | `D:\java-project\base` | Spring Boot 3.x 工程，含公共工具类、基础配置 |
| Web 前端基础工程 | `D:\vue-project\base-front-web` | Vue3 + Element Plus 工程，含 request.ts 封装 |
| H5 前端基础工程 | `D:\vue-project\base-front-h5` | Vue3 + Vant 工程，含 request.ts 封装 |

### 4. 输出目录

Agent 会自动创建以下输出目录（无需手动创建）：

| 产物 | 输出路径 |
|------|----------|
| Java 后端代码 | `D:\java-project\auto-backend-code` |
| Web 前端代码 | `D:\vue-project\auto-web-front-code` |
| H5 前端代码 | `D:\vue-project\auto-h5-front-code` |
| 中间文件 | `D:\claude-agent-demo\.claude\` |

---

## 使用方法

在 Claude Code 中输入：

```
执行 agent-auto-build-code
```

---

## 工作流程

Agent 按以下阶段自动执行，其中**阶段一点八**、**阶段三**、**阶段五**需要人工确认后继续：

```
阶段零：检测原型目录
  └─ 扫描 web/ 和 h5/ 子目录，确认本次需要处理哪些端

阶段一：解析原型（可并行）
  ├─ [Web端存在] agent-parse-web  → web-prd.json
  └─ [H5端存在]  agent-parse-h5   → h5-prd.json

阶段一点五：解析需求文档（可选）
  └─ [docs/存在] agent-parse-doc  → biz-spec.json
     [docs/不存在] 自动跳过

阶段一点六：融合规格（有需求文档时执行）
  └─ [biz-spec.json存在] agent-merge-spec → product-spec.json
     [无需求文档] 自动跳过，后续使用 prd.json

阶段一点七：确定规格文件
  └─ 有需求文档 → 使用 product-spec.json
     无需求文档 → 使用 web-prd.json / h5-prd.json

阶段一点八：⚠️ 校验规格文件并人工确认
  └─ agent-validate-spec 自动执行结构校验 + 输出摘要，等待确认后继续

阶段二：生成数据库表结构（含断点续跑）
  └─ agent-build-sql → schema.sql

阶段三：⚠️ 人工审查 schema.sql
  └─ 展示建表清单，等待确认后继续

阶段四：生成后端代码（含断点续跑）
  └─ agent-build-backend → Java 代码 + api.json

阶段五：⚠️ 人工审查 api.json
  └─ 展示接口清单，等待确认后继续

阶段六：生成前端代码（可并行）
  ├─ [Web端存在] agent-build-front-web → Web 前端代码
  └─ [H5端存在]  agent-build-front-h5  → H5 前端代码

阶段七：生成启动文档
  └─ README.md（项目简介 + 启动步骤 + 接口清单）
```

---

## 人工审查节点说明

流程中有三个暂停点，需要人工确认：

### 阶段一点八：校验规格文件并确认摘要

Agent 会自动对规格文件执行结构校验，并输出一份中文摘要供人工确认。

**自动校验内容（机器完成）：**
- 必填字段完整性（实体、接口、业务规则等）
- 引用完整性（bizRuleRefs / notificationRef / 状态机 from/to 引用）
- 状态机内部一致性
- 枚举覆盖性
- pages 双端完整性

**人工确认内容（看摘要即可）：**
- 实体数量和字段数是否合理
- 接口按模块分组是否有遗漏
- 业务规则条数是否与需求文档对得上
- 页面数量 Web/H5 是否正确

处理方式：
- 校验发现**错误** → Agent 展示错误清单并暂停，直接编辑 `product-spec.json` 修复后回复 `继续`
- 校验仅有**警告** → Agent 展示警告和摘要，确认无误后回复 `继续`；如需修改先编辑文件再回复
- 校验**全部通过** → Agent 展示摘要，确认无误后回复 `继续`

### 阶段三：审查 schema.sql

Agent 会展示所有建表 SQL，确认表结构、字段类型、索引设计符合预期。

- 如需修改：直接编辑 `D:\claude-agent-demo\.claude\schema.sql`，编辑完成后回复 `继续`
- 无需修改：直接回复 `继续`

### 阶段五：审查 api.json

Agent 会展示所有接口清单（按模块分组），确认接口路径、请求/响应结构符合预期。

- 如需修改：直接编辑 `D:\claude-agent-demo\.claude\api.json`，编辑完成后回复 `继续`
- 无需修改：直接回复 `继续`

---

## 断点续跑

若执行过程中途中断，**重新执行 Agent 时会自动跳过已完成的阶段**：

| 检查文件 | 存在则跳过 |
|----------|------------|
| `schema.sql` | 阶段二（不重新生成 SQL） |
| `api.json` | 阶段四（不重新生成后端代码） |

若需要重新生成某个阶段，手动删除对应的中间文件即可：

```bash
# 重新生成 SQL 和后端（删除两个中间文件）
del D:\claude-agent-demo\.claude\schema.sql
del D:\claude-agent-demo\.claude\api.json

# 仅重新生成后端（保留 SQL）
del D:\claude-agent-demo\.claude\api.json

# 重新解析需求文档并重新融合（需同时删除三个文件）
del D:\claude-agent-demo\.claude\biz-spec.json
del D:\claude-agent-demo\.claude\product-spec.json
del D:\claude-agent-demo\.claude\api.json
```

---

## 修改路径配置

所有路径集中在 Agent 文件顶部的**变量定义区**统一维护，修改时只需编辑该文件一处：

```
D:\claude-agent-demo\.claude\agents\agent-auto-build-code.md
```

变量说明：

```
HTML_WEB   原型目录（Web端）
HTML_H5    原型目录（H5端）
DOC_PATH   需求文档目录（可选，放 .md/.txt 文件）
WEB_PRD    web-prd.json 输出路径
H5_PRD     h5-prd.json 输出路径
BIZ_SPEC   biz-spec.json 输出路径（需求文档解析结果）
SPEC_JSON  product-spec.json 输出路径（融合后完整规格）
SCHEMA_SQL schema.sql 输出路径
API_JSON   api.json 输出路径
README     README.md 输出路径
JAVA_BASE  Java 脚手架路径
JAVA_OUT   Java 代码输出路径
WEB_BASE   Web 前端脚手架路径
WEB_OUT    Web 前端代码输出路径
H5_BASE    H5 前端脚手架路径
H5_OUT     H5 前端代码输出路径
```

---

## 中间文件说明

Agent 执行过程中会在 `D:\claude-agent-demo\.claude\` 目录生成以下中间文件，可供人工查阅或二次使用：

| 文件 | 生成条件 | 说明 |
|------|----------|------|
| `web-prd.json` | Web端原型存在 | Web 端结构化需求（页面、字段、接口、枚举） |
| `h5-prd.json` | H5端原型存在 | H5 端结构化需求 |
| `biz-spec.json` | docs/目录存在 | 业务规格（业务规则、状态机、权限矩阵、计算规则、通知规则） |
| `product-spec.json` | docs/目录存在 | 融合后的完整规格（prd.json + biz-spec.json），后续代码生成的主要输入 |
| `schema.sql` | 始终生成 | 完整建表 SQL |
| `api.json` | 始终生成 | 接口契约（OpenAPI 格式） |
| `README.md` | 始终生成 | 项目启动文档 |

---

## 常见问题

**Q：原型目录下没有 `web/` 或 `h5/` 子目录，只有 HTML 文件怎么办？**

将 HTML 文件整理到对应子目录下。Agent 以子目录区分端类型，混放无法正确识别。

**Q：只有一端原型，另一端的代码不会生成吗？**

是的。Agent 在阶段零检测原型目录，不存在的端会自动跳过，不影响另一端的正常生成。

**Q：需求文档必须提供吗？**

不必须。不提供时 Agent 仅依据 HTML 原型生成代码，流程和之前完全一致。提供后会额外生成 `biz-spec.json` 和 `product-spec.json`，代码中包含更完整的业务逻辑。

**Q：需求文档支持哪些格式？**

支持 `.md` 和 `.txt` 格式。Word 文档请先转存为 `.md` 或 `.txt` 后放入 `docs/` 目录。

**Q：需求文档内容怎么写，有格式要求吗？**

没有严格格式要求，自然语言描述即可。Agent 会自动从文本中识别业务规则、状态流转、角色权限等信息。内容越完整清晰，提取效果越好。

**Q：生成的后端代码用的什么包名？**

来自 Java 脚手架的 `pom.xml`，Agent 会自动读取并沿用，无需额外配置。

**Q：阶段一点八校验报了错误，怎么修复？**

直接打开 `D:\claude-agent-demo\.claude\product-spec.json`，根据错误清单定位问题：
- 引用断裂（如 `bizRuleRefs` 引用了不存在的规则 ID）→ 修正 ID 或补充对应规则
- 状态机 from/to 无效 → 检查 states 中的 code 是否与 transitions 对应
- 必填字段缺失 → 补充对应字段

修复后直接回复"继续"，无需重新运行整个流程。

**Q：阶段一点八只有警告，可以直接忽略吗？**

警告不阻断生成，可以忽略。但建议先确认：
- 枚举缺失警告 → 忽略后生成代码中枚举类会缺失，可能需要手动补充
- 通知未引用警告 → 通常是文档描述了通知但状态机里忘记关联，影响通知逻辑生成
- dataConstraints 字段不存在警告 → 可能是 HTML 原型未展示该字段，可忽略或手动补字段

**Q：生成完成后如何启动项目？**

参考生成的 `D:\claude-agent-demo\.claude\README.md`，其中包含完整的启动步骤。


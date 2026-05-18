# agent-auto-build-code 使用说明

## 简介

`agent-auto-build-code` 是一个全栈代码生成编排 Agent，输入 HTML 产品原型，自动输出可直接运行的完整前后端代码，包括数据库建表 SQL、Java 后端、Web 管理端、H5 移动端。

---

## 前置条件

### 1. 目录结构准备

将 HTML 原型文件按端类型放入对应子目录：

```
C:\Users\QT-H001\Desktop\car\
├── web\          ← Web 管理端原型（可选）
│   ├── 首页.html
│   ├── 用户管理.html
│   └── ...
└── h5\           ← H5 移动端原型（可选）
    ├── 首页.html
    ├── 列表页.html
    └── ...
```

> **说明**：`web/` 和 `h5/` 目录至少提供其中一个，Agent 会自动检测并跳过不存在的端。

### 2. 脚手架准备

| 脚手架 | 路径 | 说明 |
|--------|------|------|
| Java 后端基础工程 | `D:\java-project\base` | Spring Boot 3.x 工程，含公共工具类、基础配置 |
| Web 前端基础工程 | `D:\vue-project\base-front-web` | Vue3 + Element Plus 工程，含 request.ts 封装 |
| H5 前端基础工程 | `D:\vue-project\base-front-h5` | Vue3 + Vant 工程，含 request.ts 封装 |

### 3. 输出目录

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

Agent 按以下 8 个阶段自动执行，其中**阶段三**和**阶段五**需要人工确认后继续：

```
阶段零：检测原型目录
  └─ 扫描 web/ 和 h5/ 子目录，确认本次需要处理哪些端

阶段一：解析原型（可并行）
  ├─ [Web端存在] agent-parse-web  → web-prd.json
  └─ [H5端存在]  agent-parse-h5   → h5-prd.json

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

流程中有两个暂停点，需要人工确认：

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
WEB_PRD    web-prd.json 输出路径
H5_PRD     h5-prd.json 输出路径
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

| 文件 | 说明 |
|------|------|
| `web-prd.json` | Web 端结构化需求（页面、字段、接口、枚举） |
| `h5-prd.json` | H5 端结构化需求 |
| `schema.sql` | 完整建表 SQL |
| `api.json` | 接口契约（OpenAPI 格式） |
| `README.md` | 项目启动文档 |

---

## 常见问题

**Q：原型目录下没有 `web/` 或 `h5/` 子目录，只有 HTML 文件怎么办？**

将 HTML 文件整理到对应子目录下。Agent 以子目录区分端类型，混放无法正确识别。

**Q：只有一端原型，另一端的代码不会生成吗？**

是的。Agent 在阶段零检测原型目录，不存在的端会自动跳过，不影响另一端的正常生成。

**Q：生成的后端代码用的什么包名？**

来自 Java 脚手架的 `pom.xml`，Agent 会自动读取并沿用，无需额外配置。

**Q：生成完成后如何启动项目？**

参考生成的 `D:\claude-agent-demo\.claude\README.md`，其中包含完整的启动步骤。

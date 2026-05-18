---
name: skill-build-front-h5-code
description: 根据H5端产品原型结构化文件和后端API接口，生成Vue3前端代码
allowed-tools: [Read, Grep, Glob, Write, Edit, Bash]
---

参数：$ARGUMENTS

请从上述参数中提取以下键值（格式为 key=value，多个用空格分隔）：
- prd-file=产品原型需求清单路径（必填）
- api-file=后端API接口文件路径（必填）
- front-path=前端代码输出路径（必填）
- base-path=H5前端脚手架基础目录路径（必填）
- 

## 执行步骤

**第一步：读取输入文件**
1. 使用 Read 工具读取 prd-file 指定的 prd.json 完整内容
2. 使用 Read 工具读取 api-file 指定的 api.json 完整内容

**第二步：读取脚手架结构**
1. 使用 Glob 工具扫描 base-path 目录下所有文件，了解工程目录结构
2. 使用 Read 工具读取以下关键文件作为生成模板：
   - `package.json`（获取依赖版本、项目名称）
   - `src/main.ts`（获取插件注册方式、全局配置风格）
   - `src/api/request.ts`（获取 axios 封装方式、拦截器风格、响应类型定义）
   - `src/router/index.ts`（获取路由初始化方式、守卫风格）
   - `src/stores/user.ts` 或任意一个 store 文件（获取 Pinia 编码风格）
   - `src/styles/variables.scss`（获取全局 CSS 变量名）
   - 任意一个已有 `.vue` 页面文件（获取组件结构和 UI 组件库用法）

**第三步：复制脚手架基础文件到输出目录**
使用 Bash 工具将脚手架公共文件复制到 front-path（目录不存在时先 `mkdir -p`）：

```bash
# 根目录配置文件
cp {base-path}/package.json {front-path}/package.json
cp {base-path}/vite.config.ts {front-path}/vite.config.ts
cp {base-path}/tsconfig.json {front-path}/tsconfig.json
cp {base-path}/index.html {front-path}/index.html
cp {base-path}/.env.development {front-path}/.env.development
cp {base-path}/.env.production {front-path}/.env.production

# 公共基础文件（原样复制）
cp -r {base-path}/src/assets {front-path}/src/assets
cp -r {base-path}/src/styles {front-path}/src/styles
cp -r {base-path}/src/utils {front-path}/src/utils
cp -r {base-path}/src/directives {front-path}/src/directives
cp -r {base-path}/src/plugins {front-path}/src/plugins
cp -r {base-path}/src/components {front-path}/src/components
cp -r {base-path}/src/composables {front-path}/src/composables

# 基础入口文件
cp {base-path}/src/main.ts {front-path}/src/main.ts
cp {base-path}/src/App.vue {front-path}/src/App.vue

# request 封装
mkdir -p {front-path}/src/api
cp {base-path}/src/api/request.ts {front-path}/src/api/request.ts

# store 基础文件
cp -r {base-path}/src/stores {front-path}/src/stores

# router 入口（后续追加业务路由模块）
mkdir -p {front-path}/src/router
cp {base-path}/src/router/index.ts {front-path}/src/router/index.ts
cp {base-path}/src/router/guards.ts {front-path}/src/router/guards.ts
```

**第四步：生成前端代码**
以脚手架为模板，严格遵循 CLAUDE.md 中的前端命名规范，按以下结构逐个文件生成，每个文件生成后立即使用 Write 工具写入对应路径，不要等全部生成完再统一写入。

### 类型定义层（按 api.json 每个 module）
- `front-path/src/types/api/{module}.ts`
  - 每个接口的入参类型，后缀 Req
  - 每个接口的出参类型，后缀 Resp
  - 分页数据使用 PageResult\<T\> 泛型

### 接口层（按 api.json 每个 module）
- `front-path/src/api/{module}.ts`
  - 每个接口生成一个函数，函数名与接口 name 对应
  - GET 用 request.get，POST 用 request.post，PUT 用 request.put，DELETE 用 request.delete
  - path 参数用模板字符串替换，如 `/user/${id}`
  - 禁止直接引入 axios，统一调用 request.ts 封装实例

### 枚举常量（来自 prd.json enums）
- `front-path/src/constants/enum.ts`
  - 每个 enum 生成对应的 TypeScript 枚举定义

### 路由层（按 prd.json 每个 module）
- `front-path/src/router/modules/{module}.ts`
  - 路由 name 用 PascalCase
  - 路由 path 用 kebab-case
  - component 指向对应 views 路径

### 页面层（按 prd.json 每个 page）
- `front-path/src/views/{module}/{PageName}.vue`
  - 统一使用 `<script setup lang="ts">` 语法
  - 文件顺序：`<script>` → `<template>` → `<style scoped>`
  - **列表页**：Element Plus 搜索表单（按 searchFields）+ el-table（按 tableColumns）+ 分页 + 工具栏按钮
  - **表单弹窗**：el-dialog 内嵌 el-form，按 dialogs[].fields 生成表单项，required 字段加 :rules 校验
  - **权限控制**：按钮加 v-permission 指令，值取各按钮的 permission 字段
  - **接口调用**：统一调用 api/{module}.ts 中的函数，禁止直接使用 axios

写入完成后输出：✅ 完成，前端代码已生成

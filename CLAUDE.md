# 后端

## 技术栈

### 后端技术栈

- Java 17 + springcloud 2023.0.3 + Spring Boot 3.2.0 + MyBatis-Plus3.5.9 + Redis 3.25.2 + RocketMQ 5.1

## Java 命名规范

### 命名风格

| 类型       | 风格               | 示例                             |
| -------- | ---------------- | ------------------------------ |
| 类、接口、枚举  | UpperCamelCase   | UserService、TaskStatusEnum     |
| 方法、变量、参数 | lowerCamelCase   | getUserById、tenantId           |
| 常量       | UPPER_SNAKE_CASE | MAX_RETRY_COUNT                |
| 包名       | 全小写，单数           | com.vt.iam.domain.model        |
| 数据库表/字段  | lower_snake_case | user_dept_relation、create_time |

### 类名后缀约定

- Controller / AppService / DomainService / Repository / RepositoryImpl
- Entity / DTO / VO / Converter / Enum / Constants
- Exception / Job / Consumer / Producer / Config

### 方法名前缀约定

- 查单个：`get` | 查列表：`list` | 查分页：`page` | 查数量：`count`
- 新增：`save/create` | 修改：`update` | 删除：`delete/remove`
- 校验：`validate/check` | 判断：`exists/has/is` | 发送：`send`

### 强制禁止

- 禁止拼音、中文、无意义缩写（tmp/a/b/str）
- 禁止下划线或 $ 开头/结尾（_name、name_）
- 禁止魔法值，必须定义常量后使用
- POJO 中布尔字段禁止加 is 前缀（用 deleted 不用 isDeleted）
- long/Long 赋值必须用大写 L（1000L 不用 1000l）
- 接口方法不加 public 修饰符

### 数据库约定

- 表必备三字段：id、create_time、update_time
- 主键索引：pk_xxx | 唯一索引：uk_xxx | 普通索引：idx_xxx
- 禁用 float/double，小数用 decimal

## 代码工程结构

### java后端工程结构

com.vt

├── controller // 接⼝适配层（Controller / RPC Adapter）

│ ├── web // HTTP 接⼝

│ └── rpc // RPC 接⼝适配（Provider）提供给外部调⽤

│

├── application // 应⽤层（⽤例编排）

│ ├── service // 应⽤服务（⽆复杂业务规则）调用domain层业务类及repository接口
│ ├── dto // 应⽤ DTO

│ └── vo // 返回对象

│

├── domain // 领域层（核⼼业务）

│ ├── model // BO / Entity

│ ├── service // 领域服务（核⼼业务规则）聚合业务

│ └── repository // 仓储接⼝（只定义接⼝）

│

├── infrastructure // 基础设施层

│ ├── repository // DAO / 引用MybatisPlus Mapper 实现

│ ├── mq // MQ 实现

│ ├── cache // Redis

│ └── config // 技术配置

│

├── converter // 对象转换

└── common // 公共⼯具

## 错误码规范

**统一错误码**

**采用 10位字符串 格式：A-BB-CCC-DDD**

| 段位  | 长度  | 说明      | 示例                  |
| --- | --- | ------- | ------------------- |
| A   | 1   | 错误来源/级别 | 4 客户端错误 / 5 服务端错误   |
| BB  | 2   | 系统/模块标识 | 01 用户中心 / 02 订单系统   |
| CCC | 3   | 错误分类    | 001 参数错误 / 002 认证错误 |
| DDD | 3   | 具体错误序号  | 001~ 999 自增         |

**系统/模块标识（BB段）**

| 编码  | 系统/模块  | 说明  |
| --- | ------ | --- |
| 01  | IAM    |     |
| 02  | 车辆管理   |     |
| 03  | 食堂管理平台 |     |
| 04  | 访客预约系统 |     |

**错误分类（CCC段）**

| 分类码 | 类型     | 说明               | 示例场景            |
| --- | ------ | ---------------- | --------------- |
| 001 | 参数错误   | 参数缺失、格式错误、校验不通过  | 必填字段为空          |
| 002 | 认证错误   | 未登录、token失效、签名错误 | 缺少token、token过期 |
| 003 | 权限错误   | 无操作权限、角色不允许      | 越权访问资源          |
| 004 | 资源不存在  | 数据未找到            | 订单不存在、用户不存在     |
| 005 | 状态错误   | 状态不允许当前操作        | 订单已取消无法支付       |
| 006 | 重复操作   | 重复提交、唯一性冲突       | 重复下单、用户名已存在     |
| 007 | 依赖服务错误 | 调用下游服务失败         | 调用支付网关超时        |
| 008 | 数据错误   | 数据完整性、一致性异常      | 数据脏读、乐观锁失败      |
| 009 | 系统内部错误 | 未捕获异常、业务逻辑错误     | NPE、配置错误        |
| 010 | 限流熔断   | 流量控制、服务降级        | 触发限流规则          |
| 011 | 第三方错误  | 外部API错误          | 微信接口返回错误        |

# 前端

## 技术栈

### 前端技术栈

Vue 3 + TypeScript + Vite + elementplus

## 命名规范

| 类型          | 风格                    | 示例                          |
| ----------- | --------------------- | --------------------------- |
| 组件文件        | PascalCase            | UserList.vue、BaseTable.vue  |
| 普通文件（工具/钩子） | camelCase             | useTable.ts、formatDate.ts   |
| 变量、函数、参数    | camelCase             | userId、getUserList          |
| 常量          | UPPER_SNAKE_CASE      | MAX_PAGE_SIZE               |
| CSS 类名      | kebab-case            | user-card、btn-primary       |
| props 定义    | camelCase             | pageSize、modelValue         |
| emit 事件名    | kebab-case            | update:modelValue、row-click |
| Pinia store | camelCase，useXxxStore | useUserStore                |
| 路由 name     | PascalCase            | UserList、OrderDetail        |
| 路由 path     | kebab-case            | /user-list、/order-detail    |

#### 方法名前缀约定

- 查单个：`get` | 查列表：`list/fetch` | 查分页：`page`
- 新增：`save/create` | 修改：`update` | 删除：`delete/remove`
- 校验：`validate/check` | 判断：`is/has/can`

#### 强制禁止

- 禁止拼音、无意义缩写（a/b/tmp/str）
- 禁止魔法值，必须定义常量使用
- 禁止布尔变量加 is 前缀（用 deleted 不用 isDeleted）

## 组件规范

- 统一使用 `<script setup lang="ts">` 语法，禁止 Options API
- 单文件组件顺序：`<script>` → `<template>` → `<style>`
- props 必须用 TypeScript 类型定义，禁止 propType 运行时写法
- 禁止在 template 中写复杂逻辑，抽取到 computed 或方法
- 单组件文件不超过 300 行，超出须拆分子组件
- 样式必须加 scoped，避免全局污染
- 父子通信：props down，emits up，禁止子组件修改 props
- 非必要禁止直接操作 DOM，优先用 ref 和指令

## 接口调用规范

- 禁止在组件或 store 中直接使用 axios，统一调用 api/ 下的函数
- api 函数必须有入参和出参的 TypeScript 类型，放在 types/api/ 下
- 接口统一通过 request.ts 封装的实例调用，不允许新建 axios 实例
- 接口错误统一在拦截器处理，组件层无需单独 catch 通用错误

## TypeScript 规范

- 禁止使用 any，确实不确定类型用 unknown 并做类型收窄
- 优先用 interface 定义对象类型，用 type 定义联合/交叉类型
- 接口入参类型后缀 Req，出参后缀 Resp，分页数据用 PageResult
- 枚举值统一在 constants/enum.ts 中定义
- 禁止断言滥用（as），类型不明时先完善类型定义

## 状态管理规范（Pinia）

- 按业务模块拆分 store，禁止一个巨型 store
- store 中只放跨组件共享状态，页面私有状态放组件内
- 禁止在 store 中直接操作 DOM 或调用路由跳转（路由跳转在组件层）
- 异步操作写在 actions 中，不允许在组件中修改 store 内部状态（除 patch）

## 样式规范

- 全局颜色、间距、字体大小必须使用 variables.scss 中的变量
- 禁止行内 style 写死颜色和尺寸
- Element Plus 主题覆盖统一在 styles/ 目录下处理，不在组件内 :deep 大范围覆盖
- 响应式断点使用 mixins.scss 统一定义

## 禁止事项汇总

- 禁止 Options API，统一 Composition API + script setup
- 禁止直接引入 axios，必须走 request.ts
- 禁止硬编码接口地址，统一走环境变量
- 禁止在 template 中调用有副作用的函数（会重复执行）
- 禁止 console.log 提交到代码仓库
- 禁止未经封装直接使用 localStorage，统一走 utils/storage.ts

## 代码工程结构

### 前端代码工程结构

src/
├── assets/ # 静态资源
│ ├── images/
│ ├── icons/
│ └── styles/
│ ├── variables.scss # 全局变量
│ ├── mixins.scss
│ └── global.scss
│
├── api/ # 接口层（按业务模块拆分）
│ ├── request.ts # axios 封装（拦截器、错误处理）
│ ├── user.ts
│ ├── order.ts
│ └── department.ts
│
├── types/ # TypeScript 类型定义
│ ├── api/ # 接口入参/出参类型
│ │ ├── user.ts
│ │ └── order.ts
│ └── global.d.ts
│
├── stores/ # 状态管理（Pinia）
│ ├── index.ts # store 统一导出
│ ├── user.ts # 用户/权限状态
│ ├── app.ts # 应用全局状态（主题、语言）
│ └── permission.ts # 路由权限状态
│
├── router/ # 路由层
│ ├── index.ts # 路由实例、全局守卫
│ ├── guards.ts # 路由守卫（鉴权、埋点）
│ └── modules/ # 按模块拆分路由
│ ├── user.ts
│ └── order.ts
│
├── views/ # 页面层（路由级组件，只做组合）
│ ├── user/
│ │ ├── UserList.vue
│ │ ├── UserForm.vue
│ │ └── components/ # 页面私有组件
│ │ └── UserTable.vue
│ └── order/
│ ├── OrderList.vue
│ └── components/
│
├── components/ # 通用组件层（跨页面复用）
│ ├── BaseTable/
│ │ ├── index.vue
│ │ └── types.ts
│ ├── BaseForm/
│ ├── BaseModal/
│ └── BaseUpload/
│
├── composables/ # 组合式逻辑层（hooks）
│ ├── useTable.ts # 通用分页表格逻辑
│ ├── useForm.ts # 通用表单逻辑
│ ├── usePermission.ts # 权限判断
│ └── useDict.ts # 数据字典
│
├── utils/ # 工具函数层
│ ├── format.ts # 格式化（日期、金额）
│ ├── validate.ts # 校验规则
│ ├── storage.ts # localStorage 封装
│ └── permission.ts # 权限工具函数
│
├── directives/ # 自定义指令
│ ├── index.ts
│ ├── permission.ts # v-permission
│ └── loading.ts
│
├── plugins/ # 插件注册
│ ├── index.ts
│ ├── element-plus.ts
│ └── i18n.ts
│
├── locales/ # 国际化
│ ├── zh-CN.ts
│ └── en-US.ts
│
├── constants/ # 常量层
│ ├── index.ts
│ └── enum.ts # 枚举值（状态码、字典）
│
├── App.vue
└── main.ts

---
name: skill-h5-product-parse
description: 深度解析H5端HTML原型，提取页面、字段、交互、业务规则，输出 h5-prd.json 供后续 skill 使用
allowed-tools: [Read, Grep, Glob, Write, Edit, Bash]
---

参数：$ARGUMENTS

请从上述参数中提取以下键值（格式为 key=value，多个用空格分隔）：

- html-path=HTML原型文件路径（必填）
- prd-file=结果输出路径（必填）

## 执行步骤

**第一步：读取文件**
使用 Read 工具读取 html-path 目录下所有的HTML文件完整内容。

**第二步：深度解析**
基于读取到的 HTML 内容，提取所有页面、字段、交互、业务规则，严格按照以下 JSON 结构输出，不得增减顶层字段：

```json
{
  "project": {
    "name": "项目名称",
    "modules": ["模块1", "模块2"]
  },
  "entities": [
    {
      "name": "User",
      "tableName": "sys_user",
      "comment": "用户表",
      "fields": [
        {
          "name": "id",
          "column": "id",
          "javaType": "Long",
          "mysqlType": "BIGINT",
          "length": null,
          "nullable": false,
          "primaryKey": true,
          "unique": false,
          "defaultValue": null,
          "comment": "主键ID"
        },
        {
          "name": "username",
          "column": "username",
          "javaType": "String",
          "mysqlType": "VARCHAR",
          "length": 50,
          "nullable": false,
          "primaryKey": false,
          "unique": true,
          "defaultValue": null,
          "comment": "用户名"
        }
      ],
      "indexes": [
        { "type": "uk", "name": "uk_username", "columns": ["username"] }
      ],
      "relations": [
        { "type": "many-to-many", "target": "Role", "through": "sys_user_role" }
      ]
    }
  ],
  "enums": [
    {
      "name": "UserStatusEnum",
      "comment": "用户状态",
      "values": [
        { "name": "DISABLED", "code": 0, "label": "禁用" },
        { "name": "ENABLED",  "code": 1, "label": "启用" }
      ]
    }
  ],
  "apis": [
    {
      "module": "用户管理",
      "prefix": "/api/v1/user",
      "items": [
        {
          "name": "分页查询用户列表",
          "method": "GET",
          "path": "/page",
          "permission": "user:list",
          "request": {
            "query": [
              { "name": "pageNum",  "javaType": "Integer", "required": true,  "default": 1 },
              { "name": "pageSize", "javaType": "Integer", "required": true,  "default": 10 },
              { "name": "keyword",  "javaType": "String",  "required": false, "comment": "关键词搜索" }
            ]
          },
          "response": { "type": "Page", "entity": "User" }
        },
        {
          "name": "新增用户",
          "method": "POST",
          "path": "/add",
          "permission": "user:add",
          "request": {
            "body": [
              { "name": "username", "javaType": "String",    "required": true,  "validation": ["NotBlank", "Length(max=50)"] },
              { "name": "password", "javaType": "String",    "required": true,  "validation": ["NotBlank"] },
              { "name": "roleIds",  "javaType": "List<Long>","required": false }
            ]
          },
          "response": { "type": "Long", "comment": "新增用户ID" }
        },
        {
          "name": "修改用户",
          "method": "PUT",
          "path": "/update",
          "permission": "user:edit",
          "request": {
            "body": [
              { "name": "id",       "javaType": "Long",   "required": true },
              { "name": "username", "javaType": "String", "required": true, "validation": ["NotBlank"] }
            ]
          },
          "response": { "type": "Boolean" }
        },
        {
          "name": "删除用户",
          "method": "DELETE",
          "path": "/{id}",
          "permission": "user:delete",
          "request": {
            "path": [
              { "name": "id", "javaType": "Long", "required": true }
            ]
          },
          "response": { "type": "Boolean" }
        }
      ]
    }
  ],
  "pages": [
    {
      "name": "用户列表",
      "route": "/user/list",
      "routeName": "UserList",
      "module": "用户管理",
      "type": "list",
      "permission": "user:list",
      "searchFields": [
        { "name": "keyword", "label": "关键词", "type": "input", "placeholder": "用户名/手机号" }
      ],
      "tableColumns": [
        { "name": "username",   "label": "用户名", "sortable": false },
        { "name": "phone",      "label": "手机号", "sortable": false },
        { "name": "status",     "label": "状态",   "type": "tag", "enum": "UserStatusEnum" },
        { "name": "createTime", "label": "创建时间","sortable": true }
      ],
      "buttons": [
        { "label": "新增", "type": "primary", "action": "openForm",    "permission": "user:add" },
        { "label": "批量删除", "type": "danger", "action": "batchDelete", "permission": "user:delete" }
      ],
      "rowActions": [
        { "label": "编辑", "action": "openForm",  "permission": "user:edit" },
        { "label": "删除", "action": "deleteRow", "permission": "user:delete" }
      ],
      "dialogs": [
        {
          "name": "UserForm",
          "title": "新增/编辑用户",
          "trigger": ["新增按钮", "编辑按钮"],
          "fields": [
            { "name": "username", "label": "用户名", "type": "input",    "required": true },
            { "name": "password", "label": "密码",   "type": "password", "required": true, "showOnEdit": false },
            { "name": "roleIds",  "label": "角色",   "type": "select",   "required": false, "multiple": true, "dataSource": "getRoleList" }
          ]
        }
      ],
      "bindApi": {
        "list":   "GET /api/v1/user/page",
        "add":    "POST /api/v1/user/add",
        "update": "PUT /api/v1/user/update",
        "delete": "DELETE /api/v1/user/{id}"
      }
    }
  ]
}
```

以上结构为模板示例，请根据实际 HTML 原型内容填充所有页面和实体，每个模块的所有页面和实体都必须输出。

**javaType 取值范围**：String / Long / Integer / Boolean / LocalDateTime / BigDecimal / List\<Long\>
**mysqlType 取值范围**：VARCHAR / BIGINT / INT / TINYINT / DATETIME / DECIMAL / TEXT

**第三步：写入文件**
使用 Write 工具将生成的完整 JSON 写入 prd-file 参数指定的路径。

写入完成后输出：✅ 完成，h5-prd.json 已生成

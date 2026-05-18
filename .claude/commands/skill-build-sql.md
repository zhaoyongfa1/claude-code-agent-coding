---
name: skill-build-sql
description: 根据产品原型结构化文件需求，生成完整MySQL数据库设计
allowed-tools: [Read, Grep, Glob, Write, Edit, Bash]
---

参数：$ARGUMENTS

请从上述参数中提取以下键值（格式为 key=value，多个用空格分隔）：

- web-prd-file=web产品原型结构化文件路径（web-prd-file与h5-prd-file其中一个必填）
- h5-prd-file=h5产品原型结构化文件路径（web-prd-file与h5-prd-file其中一个必填）
- sql-file=SQL脚本输出路径（必填）

## 执行步骤

**第一步：读取文件**
使用 Read 工具分别读取 web-prd-file 和 h5-prd-file 参数指定路径的 JSON 文件完整内容。

**第二步：生成建表 SQL**
根据 JSON 中的 `entities` 字段生成标准 MySQL 建表语句，要求如下：

1. 每张表必须包含以下公共字段（放在最后）：
   - id BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键ID'
   - tenant_id BIGINT NOT NULL COMMENT '租户ID'
   - created_by BIGINT NOT NULL COMMENT '创建人ID'
   - dept_id BIGINT DEFAULT NULL COMMENT '部门ID'
   - `create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间'`
   - `update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间'`
   - `deleted TINYINT NOT NULL DEFAULT 0 COMMENT '是否删除 0否 1是'`
2. 字段类型严格使用 JSON 中的 `mysqlType`，字符串长度使用 `length` 字段值
3. `nullable` 为 false 的字段加 NOT NULL 约束
4. 每个字段必须加 COMMENT 中文注释
5. 根据 `indexes` 生成索引，命名规则：唯一索引 uk_xxx，普通索引 idx_xxx
6. `relations` 中 many-to-many 关系生成中间关联表，表名使用 `through` 字段值
7. 禁用 float/double，小数统一用 DECIMAL
8. 表名、字段名统一使用 lower_snake_case
9. 每张表末尾加 ENGINE=InnoDB DEFAULT CHARSET=utf8mb4

**只输出 SQL 语句，不要输出 ER 图或其他说明文字。**

**第三步：写入文件**
使用 Write 工具将生成的完整 SQL 写入 sql-file 参数指定的路径。

写入完成后输出：✅ 完成，schema.sql 已生成

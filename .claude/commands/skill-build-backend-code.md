---
name: skill-build-backend-code
description: 根据产品原型结构化文件、数据库SQL脚本和Java脚手架，生成完整Java后端代码
allowed-tools: [Read, Grep, Glob, Write, Bash]
---

参数：$ARGUMENTS

请从上述参数中提取以下键值（格式为 key=value，多个用空格分隔）：
- web-prd-file=web产品原型需求清单路径（web-prd-file与h5-prd-file其中一个必填）
- h5-prd-file=h5产品原型需求清单路径（web-prd-file与h5-prd-file其中一个必填）
- sql-file=SQL脚本路径（必填）
- base-path=Java后端基础脚手架路径（必填）
- java-path=后端代码输出路径（必填）
- api-file=后端API文件输出路径（必填）

## 执行步骤

**第一步：读取输入文件**
1. 使用 Read 工具读取 web-prd-file 指定的json文件完整内容
2. 使用 Read 工具读取 h5-prd-file 指定的json文件完整内容 
3. 使用 Read 工具读取 sql-file 指定的 schema.sql 完整内容

**第二步：读取脚手架结构**
1. 使用 Glob 工具扫描 base-path 目录下所有文件，了解工程目录结构
2. 使用 Read 工具读取以下关键文件作为生成模板：
   - pom.xml（获取依赖版本、包名前缀）
   - 启动类（获取根包名及注解风格）
   - 任意一个现有 Controller 文件（获取注解风格、返回值包装类）
   - 任意一个现有 Entity 文件（获取公共基类、MyBatis-Plus 注解风格）
   - 任意一个现有 AppService 文件（获取应用层编码风格）

**第三步：复制脚手架基础文件到输出目录**

使用 Bash 工具依次执行以下复制命令，将脚手架公共文件搬入 java-path（目录不存在时先 mkdir -p）：

```bash
# 1. 根目录文件
cp {base-path}/pom.xml {java-path}/pom.xml
cp {base-path}/.gitignore {java-path}/.gitignore

# 2. 配置文件
mkdir -p {java-path}/src/main/resources/mapper
cp {base-path}/src/main/resources/bootstrap.yml {java-path}/src/main/resources/bootstrap.yml
cp {base-path}/src/main/resources/logback-spring.xml {java-path}/src/main/resources/logback-spring.xml

# 3. 公共工具类（原样复制）
cp -r {base-path}/src/main/java/com/vt/common {java-path}/src/main/java/com/vt/common

# 4. 分页基础 DTO
mkdir -p {java-path}/src/main/java/com/vt/application/dto
cp {base-path}/src/main/java/com/vt/application/dto/PageQuery.java {java-path}/src/main/java/com/vt/application/dto/PageQuery.java

# 5. 基础设施公共类（原样复制）
cp -r {base-path}/src/main/java/com/vt/infrastructure/config {java-path}/src/main/java/com/vt/infrastructure/config
cp -r {base-path}/src/main/java/com/vt/infrastructure/cache {java-path}/src/main/java/com/vt/infrastructure/cache
mkdir -p {java-path}/src/main/java/com/vt/infrastructure/repository
cp {base-path}/src/main/java/com/vt/infrastructure/repository/BaseMapperRepository.java {java-path}/src/main/java/com/vt/infrastructure/repository/BaseMapperRepository.java
```

复制完成后，使用 Write 工具完成以下两项定制：

1. **生成启动类**：参考 base-path 启动类注解风格，以 prd.json 的 `project.name`（转 UpperCamelCase）命名，写入 `{java-path}/src/main/java/com/vt/{ProjectName}Application.java`
2. **更新 pom.xml**：将 `<artifactId>base</artifactId>` 改为项目名称（kebab-case），`<description>` 改为项目名称对应描述

**第四步：生成后端代码**
严格遵循 claude.md 中的工程结构和命名规范，以脚手架为模板，按 prd.json 中每个 entity 生成以下文件，使用 Write 工具逐个写入 java-path 对应路径：

- `controller/web/{Module}Controller.java`
  - 每个 api.items 生成一个方法
  - 加 @RestController、@RequestMapping、@Tag（Swagger）注解
  - 每个方法加 @Operation(summary) 注解
  - 统一返回 Result\<T\> 包装类
- `application/service/{Module}AppService.java` 及其实现类
- `application/dto/{Module}SaveDTO.java`（对应 POST/PUT 接口的 request.body）
- `application/dto/{Module}QueryDTO.java`（对应 GET 接口的 request.query）
- `application/vo/{Module}VO.java`（对应 response 字段）
- `domain/model/{Module}Entity.java`（字段来自 entities，继承基类）
- `domain/service/{Module}DomainService.java`
- `domain/repository/{Module}Repository.java`（接口，只定义方法签名）
- `infrastructure/repository/{Module}RepositoryImpl.java`（实现 Repository 接口，引用 Mapper）
- `infrastructure/repository/mapper/{Module}Mapper.java`（继承 BaseMapper）
- `converter/{Module}Converter.java`（Entity ↔ VO ↔ DTO 转换）

**第五步：生成 API 契约文件**
扫描所有已生成的 Controller，提取接口信息，按 OpenAPI JSON 标准格式写入 api-file。

提取规则：
- `@GetMapping/@PostMapping/@PutMapping/@DeleteMapping` → method + path
- `@RequestParam/@RequestBody` 字段及类型 → request query/body 参数
- `@PathVariable` 字段及类型 → request path 参数
- 方法返回值泛型（如 `Result<PageVO<UserVO>>`）→ response 类型
- `@Operation(summary = "xxx")` → 接口名称
- `@PreAuthorize` 或权限注解 → permission 字段

使用 Write 工具将结果写入 api-file 参数指定路径。

写入完成后输出：✅ 完成，后端代码和 api.json 已生成

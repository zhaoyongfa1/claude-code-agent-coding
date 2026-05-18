-- ============================================================
-- 车辆管理系统 数据库建表脚本
-- 数据库：utf8mb4
-- 生成时间：2026-04-30
-- ============================================================

-- ----------------------------
-- 1. 车辆档案表 car_vehicle
-- ----------------------------
CREATE TABLE `car_vehicle` (
  `archive_no`        VARCHAR(50)   NOT NULL                                    COMMENT '档案编号，系统自动生成',
  `plate`             VARCHAR(20)   NOT NULL                                    COMMENT '车牌号',
  `brand`             VARCHAR(50)   NOT NULL                                    COMMENT '车辆品牌',
  `model`             VARCHAR(50)   DEFAULT NULL                                COMMENT '车辆型号',
  `vin`               VARCHAR(50)   DEFAULT NULL                                COMMENT '车架号VIN',
  `engine_no`         VARCHAR(50)   DEFAULT NULL                                COMMENT '发动机号',
  `color`             VARCHAR(20)   NOT NULL                                    COMMENT '车辆颜色',
  `use_nature`        VARCHAR(20)   DEFAULT NULL                                COMMENT '使用性质：非营运/营运/公务',
  `seat_count`        INT           DEFAULT 5                                   COMMENT '座位数',
  `category`          VARCHAR(50)   DEFAULT NULL                                COMMENT '车辆分类：生产运输车辆/厂内转运车辆/员工通勤车辆/商务接待车辆/特种作业车辆/应急保障车辆/清洁环卫车辆/私人车辆',
  `attribute`         VARCHAR(30)   DEFAULT NULL                                COMMENT '车辆属性：自有车辆/租赁车辆/合作方临时借用',
  `status`            TINYINT       NOT NULL DEFAULT 1                          COMMENT '车辆状态：1可用 2维修中 3保养中 4停用 5报废',
  `responsible_id`    BIGINT        DEFAULT NULL                                COMMENT '责任人ID',
  `responsible_name`  VARCHAR(50)   DEFAULT NULL                                COMMENT '责任人姓名（冗余字段）',
  `dept_name`         VARCHAR(50)   DEFAULT NULL                                COMMENT '所属部门名称（冗余字段）',
  `contract_start`    DATETIME      DEFAULT NULL                                COMMENT '承运服务合同开始日期',
  `contract_end`      DATETIME      DEFAULT NULL                                COMMENT '承运服务合同结束日期',
  `remarks`           TEXT          DEFAULT NULL                                COMMENT '备注',
  `inspection_date`   DATETIME      DEFAULT NULL                                COMMENT '年检有效期',
  `inspection_status` TINYINT       DEFAULT NULL                                COMMENT '车检状态：1有效 2逾期',
  -- 公共字段
  `id`                BIGINT        NOT NULL AUTO_INCREMENT                     COMMENT '主键ID',
  `tenant_id`         BIGINT        NOT NULL                                    COMMENT '租户ID',
  `created_by`        BIGINT        NOT NULL                                    COMMENT '创建人ID',
  `dept_id`           BIGINT        DEFAULT NULL                                COMMENT '部门ID',
  `create_time`       DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP          COMMENT '创建时间',
  `update_time`       DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted`           TINYINT       NOT NULL DEFAULT 0                          COMMENT '是否删除 0否 1是',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_archive_no` (`archive_no`),
  UNIQUE KEY `uk_plate` (`plate`),
  UNIQUE KEY `uk_vin` (`vin`),
  INDEX `idx_status` (`status`),
  INDEX `idx_dept_id` (`dept_id`),
  INDEX `idx_responsible_id` (`responsible_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='车辆档案表';


-- ----------------------------
-- 2. 车辆保险信息表 car_vehicle_insurance
-- ----------------------------
CREATE TABLE `car_vehicle_insurance` (
  `vehicle_id`        BIGINT        NOT NULL                                    COMMENT '车辆ID',
  `insurance_type`    VARCHAR(20)   NOT NULL                                    COMMENT '险种：交强险/商业险/其他',
  `custom_type_name`  VARCHAR(50)   DEFAULT NULL                                COMMENT '自定义险种名称（险种为其他时填写）',
  `company`           VARCHAR(100)  DEFAULT NULL                                COMMENT '投保公司',
  `start_date`        DATETIME      DEFAULT NULL                                COMMENT '保险开始日期',
  `end_date`          DATETIME      DEFAULT NULL                                COMMENT '保险结束日期',
  `status`            TINYINT       DEFAULT NULL                                COMMENT '保险状态：1有效 2即将到期 3逾期',
  -- 公共字段
  `id`                BIGINT        NOT NULL AUTO_INCREMENT                     COMMENT '主键ID',
  `tenant_id`         BIGINT        NOT NULL                                    COMMENT '租户ID',
  `created_by`        BIGINT        NOT NULL                                    COMMENT '创建人ID',
  `dept_id`           BIGINT        DEFAULT NULL                                COMMENT '部门ID',
  `create_time`       DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP          COMMENT '创建时间',
  `update_time`       DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted`           TINYINT       NOT NULL DEFAULT 0                          COMMENT '是否删除 0否 1是',
  PRIMARY KEY (`id`),
  INDEX `idx_vehicle_id` (`vehicle_id`),
  INDEX `idx_end_date` (`end_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='车辆保险信息表';


-- ----------------------------
-- 3. 车辆附件表 car_vehicle_attachment
-- ----------------------------
CREATE TABLE `car_vehicle_attachment` (
  `vehicle_id`        BIGINT        NOT NULL                                    COMMENT '车辆ID',
  `attachment_type`   VARCHAR(50)   NOT NULL                                    COMMENT '附件类型：photos/purchaseContract/purchaseInvoice/registrationCert/drivingLicense/taxCertificate/other',
  `file_name`         VARCHAR(200)  NOT NULL                                    COMMENT '原始文件名',
  `file_url`          VARCHAR(500)  NOT NULL                                    COMMENT '文件存储URL',
  `file_size`         BIGINT        DEFAULT NULL                                COMMENT '文件大小（字节）',
  -- 公共字段
  `id`                BIGINT        NOT NULL AUTO_INCREMENT                     COMMENT '主键ID',
  `tenant_id`         BIGINT        NOT NULL                                    COMMENT '租户ID',
  `created_by`        BIGINT        NOT NULL                                    COMMENT '创建人ID',
  `dept_id`           BIGINT        DEFAULT NULL                                COMMENT '部门ID',
  `create_time`       DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP          COMMENT '创建时间',
  `update_time`       DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted`           TINYINT       NOT NULL DEFAULT 0                          COMMENT '是否删除 0否 1是',
  PRIMARY KEY (`id`),
  INDEX `idx_vehicle_id` (`vehicle_id`),
  INDEX `idx_attachment_type` (`attachment_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='车辆附件表';


-- ----------------------------
-- 4. 事故处置记录表 car_accident
-- ----------------------------
CREATE TABLE `car_accident` (
  `accident_no`       VARCHAR(50)   NOT NULL                                    COMMENT '事故编号，系统自动生成',
  `vehicle_id`        BIGINT        NOT NULL                                    COMMENT '车辆ID',
  `plate`             VARCHAR(20)   NOT NULL                                    COMMENT '车牌号（冗余字段）',
  `accident_time`     DATETIME      NOT NULL                                    COMMENT '事故发生时间',
  `location`          VARCHAR(200)  NOT NULL                                    COMMENT '事故地点',
  `accident_type`     VARCHAR(20)   NOT NULL                                    COMMENT '事故类型：剐蹭/碰撞/追尾/侧翻/自燃/其他',
  `police_involved`   TINYINT       NOT NULL DEFAULT 0                          COMMENT '是否报警：0否 1是',
  `responsibility`    VARCHAR(30)   DEFAULT NULL                                COMMENT '事故责任：全部责任/主要责任/同等责任/次要责任/无责任/无法认定责任（报警时填写）',
  `description`       TEXT          NOT NULL                                    COMMENT '事故描述，最多500字',
  `remarks`           TEXT          DEFAULT NULL                                COMMENT '备注',
  `status`            TINYINT       NOT NULL DEFAULT 1                          COMMENT '审批状态：1草稿 2审批中 3已驳回 4已闭环',
  `severity`          TINYINT       DEFAULT NULL                                COMMENT '严重程度：1低 2中 3高',
  `result`            VARCHAR(500)  DEFAULT NULL                                COMMENT '处置结果（已闭环时填写）',
  `reporter_id`       BIGINT        NOT NULL                                    COMMENT '上报人ID',
  `reporter_name`     VARCHAR(50)   NOT NULL                                    COMMENT '上报人姓名',
  `report_time`       DATETIME      DEFAULT NULL                                COMMENT '上报时间',
  -- 公共字段
  `id`                BIGINT        NOT NULL AUTO_INCREMENT                     COMMENT '主键ID',
  `tenant_id`         BIGINT        NOT NULL                                    COMMENT '租户ID',
  `created_by`        BIGINT        NOT NULL                                    COMMENT '创建人ID',
  `dept_id`           BIGINT        DEFAULT NULL                                COMMENT '部门ID',
  `create_time`       DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP          COMMENT '创建时间',
  `update_time`       DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted`           TINYINT       NOT NULL DEFAULT 0                          COMMENT '是否删除 0否 1是',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_accident_no` (`accident_no`),
  INDEX `idx_vehicle_id` (`vehicle_id`),
  INDEX `idx_status` (`status`),
  INDEX `idx_reporter_id` (`reporter_id`),
  INDEX `idx_accident_time` (`accident_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='事故处置记录表';


-- ----------------------------
-- 5. 事故费用明细表 car_accident_expense
-- ----------------------------
CREATE TABLE `car_accident_expense` (
  `accident_id`       BIGINT        NOT NULL                                    COMMENT '事故记录ID',
  `title`             VARCHAR(100)  NOT NULL                                    COMMENT '费用标题',
  `expense_desc`      VARCHAR(500)  DEFAULT NULL                                COMMENT '费用说明',
  `amount`            DECIMAL(12,2) NOT NULL                                    COMMENT '费用金额（元）',
  -- 公共字段
  `id`                BIGINT        NOT NULL AUTO_INCREMENT                     COMMENT '主键ID',
  `tenant_id`         BIGINT        NOT NULL                                    COMMENT '租户ID',
  `created_by`        BIGINT        NOT NULL                                    COMMENT '创建人ID',
  `dept_id`           BIGINT        DEFAULT NULL                                COMMENT '部门ID',
  `create_time`       DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP          COMMENT '创建时间',
  `update_time`       DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted`           TINYINT       NOT NULL DEFAULT 0                          COMMENT '是否删除 0否 1是',
  PRIMARY KEY (`id`),
  INDEX `idx_accident_id` (`accident_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='事故费用明细表';


-- ----------------------------
-- 6. 事故附件表 car_accident_attachment
-- ----------------------------
CREATE TABLE `car_accident_attachment` (
  `accident_id`       BIGINT        NOT NULL                                    COMMENT '事故记录ID',
  `expense_id`        BIGINT        DEFAULT NULL                                COMMENT '费用明细ID（费用凭证时填写）',
  `attachment_type`   VARCHAR(20)   NOT NULL                                    COMMENT '附件类型：voucher（费用凭证）/other（其他附件）',
  `file_name`         VARCHAR(200)  NOT NULL                                    COMMENT '原始文件名',
  `file_url`          VARCHAR(500)  NOT NULL                                    COMMENT '文件存储URL',
  `file_size`         BIGINT        DEFAULT NULL                                COMMENT '文件大小（字节）',
  -- 公共字段
  `id`                BIGINT        NOT NULL AUTO_INCREMENT                     COMMENT '主键ID',
  `tenant_id`         BIGINT        NOT NULL                                    COMMENT '租户ID',
  `created_by`        BIGINT        NOT NULL                                    COMMENT '创建人ID',
  `dept_id`           BIGINT        DEFAULT NULL                                COMMENT '部门ID',
  `create_time`       DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP          COMMENT '创建时间',
  `update_time`       DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted`           TINYINT       NOT NULL DEFAULT 0                          COMMENT '是否删除 0否 1是',
  PRIMARY KEY (`id`),
  INDEX `idx_accident_id` (`accident_id`),
  INDEX `idx_expense_id` (`expense_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='事故附件表';

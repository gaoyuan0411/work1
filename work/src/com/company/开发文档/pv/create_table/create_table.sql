-- ==================================================================
-- 表名称： dwd__pv__event_detail_hour__dd__incr
-- 所属主题域： 页面浏览域
-- 实现功能： 页面浏览域-小时级事件汇总表
-- 数据来源： QT或神策数据
-- 时间周期： 天
-- 创建人员： 104096
-- 创建日期： 2024-01-19
-- 依赖源表： ods__event_data_detail
--           ods_aplus_event_ri
-- 备    注： 根据配置表表从QT或者神策的明细数据中获取页面浏览域的事件明细数据，
--            并关联用户信息表补充用户的地域信息，如果存在用户则优先使用用户的地域作为浏览地域，否则用当前IP的地域作为浏览地域
-- ==================================================================
CREATE TABLE IF NOT EXISTS dwm__pv__event_detail_hour__dd__incr (
    user_id                 bigint    COMMENT '评分用户id',
    device_id               string    COMMENT '设备id',
    week_day                int       COMMENT '星期几，0：星期天，1-6：星期一到星期六',
    event_hour              string    COMMENT '小时，00-23',
    identity                string    COMMENT '浏览时身份',
    language                string    COMMENT '浏览语言',
    content_id              string    COMMENT '内容id',
    content_type            string    COMMENT '内容类型',
    channel_code            string    COMMENT '频道编码',
    channel_name            string    COMMENT '频道名称',
    module_code             string    COMMENT '模块编码: 根据事件编码和配置表关联获取',
    tag_code_1              string    COMMENT '标签1编码',
    tag_name_1              string    COMMENT '标签1名称',
    tag_code_2              string    COMMENT '标签2编码',
    tag_name_2              string    COMMENT '标签2名称',
    tag_code_3              string    COMMENT '标签3编码',
    tag_name_3              string    COMMENT '标签3名称',
    tag_code_4              string    COMMENT '标签4编码',
    tag_name_4              string    COMMENT '标签4名称',
    tag_code_5              string    COMMENT '标签5编码',
    tag_name_5              string    COMMENT '标签5名称',
    tag_code_6              string    COMMENT '标签6编码',
    tag_name_6              string    COMMENT '标签6名称',
    tag_code_7              string    COMMENT '标签7编码',
    tag_name_7              string    COMMENT '标签7名称',
    tag_code_8              string    COMMENT '标签8编码',
    tag_name_8              string    COMMENT '标签8名称',
    tag_code_9              string    COMMENT '标签9编码',
    tag_name_9              string    COMMENT '标签9名称',
    tag_code_10             string    COMMENT '标签10编码',
    tag_name_10             string    COMMENT '标签10名称',
    country_name            string    COMMENT '所属国家名称',
    province_id             bigint    COMMENT '所属省id',
    province_name           string    COMMENT '所属省名称',
    city_id                 bigint    COMMENT '所属市id',
    city_name               string    COMMENT '所属市名称',
    area_id                 bigint    COMMENT '所属区id',
    area_name               string    COMMENT '所属区名称',
    school_id               bigint    COMMENT '所属学校编码',
    school_name             string    COMMENT '所属学校名称',
    app_key                 string    COMMENT '上报appkey',
    product_id              string    COMMENT '产品标识',
    product_code            string    COMMENT '产品编码',
    product_platform        string    COMMENT '产品所属端：按埋点的app_key区分，不区分web和h5',
    platform                string    COMMENT '平台',
    is_new_device           int       COMMENT '是否新设备: 0-否，1-是',
    visit_times             bigint    COMMENT '访问次数',
    stat_time               timestamp COMMENT '统计处理时间'
) COMMENT '页面浏览域-事件明细表' PARTITIONED BY (
  `dt` string COMMENT '分区-日期(yyyy-MM-dd)',
  `pc` string COMMENT '分区-平台编码,使用product_code'
) ROW FORMAT DELIMITED NULL DEFINED AS '';


-- ==================================================================
-- 表名称： dwm__pv__event_detail_hour__dm__incr
-- 所属主题域： 页面浏览域
-- 实现功能： 页面浏览域-小时级事件月预统计表
-- 数据来源： QT或神策数据
-- 时间周期： 天
-- 创建人员： 104096
-- 创建日期： 2024-01-19
-- 依赖源表： ods__event_data_detail
--           ods_aplus_event_ri
-- 备    注： 根据配置表表从QT或者神策的明细数据中获取页面浏览域的事件明细数据，
--            并关联用户信息表补充用户的地域信息，如果存在用户则优先使用用户的地域作为浏览地域，否则用当前IP的地域作为浏览地域
-- ==================================================================
CREATE TABLE IF NOT EXISTS dwm__pv__event_detail_hour__dm__incr (
    user_id                 bigint    COMMENT '评分用户id',
    device_id               string    COMMENT '设备id',
    week_day                int       COMMENT '星期几，0：星期天，1-6：星期一到星期六',
    event_hour              string    COMMENT '小时，00-23',
    identity                string    COMMENT '浏览时身份',
    language                string    COMMENT '浏览语言',
    content_id              string    COMMENT '内容id',
    content_type            string    COMMENT '内容类型',
    channel_code            string    COMMENT '频道编码',
    channel_name            string    COMMENT '频道名称',
    module_code             string    COMMENT '模块编码: 根据事件编码和配置表关联获取',
    country_name            string    COMMENT '所属国家名称',
    province_id             bigint    COMMENT '所属省id',
    province_name           string    COMMENT '所属省名称',
    city_id                 bigint    COMMENT '所属市id',
    city_name               string    COMMENT '所属市名称',
    area_id                 bigint    COMMENT '所属区id',
    area_name               string    COMMENT '所属区名称',
    school_id               bigint    COMMENT '所属学校编码',
    school_name             string    COMMENT '所属学校名称',
    app_key                 string    COMMENT '上报appkey',
    product_id              string    COMMENT '产品标识',
    product_code            string    COMMENT '产品编码',
    product_platform        string    COMMENT '产品所属端：按埋点的app_key区分，不区分web和h5',
    platform                string    COMMENT '平台',
    one_day_visit_times     bigint    COMMENT '新设备当天访问次数',
    visit_times             bigint    COMMENT '访问次数',
    stat_time               timestamp COMMENT '统计处理时间'
) COMMENT '页面浏览域-事件明细表' PARTITIONED BY (
    `dt` string COMMENT '分区-月(yyyy-MM)',
    `pc` string COMMENT '分区-平台编码,使用product_code'
) ROW FORMAT DELIMITED NULL DEFINED AS '';

-- ==================================================================
-- 表名称： dwm__pv__event_detail_hour__dy__incr
-- 所属主题域： 页面浏览域
-- 实现功能： 页面浏览域-小时级事件年预统计表
-- 数据来源： QT或神策数据
-- 时间周期： 天
-- 创建人员： 104096
-- 创建日期： 2024-01-19
-- 依赖源表： ods__event_data_detail
--           ods_aplus_event_ri
-- 备    注： 根据配置表表从QT或者神策的明细数据中获取页面浏览域的事件明细数据，
--            并关联用户信息表补充用户的地域信息，如果存在用户则优先使用用户的地域作为浏览地域，否则用当前IP的地域作为浏览地域
-- ==================================================================
CREATE TABLE IF NOT EXISTS dwm__pv__event_detail_hour__dy__incr (
    user_id                 bigint    COMMENT '评分用户id',
    device_id               string    COMMENT '设备id',
    event_hour              string    COMMENT '小时，00-23',
    week_day                int       COMMENT '星期几，0：星期天，1-6：星期一到星期六',
    identity                string    COMMENT '浏览时身份',
    language                string    COMMENT '浏览语言',
    content_id              string    COMMENT '内容id',
    content_type            string    COMMENT '内容类型',
    channel_code            string    COMMENT '频道编码',
    channel_name            string    COMMENT '频道名称',
    module_code             string    COMMENT '模块编码: 根据事件编码和配置表关联获取',
    country_name            string    COMMENT '所属国家名称',
    province_id             bigint    COMMENT '所属省id',
    province_name           string    COMMENT '所属省名称',
    city_id                 bigint    COMMENT '所属市id',
    city_name               string    COMMENT '所属市名称',
    area_id                 bigint    COMMENT '所属区id',
    area_name               string    COMMENT '所属区名称',
    school_id               bigint    COMMENT '所属学校编码',
    school_name             string    COMMENT '所属学校名称',
    app_key                 string    COMMENT '上报appkey',
    product_id              string    COMMENT '产品标识',
    product_code            string    COMMENT '产品编码',
    product_platform        string    COMMENT '产品所属端：按埋点的app_key区分，不区分web和h5',
    platform                string    COMMENT '平台',
    one_day_visit_times     bigint    COMMENT '新设备当天访问次数',
    visit_times             bigint    COMMENT '访问次数',
    stat_time               timestamp COMMENT '统计处理时间'
) COMMENT '页面浏览域-事件明细表' PARTITIONED BY (
    `dt` string COMMENT '分区-月(yyyy)',
    `pc` string COMMENT '分区-平台编码,使用product_code'
) ROW FORMAT DELIMITED NULL DEFINED AS '';


-- ==================================================================
-- 表名称： dwm__pv__event_detail_tag_hour__dm__incr
-- 所属主题域： 页面浏览域
-- 实现功能： 页面浏览域-标签小时级事件月预统计表（只统计学生自主学习（course）频道的数据）
-- 数据来源： QT或神策数据
-- 时间周期： 天
-- 创建人员： 104096
-- 创建日期： 2024-01-19
-- 依赖源表： ods__event_data_detail
--           ods_aplus_event_ri
-- 备    注： 根据配置表表从QT或者神策的明细数据中获取页面浏览域的事件明细数据，
--            并关联用户信息表补充用户的地域信息，如果存在用户则优先使用用户的地域作为浏览地域，否则用当前IP的地域作为浏览地域
-- ==================================================================
CREATE TABLE IF NOT EXISTS dwm__pv__event_detail_tag_hour__dm__incr (
    user_id                 bigint    COMMENT '评分用户id',
    device_id               string    COMMENT '设备id',
    week_day                int       COMMENT '星期几，0：星期天，1-6：星期一到星期六',
    event_hour              string    COMMENT '小时，00-23',
    identity                string    COMMENT '浏览时身份',
    language                string    COMMENT '浏览语言',
    content_id              string    COMMENT '内容id',
    content_type            string    COMMENT '内容类型',
    channel_code            string    COMMENT '频道编码',
    channel_name            string    COMMENT '频道名称',
    module_code             string    COMMENT '模块编码: 根据事件编码和配置表关联获取',
    tag_code_1              string    COMMENT '标签1编码',
    tag_name_1              string    COMMENT '标签1名称',
    tag_code_2              string    COMMENT '标签2编码',
    tag_name_2              string    COMMENT '标签2名称',
    tag_code_3              string    COMMENT '标签3编码',
    tag_name_3              string    COMMENT '标签3名称',
    tag_code_4              string    COMMENT '标签4编码',
    tag_name_4              string    COMMENT '标签4名称',
    tag_code_5              string    COMMENT '标签5编码',
    tag_name_5              string    COMMENT '标签5名称',
    tag_code_6              string    COMMENT '标签6编码',
    tag_name_6              string    COMMENT '标签6名称',
    tag_code_7              string    COMMENT '标签7编码',
    tag_name_7              string    COMMENT '标签7名称',
    tag_code_8              string    COMMENT '标签8编码',
    tag_name_8              string    COMMENT '标签8名称',
    tag_code_9              string    COMMENT '标签9编码',
    tag_name_9              string    COMMENT '标签9名称',
    tag_code_10             string    COMMENT '标签10编码',
    tag_name_10             string    COMMENT '标签10名称',
    country_name            string    COMMENT '所属国家名称',
    province_id             bigint    COMMENT '所属省id',
    province_name           string    COMMENT '所属省名称',
    city_id                 bigint    COMMENT '所属市id',
    city_name               string    COMMENT '所属市名称',
    area_id                 bigint    COMMENT '所属区id',
    area_name               string    COMMENT '所属区名称',
    school_id               bigint    COMMENT '所属学校编码',
    school_name             string    COMMENT '所属学校名称',
    app_key                 string    COMMENT '上报appkey',
    product_id              string    COMMENT '产品标识',
    product_code            string    COMMENT '产品编码',
    product_platform        string    COMMENT '产品所属端：按埋点的app_key区分，不区分web和h5',
    platform                string    COMMENT '平台',
    one_day_visit_times     bigint    COMMENT '新设备当天访问次数',
    visit_times             bigint    COMMENT '访问次数',
    stat_time               timestamp COMMENT '统计处理时间'
) COMMENT '页面浏览域-事件明细表' PARTITIONED BY (
  `dt` string COMMENT '分区-日期(yyyy-MM)',
  `pc` string COMMENT '分区-平台编码,使用product_code'
) ROW FORMAT DELIMITED NULL DEFINED AS '';

-- ==================================================================
-- 表名称： dwm__pv__event_detail_tag_hour__dy__incr
-- 所属主题域： 页面浏览域
-- 实现功能： 页面浏览域-标签小时级事件年预统计表（只统计学生自主学习（course）频道的数据）
-- 数据来源： QT或神策数据
-- 时间周期： 天
-- 创建人员： 104096
-- 创建日期： 2024-01-19
-- 依赖源表： ods__event_data_detail
--           ods_aplus_event_ri
-- 备    注： 根据配置表表从QT或者神策的明细数据中获取页面浏览域的事件明细数据，
--            并关联用户信息表补充用户的地域信息，如果存在用户则优先使用用户的地域作为浏览地域，否则用当前IP的地域作为浏览地域
-- ==================================================================
CREATE TABLE IF NOT EXISTS dwm__pv__event_detail_tag_hour__dy__incr (
    user_id                 bigint    COMMENT '评分用户id',
    device_id               string    COMMENT '设备id',
    week_day                int       COMMENT '星期几，0：星期天，1-6：星期一到星期六',
    event_hour              string    COMMENT '小时，00-23',
    identity                string    COMMENT '浏览时身份',
    language                string    COMMENT '浏览语言',
    content_id              string    COMMENT '内容id',
    content_type            string    COMMENT '内容类型',
    channel_code            string    COMMENT '频道编码',
    channel_name            string    COMMENT '频道名称',
    module_code             string    COMMENT '模块编码: 根据事件编码和配置表关联获取',
    tag_code_1              string    COMMENT '标签1编码',
    tag_name_1              string    COMMENT '标签1名称',
    tag_code_2              string    COMMENT '标签2编码',
    tag_name_2              string    COMMENT '标签2名称',
    tag_code_3              string    COMMENT '标签3编码',
    tag_name_3              string    COMMENT '标签3名称',
    tag_code_4              string    COMMENT '标签4编码',
    tag_name_4              string    COMMENT '标签4名称',
    tag_code_5              string    COMMENT '标签5编码',
    tag_name_5              string    COMMENT '标签5名称',
    tag_code_6              string    COMMENT '标签6编码',
    tag_name_6              string    COMMENT '标签6名称',
    tag_code_7              string    COMMENT '标签7编码',
    tag_name_7              string    COMMENT '标签7名称',
    tag_code_8              string    COMMENT '标签8编码',
    tag_name_8              string    COMMENT '标签8名称',
    tag_code_9              string    COMMENT '标签9编码',
    tag_name_9              string    COMMENT '标签9名称',
    tag_code_10             string    COMMENT '标签10编码',
    tag_name_10             string    COMMENT '标签10名称',
    country_name            string    COMMENT '所属国家名称',
    province_id             bigint    COMMENT '所属省id',
    province_name           string    COMMENT '所属省名称',
    city_id                 bigint    COMMENT '所属市id',
    city_name               string    COMMENT '所属市名称',
    area_id                 bigint    COMMENT '所属区id',
    area_name               string    COMMENT '所属区名称',
    school_id               bigint    COMMENT '所属学校编码',
    school_name             string    COMMENT '所属学校名称',
    app_key                 string    COMMENT '上报appkey',
    product_id              string    COMMENT '产品标识',
    product_code            string    COMMENT '产品编码',
    product_platform        string    COMMENT '产品所属端：按埋点的app_key区分，不区分web和h5',
    platform                string    COMMENT '平台',
    one_day_visit_times     bigint    COMMENT '新设备当天访问次数',
    visit_times             bigint    COMMENT '访问次数',
    stat_time               timestamp COMMENT '统计处理时间'
) COMMENT '页面浏览域-事件明细表' PARTITIONED BY (
  `dt` string COMMENT '分区-日期(yyyy)',
  `pc` string COMMENT '分区-平台编码,使用product_code'
) ROW FORMAT DELIMITED NULL DEFINED AS '';




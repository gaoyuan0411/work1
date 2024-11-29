-- ==================================================================
-- 表名称： dwd__smart_special__event_detail__dd__incr
-- 所属主题域： 门户专题域
-- 实现功能： 门户专题域-事件明细表
-- 数据来源： QT或神策数据
-- 时间周期： 天
-- 创建人员： 10017103
-- 创建日期： 2024-08-16
-- ==================================================================
CREATE TABLE IF NOT EXISTS dwd__smart_special__event_detail__dd__incr (
    user_id                 bigint    COMMENT '评分用户id',
    device_id               string    COMMENT '设备id',
    identity                string    COMMENT '浏览时身份',
    channel_code            string    COMMENT '频道编码:从事件中扩展字段中拆分',
    channel_name            string    COMMENT '频道名称:从事件中扩展字段中拆分',
    country_name            string    COMMENT '所属国家名称',
    province_id             bigint    COMMENT '所属省id',
    province_name           string    COMMENT '所属省名称',
    city_id                 bigint    COMMENT '所属市id',
    city_name               string    COMMENT '所属市名称',
    area_id                 bigint    COMMENT '所属区id',
    area_name               string    COMMENT '所属区名称',
    school_id               bigint    COMMENT '所属学校编码',
    school_name             string    COMMENT '所属学校名称',
    user_country_name       string    COMMENT '用户所属国家名称',
    user_province_id        bigint    COMMENT '用户所属省id',
    user_province_name      string    COMMENT '用户所属省名称',
    user_city_id            bigint    COMMENT '用户所属市id',
    user_city_name          string    COMMENT '用户所属市名称',
    user_area_id            bigint    COMMENT '用户所属区id',
    user_area_name          string    COMMENT '用户所属区名称',
    user_school_id          bigint    COMMENT '用户的学校id',
    user_school_name        string    COMMENT '用户的学校名称',
    ip_country_name         string    COMMENT 'IP所属国家名称',
    ip_province_id          bigint    COMMENT 'IP所属省id',
    ip_province_name        string    COMMENT 'IP所属省名称',
    ip_city_id              bigint    COMMENT 'IP所属市id',
    ip_city_name            string    COMMENT 'IP所属市名称',
    ip_area_id              bigint    COMMENT 'IP所属区id',
    ip_area_name            string    COMMENT 'IP所属区名称',
    log_id                  string    COMMENT '访问日志id',
    local_time              string    COMMENT '访问日志本地时间',
    server_time             string    COMMENT '访问日志时间',
    app_key                 string    COMMENT '上报appkey',
    product_id              string    COMMENT '产品标识',
    product_code            string    COMMENT '产品编码',
    product_platform        string    COMMENT '产品所属端：按埋点的app_key区分，不区分web和h5',
    event_code              string    COMMENT '事件编码',
    event_type              string    COMMENT '事件类型',
    device_brand            string    COMMENT '设备品牌',
    device_model            string    COMMENT '设备机型',
    os                      string    COMMENT '操作系统',
    os_version              string    COMMENT '操作系统版本',
    browser                 string    COMMENT '浏览器名，例如 Chrome',
    browser_version         string    COMMENT '浏览器版本，例如 Chrome 45',
    platform                string    COMMENT '平台',
    ip                      string    COMMENT 'ip',
    carrier                 string    COMMENT '运营商名称，例如 ChinaNet',
    is_first_day            boolean   COMMENT '是否首日访问',
    is_first_time           boolean   COMMENT '是否是首次启动',
    manufacturer            string    COMMENT '设备制造商，例如 Apple',
    brand                   string    COMMENT '设备品牌',
    model                   string    COMMENT '设备型号，例如 iPhone 8,4',
    properties              string    COMMENT '自定义属性（神策为properties字段；qt为cusp字段）',
    app_version             string    COMMENT '客户端版本',
    timezone                string    COMMENT '时区，默认为东八区：8',
    stat_time               timestamp COMMENT '统计处理时间'
) COMMENT '页面浏览域-事件明细表' PARTITIONED BY (
  `dt` string COMMENT '分区-日期(yyyy-MM-dd)'
) ROW FORMAT DELIMITED NULL DEFINED AS '';

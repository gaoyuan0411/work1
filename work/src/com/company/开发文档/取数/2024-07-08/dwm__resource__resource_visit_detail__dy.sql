-- ==================================================================
-- 脚本名称： dwm__resource__resource_visit_detail__dy
-- 实现功能： 北师大241所学校数据，访问频次明细
-- 创建者：   1007103
-- 创建日期： 2024-07-08
-- ==================================================================
CREATE TABLE dwm__resource__resource_visit_detail__dy
(
    `user_id`         BIGINT COMMENT '用户id',
    `app_key`          string COMMENT 'app_key',
    `channel_code`      string COMMENT '频道编码',
    `visit_count`     BIGINT COMMENT '访问量',
    `detail_visit_count`     BIGINT COMMENT '最细粒度访问'
) COMMENT '资源-资源浏览明细-每年-增量' PARTITIONED BY (
    dt string COMMENT '分区-日期(yyyy)'
    ) ROW FORMAT DELIMITED NULL DEFINED AS '';
insert overwrite table dwm__resource__resource_visit_detail__dy partition(dt='2023')
select user_id,app_key,channel_code,sum(visit_count) as visit_count,sum(detail_visit_count) as detail_visit_count  from nddc.dwm__resource__resource_visit_detail__d
where dt between '2023-01-01' and '2023-12-31'
and user_id <> 0
and channel_code <> ''
and app_key <> ''
group by user_id,app_key,channel_code


--问题：课程教学>学生自主学习(精品课)>高中>英语>沪教版-必修 第二册微课视频应该是9个  计算结果是8个
--原因查询
--微课视频tag_id查询
SELECT *
FROM nddc.ods__auxo_tag__e_view_tag__mysql__full t
WHERE t.dt = '${biz_date}'
  AND t.parent_id = 'bklx'
  AND t.title IN ('微课视频');
--微课视频视频的tag_id为：502036372019
--资源所挂id查询
SELECT *
FROM nddc.ods__xedu_ndr_tag__taged_object__mdb__full t
WHERE dt = '${biz_date}'
  AND tenant_id = '1'
  AND SPLIT(id, '_')[0] = 'd9071956-6d91-4062-ba9b-c7bc83700b29' --查询tag_ids挂在5036342730下面没有挂在微课的id下面
  --上面的查询得到结论resource_id='d9071956-6d91-4062-ba9b-c7bc83700b29' 这条资源的挂载id少了微课的id导致了微课视频少算了一条
  --需要业务处理
    5d71ceb9-2a42-4f71-bb73-de4592fa7763
ea8cc7c8-5000-51cd-912c-ac0eaf9d7e2b
CREATE EXTERNAL TABLE `nddc.ods__habit_cultivate__mysql__habit_user__full`
(
    `user_habit_id`         STRING COMMENT '标识',
    `tenant_id`             BIGINT COMMENT '租户ID',
    `user_id`               BIGINT COMMENT '用户标识',
    `agent_user_id`         BIGINT COMMENT '代理用户ID（一般是指家长ID）',
    `habit_id`              STRING COMMENT '习惯标识',
    `join_time`             STRING COMMENT '参加时间',
    `create_time`           STRING COMMENT '创建时间',
    `create_user`           BIGINT COMMENT '创建者',
    `update_time`           STRING COMMENT '更新时间',
    `update_user`           BIGINT COMMENT '更新者',
    `user_name`             STRING COMMENT '',
    `user_name_pin_yin`     STRING COMMENT '',
    `habit_status`          TINYINT COMMENT '打卡的状态(冗余)',
    `habit_activity_status` TINYINT COMMENT '打卡启用状态(冗余)',
    `habit_create_time`     STRING COMMENT '',
    `habit_begin_time`      BIGINT COMMENT '',
    `habit_end_time`        BIGINT COMMENT '',
    `role`                  STRING COMMENT '',
    `activity_source`       INT COMMENT '活动来源',
    `class_id`              BIGINT COMMENT '班级ID',
    `apply_status`          TINYINT COMMENT '报名状态',
    `is_deleted`            INT COMMENT '是否被删除',
    `habit_name`            STRING COMMENT '打卡名称'
)
    COMMENT 'ods-打卡-打卡用户-每天更新-全量'
    PARTITIONED BY (
        `dt` STRING COMMENT '??-??(yyyy-MM-dd)',
        `db` STRING COMMENT '??')
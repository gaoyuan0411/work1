--20240508-4月月报数据
--2.师生认证【治港】
--平台上线至今，累计开设151.74万个班级，其中包含行政班75.97万个、普通班75.78万个，建立家校群、班级群、教研群等群组259.3万个。群组数量排名居全国前5位的省份依次是XXX省（XXX个）、XXX省（XXX个）、XXX省（XXX个）、XXX省（XXX个）、XXX省（XXX个）。
--本月，平台新建XXX万个班级，其中包含行政班XXX万个、普通班XXX万个，XXX名教师、XXX名学生加入了行政班；新增家校群、班级群、教研群等群组XXX万个。新增群组数量排名居全国前5位的省份依次是XXX省（XXX个）、XXX省（XXX个）、XXX省（XXX个）、XXX省（XXX个）、XXX省（XXX个）。
--1、资源使用情况【高远】
--本月，平台资源累计被访问149.35亿次，
----数据来源：页面浏览-资源类浏览数据
--被访问次数最多的前5条资源是XXXX（XXX次）、XXXX（XXX次）、XXXX（XXX次）、XXXX（XXX次）、XXXX（XXX次），
--数据来源：  select * from
              nddc.ads__zxx__resource__res_visit__stat__da_p  t -- 查询条件设置
            where t.period_code='202404'
             and  t.site_type = 'zxx'
              and t.province_id = '0'
              and t.identity = 'all'
              and t.app_type = 'all'
              order by pv desc
              limit 5
--分别来自XXXX、XXXX、XXXX、XXXX、XXXX频道；
--被访问次数最多的前3个频道排分别是XXXX（XXX次）、XXXX（XXX次）、XXXX（XXX次）。
----数据来源：页面浏览-资源类浏览数据
--本月，平台用户累计转发资源XXX次，被转发次数最多的前5条资源是XXXX（XXX次）、XXXX（XXX次）、XXXX（XXX次）、XXXX（XXX次）、XXXX（XXX次），分别来自XXXX、XXXX、XXXX、XXXX、XXXX频道；被转发次数最多的前3个频道分别是XXXX（XXX次）、XXXX（XXX次）、XXXX（XXX次）。
--数据来源：功能分析—共享分享
--频道数据
SELECT
  channel_code,channel_name,sum(share_total_count) as share_total_count
from
  nddc.ads__ri__area_share_object_rank2__d__full
where
  period_type_code = '30'
  AND period_code = '202404'
  and province_id = '0'
  and (
    city_id = 0
    or city_id IS null
  )
  and object_type = 'resource'
  and share_method = 'ALL'
  and resource_id != 'ALL'
  and x_product_id = 'e5649925-441d-4a53-b525-51a2f1c4e0a8'
  GROUP BY channel_code,channel_name
order by
  sum(share_total_count)  desc
--本月，平台用户累计点赞资源XXX次，被点赞次数最多的前5条资源是XXXX（XXX次）、XXXX（XXX次）、XXXX（XXX次）、XXXX（XXX次）、XXXX（XXX次），分别来自XXXX、XXXX、XXXX、XXXX、XXXX频道；被点赞次数最多的前3个频道排分别是XXXX（XXX次）、XXXX（XXX次）、XXXX（XXX次）。
-- 频道数据
SELECT
  channel_code,
  channel_name,
  sum(like_today_like_count)like_today_like_count
from
  nddc.ads__ri__like_stat__dd__full_v2
where
  period_date between '2024-04-01'
  AND '2024-04-30'
  AND channel_code <> 'ALL'
  AND x_product_id = 'e5649925-441d-4a53-b525-51a2f1c4e0a8'
  group by   channel_code, channel_name
  order by sum(like_today_like_count) desc
  --资源数据
  select a.*,b.content_title,b.channel_code,b.channel_name from (SELECT
  like_object_id, like_object_name,like_channel_code,like_channel_name,sum(like_count)like_count
  from
    nddc.dwm__ri__user_like__dd__incr_v2
  where
    like_created_date between '2024-04-01'
    AND '2024-04-30'
    AND x_product_id = 'e5649925-441d-4a53-b525-51a2f1c4e0a8'
    and like_object_name IS NULL
    group by   like_object_id, like_object_name,like_channel_code,like_channel_name
    order by sum(like_count) desc
    limit 10
    )a  inner join (select * from nddc.dim__talr__channel_content t
  where dt='2024-05-05') b on a.like_object_id=b.robject_id
--本月，平台用户累计收藏资源XXX次，被收藏次数最多的前5条资源是XXXX（XXX次）、XXXX（XXX次）、XXXX（XXX次）、XXXX（XXX次）、XXXX（XXX次），分别来自XXXX、XXXX、XXXX、XXXX、XXXX频道；被收藏次数最多的前3个频道排分别是XXXX（XXX次）、XXXX（XXX次）、XXXX（XXX次）。
--频道数据
SELECT
  channel_code,
  channel_name,
 sum(favorite_today_count) favorite_today_count
from
  nddc.ads__ri__favorite_stat__dd__full_v2
where
  period_date between '2024-04-01'
  AND '2024-04-30'
  AND channel_code <> 'ALL'
  AND province_id = '0'
  AND x_product_id = 'e5649925-441d-4a53-b525-51a2f1c4e0a8'
  group by   channel_code,
  channel_name
  order by  sum(favorite_today_count) desc
--资源
SELECT
   content_robject_id, content_title,content_channel_code,content_channel_name,sum(favorite_total_count)favorite_total_count
  from
    nddc.dwm__ri__favorite_channel__dn__full
  where dt='2024-05-05'
    and favorite_create_date between '2024-04-01'
    AND '2024-04-30'
    AND x_product_id = 'e5649925-441d-4a53-b525-51a2f1c4e0a8'
    group by   content_robject_id, content_title,content_channel_code,content_channel_name
    order by sum(favorite_total_count) desc
    limit 10
--本月，平台用户累计评价资源XXX次，被评价次数最多的前5条资源是XXXX（XXX次）、XXXX（XXX次）、XXXX（XXX次）、XXXX（XXX次）、XXXX（XXX次），分别来自XXXX、XXXX、XXXX、XXXX、XXXX频道；被评价次数最多的前3个频道排分别是XXXX（XXX次）、XXXX（XXX次）、XXXX（XXX次）。本月底，资源评价分数均值为XXX，较上月上升或下降？
--频道数据
SELECT
  channel_code,
  channel_name,
 sum(assessment_today_count) assessment_today_count
from
  nddc.ads__ri__assessment_stat__dd__full_v2
where
 period_date between '2024-04-01'
  AND '2024-04-30'
  AND channel_code <> 'ALL'
  AND province_id = '0'
  AND x_product_id = 'e5649925-441d-4a53-b525-51a2f1c4e0a8'
  group by   channel_code,channel_name
  order by sum(assessment_today_count) desc
  --资源数据
  SELECT
     content_robject_id, content_title,content_channel_code,content_channel_name,sum(assessment_total_count)assessment_total_count
    from
      nddc.dwm__ri__assessment_channel__dn__full
    where dt='2024-05-05'
      and assessment_create_date between '2024-04-01'
      AND '2024-04-30'
      AND x_product_id = 'e5649925-441d-4a53-b525-51a2f1c4e0a8'
      group by   content_robject_id, content_title,content_channel_code,content_channel_name
      order by sum(assessment_total_count) desc
      limit 10
   --平均分
   SELECT
    sum(assessment_today_score)/  sum(assessment_today_count) assessment_today_avg_rate
   from
     nddc.ads__ri__assessment_stat__dd__full_v2
   where
    period_date between '2024-03-01'
     AND '2024-03-31'
     AND channel_code = 'ALL'
     AND province_id = '0'
     AND x_product_id = 'e5649925-441d-4a53-b525-51a2f1c4e0a8'
--2、教学工具使用情况
--1.备课授课【治港】
--平台上线至今，共有XXX名教师使用平台开展备、授课，其中备课工具使用XXX万人次、授课工具使用XXX万人次；XXX人浏览国家中小学平台提供的习题资源，累计查看习题XXX万次、查看习题答案XXX万次；组卷XXX万次。
--本月，有XXX名教师使用平台开展备、授课，其中备课工具使用XXX万人次、授课工具使用XXX万人次，使用量排名居全国前5位的省份是XXX省（XXX次）、XXX省（XXX次）、XXX省（XXX次）；XXX人浏览国家中小学平台提供的习题资源，累计查看习题XXX万次、查看习题答案XXX万次，查看习题次数排名居全国前5位的省份是XXX省（XXX次）、XXX省（XXX次）、XXX省（XXX次）、XXX省（XXX次）、XXX省（XXX次）；组卷XXX万次，组卷工具使用量排名居全国前5位的省份是XXX省（XXX次）、XXX省（XXX次）、XXX省（XXX次）、XXX省（XXX次）、XXX省（XXX次）。
--2.教学活动【高远】
--平台上线至今，教师基于群组发起作业、打卡、学生评价等活动XXXX个，其中，作业XXX个，打卡XXXX个、学生评价XXXX个；转发活动XXXX次，参与教师XXXX多人，参与学生XXXX万人。发起量排名居全国前5位的省份是XXX省（XXX次）、XXX省（XXX次）、XXX省（XXX次）、XXX省（XXX次）、XXX省（XXX次）。
--至今
select 3915716 + 1110107 + 1153528 as activity_num
,6154688 + 2677129 + 129170  as student_num
,407777 + 195904 + 47006 as teacher_num
--月
select 67842 + 15546 + 119552 as activity_num
,555153 + 260409 + 35657  as student_num
,40533 + 23195 + 14459 as teacher_num
--省份
SELECT
province_id,province_name,sum(activity_num) as activity_num
from
  nddc.ads__tal_activity__tal_group_activity_period_stat2__d
where
   period_type_code = '30'
  AND period_code = '202404'
  and province_id != 0
  and area_type = 'province'
  and activity_type in( 'assessment','habit','homework')
  and group_type = '99'
  GROUP BY province_id,province_name
order by
  sum(activity_num) desc
--本月，教师基于群组发起作业、打卡、学生评价等活动XXXX个，其中，作业XXX个，打卡XXXX个、学生评价XXXX个；转发活动XXXX次，参与教师XXXX多人，参与学生XXXX万人。发起量排名居全国前5位的省份是XXX省（XXX次）、XXX省（XXX次）、XXX省（XXX次）、XXX省（XXX次）、XXX省（XXX次）。
--3、支持服务情况【高远】
--本月机审资源XXX条，人工排查机审未通过的申诉XXX条，人工排查处理用户建议XX条，主要集中在XXXX。
--本月处理投诉数XX条，其中有效投诉XXX条，主要集中在XXXX。

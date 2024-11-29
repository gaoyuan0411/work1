--整体评价次数
select province_id,province_name,assessment_total_count
from nddc.ads__ri__assessment_stat__dd__full_v2 t
where dt='${biz_date}'
and city_id=0 and province_id<>0
and channel_code='ALL'
and  x_product_id = 'e5649925-441d-4a53-b525-51a2f1c4e0a8'
order by assessment_total_count

--省、频道评价次数
select * from (
select province_id,province_name,channel_code,channel_name,assessment_total_count,row_number() over(partition by province_id,province_name order by assessment_total_count desc)  rk
from nddc.ads__ri__assessment_stat__dd__full_v2 t
where dt='${biz_date}'
and city_id=0 and province_id<>0
and channel_code!='ALL'
and  x_product_id = 'e5649925-441d-4a53-b525-51a2f1c4e0a8'
) a where a.rk<=5

--省、资源评价
select * from (
select province_id,province_name,channel_code,channel_name,assessment_object_id,assessment_object_name,assessment_total_count,row_number() over(partition by province_id,province_name order by assessment_total_count desc)  rk
from nddc.ads__ri__assessment_object_rank__da__full t
where dt='${biz_date}'
and period_type_code=99
and city_id=0 and province_id<>0
and channel_code!='ALL'
and  x_product_id = 'e5649925-441d-4a53-b525-51a2f1c4e0a8'
) a where a.rk<=5

--整体收藏次数
select province_id,province_name,favorite_total_count
from nddc.ads__ri__favorite_stat__dd__full_v2 t
where dt='${biz_date}'
and city_id=0 and province_id<>0
and channel_code='ALL'
and  x_product_id = 'e5649925-441d-4a53-b525-51a2f1c4e0a8'
order by favorite_total_count

--省、频道收藏次数
select * from (
select province_id,province_name,channel_code,channel_name,favorite_total_count,row_number() over(partition by province_id,province_name order by favorite_total_count desc)  rk
from nddc.ads__ri__favorite_stat__dd__full_v2 t
where dt='${biz_date}'
and city_id=0 and province_id<>0
and channel_code!='ALL'
and  x_product_id = 'e5649925-441d-4a53-b525-51a2f1c4e0a8'
) a where a.rk<=5

--省、资源收藏
select * from (
select province_id,province_name,channel_code,channel_name,favorite_object_id,favorite_object_name,favorite_total_count,row_number() over(partition by province_id,province_name order by favorite_total_count desc)  rk
from nddc.ads__ri__favorite_object_rank__da__full t
where dt='${biz_date}'
and period_type_code=99
and city_id=0 and province_id<>0
and channel_code!='ALL'
and  x_product_id = 'e5649925-441d-4a53-b525-51a2f1c4e0a8'
) a where a.rk<=5

--整体分享次数
select province_id,province_name,resource_share_count
from nddc.ads__ri__share_stat__dd__full t
where dt='${biz_date}'
and city_id=0 and province_id<>0
-- and channel_code='ALL'
and share_method='ALL'
and  x_product_id = 'e5649925-441d-4a53-b525-51a2f1c4e0a8'
order by resource_share_count

--省、频道分享次数
select * from (
select *,row_number() over(partition by province_id,province_name order by share_event_total_count desc)  rk
from (
                 SELECT
                        rul.user_province_id      AS province_id,
                        MAX(rul.user_province_name)            AS province_name,
                        dcc.channel_code,
                        dcc.channel_name,
                        SUM(rul.share_event_total_count)                    AS share_event_total_count

                 FROM nddc.dwm__ri__user_share__dd__full rul
                 left join (    SELECT *
                                FROM (
                                         SELECT *,
                                                ROW_NUMBER() OVER (PARTITION BY dctf.product_id,dctf.channel_code,dctf.robject_id
                                                    ORDER BY dctf.content_valid_status DESC, dctf.content_last_modified_time DESC ) AS rk
                                         FROM nddc.dwd__talr__channel_content_tag_flat__d__full dctf
                                         WHERE  dctf.dt = '${biz_anchor_date}'
                                         AND dctf.site_type = dctf.product_code
                                         AND ((dctf.content_type = 'textbook' AND dctf.channel_code = 'course')
                                             OR dctf.content_type != 'textbook')
                                     ) t1
                                WHERE rk = 1) dcc
                                                       ON rul.share_object_id = dcc.robject_id
                                                       AND rul.x_product_id = dcc.product_id
                 WHERE rul.dt = '${biz_date}'
                 AND  (user_province_id NOT IN(594035816785) OR user_province_id IS NULL)
                 AND (user_province_id NOT IN(594036056566) OR user_province_id IS NULL)
                 and  x_product_id = 'e5649925-441d-4a53-b525-51a2f1c4e0a8'
                 and user_province_id <> -2
                 and share_object_type='resource'
                 GROUP BY   rul.user_province_id,dcc.channel_code,dcc.channel_name
                          )  a where channel_code is not null
                          ) b where rk<=5

--省、资源分享
select * from (
select province_id,province_name,channel_code,channel_name,tag_id_01,tag_name_01,resource_id,resource_id,share_total_count,row_number() over(partition by province_id,province_name order by share_total_count desc)  rk
from nddc.ads__ri__share_object_rank__d__full t
where dt='${biz_date}'
and city_id=0 and province_id<>0
and period_type_code = 99
and channel_code!='ALL'
and share_method='ALL'
and object_type='resource'
and  x_product_id = 'e5649925-441d-4a53-b525-51a2f1c4e0a8'
) a where a.rk<=5

--点赞分省整体
    SELECT
           t1.user_province_id      AS province_id,
           MAX(t1.user_province_name)            AS province_name,
           SUM(t1.like_count)                    AS like_total_like_count

    FROM nddc.dwm__ri__user_like__dd__full_v2 t1
    WHERE t1.dt = '${biz_date}'
    AND  (user_province_id NOT IN(594035816785) OR user_province_id IS NULL)
    AND (user_province_id NOT IN(594036056566) OR user_province_id IS NULL)
    and  x_product_id = 'e5649925-441d-4a53-b525-51a2f1c4e0a8'
    and user_province_id <> -2
    GROUP BY t1.user_province_id

--省、频道点赞次数
select * from (
select *,row_number() over(partition by province_id,province_name order by like_total_like_count desc)  rk
from (
                 SELECT
                        t1.user_province_id      AS province_id,
                        MAX(t1.user_province_name)            AS province_name,
                        like_channel_code as channel_code,
                        like_channel_name as channel_name,
                        SUM(t1.like_count)                    AS like_total_like_count

                 FROM nddc.dwm__ri__user_like__dd__full_v2 t1
                 WHERE t1.dt = '${biz_date}'
                 AND  (user_province_id NOT IN(594035816785) OR user_province_id IS NULL)
                 AND (user_province_id NOT IN(594036056566) OR user_province_id IS NULL)
                 and  x_product_id = 'e5649925-441d-4a53-b525-51a2f1c4e0a8'
                 and user_province_id <> -2
                 GROUP BY   t1.user_province_id,like_channel_code,like_channel_name
                          )  a
                          ) b where rk<=5

 --省、资源点赞
select * from (
select *,row_number() over(partition by province_id,province_name order by like_total_like_count desc)  rk
from (
                 SELECT
                        rul.user_province_id      AS province_id,
                        MAX(rul.user_province_name)            AS province_name,
                        like_channel_code as channel_code,
                        like_channel_name as channel_name,
                                   rul.like_object_id                     AS resource_id,
                                   MAX(COALESCE(dcc.content_title, rul.like_object_name))
                                                                          AS resource_name,
                        SUM(rul.like_count)                    AS like_total_like_count

                 FROM nddc.dwm__ri__user_like__dd__full_v2 rul
                 left join (    SELECT *
                                FROM (
                                         SELECT *,
                                                ROW_NUMBER() OVER (PARTITION BY dctf.product_id,dctf.channel_code,dctf.robject_id
                                                    ORDER BY dctf.content_valid_status DESC, dctf.content_last_modified_time DESC ) AS rk
                                         FROM nddc.dwd__talr__channel_content_tag_flat__d__full dctf
                                         WHERE  dctf.dt = '${biz_anchor_date}'
                                         AND dctf.site_type = dctf.product_code
                                         AND ((dctf.content_type = 'textbook' AND dctf.channel_code = 'course')
                                             OR dctf.content_type != 'textbook')
                                     ) t1
                                WHERE rk = 1) dcc
                                                       ON rul.like_object_id = dcc.robject_id
                                                       AND rul.x_product_id = dcc.product_id
                                                       AND rul.like_channel_code = dcc.channel_code
                 WHERE rul.dt = '${biz_date}'
                 AND  (user_province_id NOT IN(594035816785) OR user_province_id IS NULL)
                 AND (user_province_id NOT IN(594036056566) OR user_province_id IS NULL)
                 and  x_product_id = 'e5649925-441d-4a53-b525-51a2f1c4e0a8'
                 and user_province_id <> -2
                 GROUP BY   rul.user_province_id,like_channel_code,like_channel_name,like_object_id
                          )  a
                          ) b where rk<=5

--省份资源播放
select a.province_id,MAX(b.province_name)province_name,SUM(visit_count) as visit_count
from (
select province_id,MAX(province_name)province_name,SUM(visit_count) visit_count
from nddc.dws__resource__resource_visit_detail__dtd__full t
where dt='${biz_date}'
GROUP by province_id
) a inner join (select area_id as province_id, `name` as province_name from nddc.dim__area where dt='${biz_date}' and area_level=1) b
on a.province_id=b.province_id
GROUP by a.province_id

--省、频道播放
select *
from (
select * ,row_number() over(partition by province_id,province_name order by visit_count desc)  rk
from (
select a.province_id,MAX(b.province_name)province_name,channel_code,MAX(channel_name)channel_name ,SUM(visit_count) as visit_count
from (
select province_id,MAX(province_name)province_name,channel_code,MAX(channel_name)channel_name ,SUM(visit_count) visit_count
from nddc.dws__resource__resource_visit_detail__dtd__full t
where dt='${biz_date}'
and nvl(channel_code,'') <> ''
GROUP by province_id,channel_code
) a inner join (select area_id as province_id, `name` as province_name from nddc.dim__area where dt='${biz_date}' and area_level=1) b
on a.province_id=b.province_id
GROUP by a.province_id,a.channel_code
) c
) d where rk<=5

--省、资源播放
select *
from (
select * ,row_number() over(partition by province_id,province_name order by visit_count desc)  rk
from (
select a.province_id,MAX(b.province_name)province_name,channel_code,MAX(channel_name)channel_name ,resource_id,max(resource_name)resource_name,SUM(visit_count) as visit_count
from (
select province_id,MAX(province_name)province_name,channel_code,resource_id,max(resource_name)resource_name,MAX(channel_name)channel_name ,SUM(visit_count) visit_count
from nddc.dws__resource__resource_visit_detail__dtd__full t
where dt='${biz_date}'
and nvl(channel_code,'') <> ''
GROUP by province_id,channel_code,resource_id
) a inner join (select area_id as province_id, `name` as province_name from nddc.dim__area where dt='${biz_date}' and area_level=1) b
on a.province_id=b.province_id
GROUP by a.province_id,a.channel_code,a.resource_id
) c
) d where rk<=5
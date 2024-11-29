-- SELECT
--   os
--   ,case when os = 'Android' then '安卓'
--        when os = 'Ubuntu' then '乌班图'
--        when os = 'other' then '其他'
--        ELSE os end app_type_name
--   ,sum(if(stat_date = #{stat_date}, uv, 0)) as uv
--   ,sum(if(stat_date != #{stat_date}, uv, 0)) as yesterday_uv
--   ,max(if(stat_date = #{stat_date}, rank_num, 0)) as rank
--   ,max(if(stat_date != #{stat_date}, rank_num, 0)) as yesterday_rank
-- FROM (
--   SELECT
--     stat_date
--     ,os
--     ,uv
--     ,IF(@stat_date = s.stat_date,
--         @rank_counter := @rank_counter + 1,
--         @rank_counter := 1) temp1
--     ,IF(@stat_date = s.stat_date,
--         IF(@uv = s.uv, @cur_rank, @cur_rank := @rank_counter), @cur_rank := 1) as rank_num
--     ,@uv := s.uv temp2
--     ,@stat_date := s.stat_date temp3
--   FROM (
--     SELECT
--       stat_date
--       ,if(os = '空字符串（预置）', 'other', os) os
--       ,sum(uv) uv
--     FROM ads__platform_os_stat_data__dh__incr
--     WHERE site_type = #{site_type}
--       AND app_type IN ('app','app_hd','web-all','pc')
--       AND stat_date in (#{stat_date}, date_add(#{stat_date}, interval -1 day))
--     GROUP BY stat_date,if(os = '空字符串（预置）', 'other', os)
--   ) s, (SELECT @cur_rank := 0, @stat_date := NULL, @uv := NULL, @rank_counter := 1)r
--   ORDER BY stat_date, uv DESC
-- ) t
-- GROUP BY os
-- HAVING uv > 0
-- order by rank
-- <if test="limit == null or limit == '' or limit &lt; 1">
-- limit 10
-- </if>
-- <if test="limit != null and limit != '' and limit &gt; 0">
-- limit #{limit}
-- </if>
SELECT platform as os
    ,case when platform = 'Android' then '安卓'
              when platform = 'Ubuntu' then '乌班图'
              when platform = 'Unknown' then '其他'
              ELSE platform end app_type_name
         ,sum(if(stat_date = #{stat_date}, uv, 0)) as uv
         ,sum(if(stat_date != #{stat_date}, uv, 0)) as yesterday_uv
         ,max(if(stat_date = #{stat_date}, rank_num, 0)) as rank
         ,max(if(stat_date != #{stat_date}, rank_num, 0)) as yesterday_rank
from (
         SELECT *, RANK() OVER (PARTITION BY stat_date ORDER BY uv DESC) as rank_num
         FROM (
                  SELECT stat_date, ifnull(platform,'Unknown') as platform, COUNT(DISTINCT user_id) AS uv
                  FROM dwm__pv__event_detail__ih__incr
                  WHERE stat_date IN (#{stat_date}, DATE_ADD(#{stat_date}, INTERVAL -1 DAY))
                    AND product_code = #{site_type}
                  GROUP BY stat_date, platform
              ) a
     ) b
GROUP BY  platform
HAVING uv > 0
order by rank
<if test="limit == null or limit == '' or limit &lt; 1">
limit 10
</if>
<if test="limit != null and limit != '' and limit &gt; 0">
limit #{limit}
</if>
;
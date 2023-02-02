--1、投诉工单卡新建派发：
select count(*) from inf_complaints_msg g where g.state='10I' --and g.create_date > sysdate-5 ;


select b.order_code, a.orderstate, c.*
  from om_eoms_order a, om_order b, inf_complaints_msg c
 where a.orderstate = '新建派发'
   and b.id = c.order_id
   and a.id = b.id
   and b.id in (select g.order_id
                  from inf_complaints_msg g
                 where g.state = '10E'
                   and g.create_date > sysdate - 1);


select * from om_order a where a.id='128590934'

--2、一点支撑卡单：
select count(1) ufmi from ydzc_pro.uos_flow_msg c where c.state = '10I';

--3、各环节卡单截图：


  select utd.tache_name,count(*)
  from om_order i, wo_work_order y
  left join uos_tache_define utd on y.tache_define_id=utd.id 
  left join wo_work_order_state wwos on y.work_order_state=wwos.work_order_state
  --left join Om_Service_Order oso on i.order_code=oso.crm_so_id
 where i.id = y.base_order_id 
   and y.create_date >= to_date('2022-7-05 00:00:00','YYYY-MM-DD HH24:MI:SS')
   and y.create_date < sysdate - 1/480
   and (select max(wwo.id ) from wo_work_order wwo where wwo.base_order_id = y.base_order_id) = y.id    
   and y.work_order_state in ('10D','10F') --工单环节是已派发的和已完成的
   and i.order_state not in ('10F','10C')--订单状态是正常
   and y.finish_date is null
   --and utd.tache_name in('RADIUS施工' ,'RMS施工' ,'PON网管施工' ,'资源配置')
   --and (utd.tache_name ='RADIUS施工' or utd.tache_name ='RMS施工' or utd.tache_name ='PON网管施工' or utd.tache_name ='资源配置')
   --and utd.tache_name ='LOID配置 '
      --and utd.tache_name ='LOID配置 '
  -- and utd.tache_name ='BOSS归档'
   --and utd.tache_name ='资源配置'
     --and utd.tache_name ='资源归档'
   --and utd.tache_name ='RADIUS施工'
   --and utd.tache_name ='RMS施工'
   --and utd.tache_name ='外线施工' 
   --and utd.tache_name ='PON网管施工' 
   --and utd.tache_name like '%资源%'--'资源配置'--'PON网管施工'--'RADIUS施工'--'RMS施工'
   --and i.order_title like '%改速率%'
  -- and i.order_code like '%-%'
  -- and i.order_code not like '%GX-%'
   --and y.work_order_type='10C' --判断是拆单类型的
  group by  utd.tache_name
  order by count(*) desc;
  
  
   
--4、数据库负荷，需要截图出来：
--http://10.188.38.219:8810/grafana/d/1ee82mJWk/oracleshu-ju-ku-xi-tong-zhi-biao-jian-kong?orgId=1&refresh=1m

--5、锁表：
       select 'blocker(' || lb.sid || ':' || sb.username || ')-sql:' ||
       qb.sql_text blockers,
       'waiter (' || lw.sid || ':' || sw.username || ')-sql:' ||
       qw.sql_text waiters
  from v$lock lb, v$lock lw, v$session sb, v$session sw, v$sql qb, v$sql qw
 where lb.sid = sb.sid
   and lw.sid = sw.sid
   and sb.prev_sql_addr = qb.address
   and sw.sql_address = qw.address
   and lb.id1 = lw.id1
   and sw.lockwait is not null
   and sb.lockwait is null
   and lb.block = 1;
   
--6、卡入库数量：
   select pm.name, count(pm.name)
     from inf_boss_sheet g, om_service_order b, om_order c, pm_service pm
    where g.sserialnumber = b.bss_sserialnumber
      and b.id = c.id
      and c.service_id = pm.id
      and g.create_date >
          to_date('2022-06-29 23:00:00', 'YYYY-MM-DD HH24:MI:SS')
    group by pm.name;
    
    
    --查询入库量
    select a.servicetype, count(a.servicetype)
      from inf_boss_sheet a
     where a.create_date between
           to_date('2022-06-29 23:00:00', 'YYYY-MM-DD HH24:MI:SS')
           and to_date('2022-07-01 05:00:00','YYYY-MM-DD HH24:MI:SS')  
           group by a.servicetype;
    
    
    
    select to_char(a.create_date,'YYYY-MM-DD HH24:MI'), count(1)
      from inf_boss_sheet a
     where a.create_date >
           to_date('2022-06-24 16:00:00', 'YYYY-MM-DD HH24:MI:SS')
           and a.state='10I'
     group by to_char(a.create_date,'YYYY-MM-DD HH24:MI') 
     order by to_char(a.create_date,'YYYY-MM-DD HH24:MI') desc
   
    
    
    select count(1) from inf_boss_sheet a where a.state='10I' and a.create_date>to_date('2022-06-24 10:00:00','YYYY-MM-DD HH24:MI:SS');  
    
   
   --资源配置
select count(*) from inf_res_msg a,om_service_order b  where a.order_id=b.id and state='10I' and a.msg_type='202';


SELECT  replace(STANDARD_ADDRESS_EIGHT ,'|','')  FROM OM_SERVICE_ORDER WHERE ID =119731462

select 'STA' as PARTY_TYPE,uc.staff_id as PARTY_ID,us.staff_name as PARTY_NAME
  from uos_staff_with_zy_community uc
  join uos_staff us on us.staff_id=uc.staff_id
 where EXISTS
       (select 1
          From zy_community_info z
         where z.community_id=uc.community_id and
         z.grid_id =(select zci.grid_id
  from uos_staff_with_zy_community uswzc
  join zy_community_info zci on zci.community_id=uswzc.community_id
 where uswzc.community_all_name = '广西贵港覃塘区覃塘镇北街北街民房' ))
 and us.state = 1 and us.delete_state = 0
 group by uc.staff_id,us.staff_name







   select * from  inf_boss_sheet  g where g.create_date>to_date('2022-03-19 10:00:00','YYYY-MM-DD HH24:MI:SS') 
   
   
   
   
   
   
   
   -- 上线后第二天每小时数据
 
call UpJobNumber_old(trunc(to_date('2022-06-28 07:00:00','YYYY-MM-DD HH24:MI:SS') ,'HH24'),trunc(to_date('2022-06-28 08:00:00','YYYY-MM-DD HH24:MI:SS') ,'HH24'));

call UpJobNumber(trunc(to_date('2022-06-28 07:00:00','YYYY-MM-DD HH24:MI:SS') ,'HH24'),trunc(to_date('2022-06-28 08:00:00','YYYY-MM-DD HH24:MI:SS') ,'HH24'));



select a.*, rowid
  from tmp_up_huizong a
 where a.时间 > '2022-03-24 00'
   and a.时间 < '2022-03-24 20'
 order by a.时间, a.排序;
 
 
select a.*, rowid
  from tmp_up_huizong a
 where a.时间 > '2022-03-25 07'
   and a.时间 < '2022-03-25 20'
 order by a.时间, a.排序;
   
   
   --长脚本查询（执行时间超过30分钟）
select b.SQL_TEXT,
       s.MACHINE,
       s.CLIENT_INFO,
       s.username,
       round(s.last_call_et / 60) times,
       'alter system kill session ''' || s.sid || ',' || s.serial# ||
       ''' immediate;' si,
       s.sql_id      
  from v$session s, v$sql b
 where s.SQL_ID = b.SQL_ID
   and status = 'ACTIVE'
   and type <> 'BACKGROUND'
   and last_call_et > 60*30
   and s.USERNAME <> 'SYS'
   --and b.SQL_TEXT like 'SELECT%'
   and s.CLIENT_INFO not in ('10.188.38.59')
 order by times desc;
   
--改速率
 select COUNT(1) from inf_boss_sheet a where a.state='10I' and a.create_date>=to_date('2022-7-22','yyyy-mm-dd') AND A.SERVICETYPE='1011'
   
   
   
    

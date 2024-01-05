select om.order_code as orderCode,               --��������
       om.order_title as orderTitle,             --��������
       om.bss_sserialnumber as bossOrderId,      --boss������
       om.user_area_name as userAreaName,        --����
       om.new_access_type as accessType,         --���뷽ʽ
       om.acc_nbr as accNbr,                     --�������
       /*decode(om.user_name,
              'null',
              null,
              'null',
              null,
              translate(om.user_name,
                        substr(om.user_name, 2, length(om.user_name) - 1),
                        '**'))*/
     om.user_name as userName,        --�û�����
       --decode(om.service_lv,'high','��Ʒ��','��ͨ') as userLv,          --�û��ȼ�
       --decode(om.town_flag,'03','ũ��','����') as townFlag,             --��������
       om.COVER_TYPE as townFlag,             --��������
       om.new_standard_address as address,      --�豸��׼��ַ
       om.user_addr as userAddr,                --�û���װ��ַ
       om.exch_comp as exchComp,                --��ά��˾
       om.exch_name as exchNaame,               --��άפ��
       om.rate,                                 --�������
       om.new_offer_name as newOfferName,       --�ײ���Ϣ
       om.accept_date as acceptDate,            --boss����ʱ��
       ooki.accept_staff_name acceptStaffName,  --������Ա����ϵ�绰
       nvl(oor.state_date,om.create_date) orderCreateDate,          --boss�ɵ�ʱ��
       nvl(oor.state_date,om.wo_create_date) as createDate,         --���߽ӵ�ʱ��
       om.wo_finish_date as finishDate,         --���߻ص�ʱ��
       om.finish_date as orderFinishDate,       --boss�鵵ʱ��
       oss.appoint_time as bespDate,  --ǰ̨ԤԼʱ��
       om.first_book_oper_date as bookOperDate,       --ԤԼ����ʱ��
       om.book_begin_date as bookDate,          --ԤԼ����ʱ��
       om.book_staff_name as bookStaffName,     --ԤԼ������
       om.party_name as partyName,              --ʩ����Ա
       om.org_name as orgName,                  --ʩ�������ڰ���
       om.exch_comp as staffExchComp,           --ʩ�������ڴ�ά��˾
       om.mobile_tel as mobileTel,              --ʩ������ϵ�绰
       decode(om.construct_type,'0','���','1','����',null) as comstructType,      --ʩ����ʽ
       om.sn,                                   --��èsn��

       case
         when nvl(nvl(oor.suspend_times,om.suspend_times), 0) > 0 then
          '��'
         else
          '��'
       end as isSuspend,                              --�Ƿ����

       case when oor.order_id is not null then oor.suspend_times else om.suspend_times end as suspendTimes, --�������

       case when oor.order_id is not null then (to_char(round(oor.suspend_minutes/60,2),'fm9999990.0099')) else (to_char(round(om.suspend_minutes/60,2),'fm9999990.0099')) end  as suspendMinutes,  --������ʱ��

       case when oor.order_id is not null then oor.suspend_date else om.suspend_date end as suspendDate,   --������ʱ��

       case when oor.order_id is not null then oor.unsuspend_date else  om.unsuspend_date end as unsuspendDate,            --�����ʱ��

       case when oor.order_id is not null then oor.suspend_staff else om.suspend_staff end as suspendStaff,              --������

       case when oor.order_id is not null then oor.suspend_reason else u.return_reason_name end as suspendReason,         --����ԭ��

       case when oor.order_id is not null then oor.suspend_comment else om.app_comment end as suspendComment,              --����ע

        case when om.timeout_reason_id is null then 'δ��ʱ' else '��ʱ' end as overtimeFlag,                        --�Ƿ�ʱ

       case when oor.order_id is not null then ( to_char(round((om.WO_FINISH_DATE - oor.state_date)*24,2),'FM9999990.00')) else (to_char(round((om.WO_FINISH_DATE - om.CREATE_DATE)*24,2),'FM9999990.00'))  end  as usedTime,

       case when oor.order_id is not null then ( to_char(round((om.WO_FINISH_DATE - oor.state_date)*24,2) - round(nvl(oor.suspend_minutes,0)/60,2),'fm9999990.0099') ) else
       (to_char(round((om.WO_FINISH_DATE - om.CREATE_DATE)*24,2) - round(nvl(om.suspend_minutes,0)/60,2),'fm9999990.0099')) end as usedTimeNS,


       om.work_result as workResult,                --�ص���ע
       om.comments,                                 --����ע
       wopr.pic_num as picNum,
       --om.order_jt_request_finish_date,
       om.is_telepro,
       om.village,
       om.STAR_LEVEL,
       om.gird,
       nvl(substr(om.new_standard_address,
               instr(om.new_standard_address, '|', 1, 2) + 1,
               instr(om.new_standard_address, '|', 1, 3) - 1 -
               instr(om.new_standard_address, '|', 1, 2)),'����') as county,
       om.common_order_product,
       om.common_order_code,
       (select ta.community_id from uos_staff_with_zy_community ta where ta.community_all_name = om.community_name and rownum =1) as community_id,
        om.community_name as community_name,
       (select us.username from uos_staff us where us.staff_id = (select wwo.party_id from wo_work_order wwo where wwo.tache_define_id in(select id from uos_tache_define where tache_name like '%����ʩ��%')  and wwo.base_order_id = om.order_id and rownum = 1  ) and rownum = 1) as user_name,
     decode(oso.issameinstall, '0', '��', '1', '��', null) as is_same_install,
     decode(ota.ACTIVATE_RESULT, '0', '��', '1', '��', null) as terminalActivate, --add by huang.qiangyi 2021-05-07
   ota.CMEI as cmei, --add by huang.qiangyi 2021-05-07
       (case when oso.account4afoross is not null then '��'
       else '��' end )as account4afoross,
       (select attach_name from res_attache_rela where id = om.attach) attach,
       (select company_name from company_type_rela where company_id = om.eqp_company and company_type = 2) eqp_company,
       (select company_name from company_type_rela where company_id = om.olt_company and company_type = 3) olt_company,
       (select a.reason_catalog_name from uos_reason_catalog a where a.id = urr.reason_catalog_id) as firstTimeoutReason,
       urr.return_reason_name as secondTimeoutReason
     , (SELECT ogco.group_order_code from om_group_construct_order ogco, om_group_construct_order_rela ogcor WHERE ogco.id = ogcor.group_order_id and ogcor.order_id=om.order_id) as workCode
     ,om.RECOVER_FLAG
   --,decode(osor.is_giga_bit_vip,'Y',  '��', '��') as isGigaBitVip
     ,om.customer_Urge as customerUrge
          ,     osor.user_quality

  from om_order_finish_wid om
  left join om_service_order oso on om.order_id=oso.id
  left join om_order_key_info ooki on om.order_id = ooki.id
  left join om_so_sla oss on oss.service_order_id = om.order_id --����ǰ̨ʱ���
  left join uos_return_reason u on u.id = om.sla_ext_value4
  left join uos_return_reason urr on urr.id = om.timeout_reason_id
  left join (select order_id,count(1) pic_num from work_order_pic_rec group by order_id) wopr on om.order_id = wopr.order_id
  left join om_order_reback_install oor on om.order_id = oor.order_id and oor.state = '10F'
  left join OM_TERMINAL_ACTIVATE ota on ota.order_id=om.order_id  --add by huang.qiangyi 20210507
  left join om_so_order_rela osor on osor.service_order_id = om.order_id
  where om.service_id in (220413,1250632,1260632,220402)
  and om.order_state = '10F'
  and om.finish_date between  to_date('2023-01-05 00:00:00','yyyy-mm-dd hh24:mi:ss') and  to_date('2023-01-05 23:59:59','yyyy-mm-dd hh24:mi:ss')
   order by user_area_name,orderFinishDate desc

--����������� �ź����ȥ Ȼ��ִ������Ľű�
SELECT a.*,rowid FROM zl a;
--ִ�нű�
begin
  for i in (select oo.id
              from om_order oo, om_service_order oso
             where oo.id = oso.id
               and oo.order_state not in ('10C', '10F', 'C')
               and oso.acc_nbr in (select a.acc_nbr from zl a)) loop
    insert into om_check_quality_appeal o
      (o.appeal_id,
       o.order_id,
       o.appeal_state,
       o.appeal_comment,
       o.appeal_staff_id,
       o.deal_result,
       o.deal_comment,
       o.create_date,
       o.deal_time,
       o.deal_staff_id)
    values
      (om_check_quality_appeal_seq.nextval,
       i.id,
       '10F',
       '������������޷���⣬Ҫ��IOM���Ұ�����',
       '1',
       '1',
       'IOM���Һ�̨��æ����',
       sysdate,
       sysdate,
       '1');
    commit;
  end loop;
end;

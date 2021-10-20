drop table if exists dq_emails_sent;
create table dq_emails_sent as
select email_id, sent_str sent, sent_str wip from emails
   where sent is null and sent_str is not null and trim(sent_str) != '';
alter table dq_emails_sent add sent_ttz timestamp with time zone;
alter table dq_emails_sent add primary key (email_id);
update dq_emails_sent set sent_ttz = try_cast_timestamp(sent);
--
alter table dq_emails_sent add clean boolean;
update dq_emails_sent
  set clean = case when sent_ttz is not null then true
                                             else false
               end;
--
-- eliminate space before or after colon
update dq_emails_sent
    set wip = regexp_replace(wip, ' :', ':', 'g')
    where sent_ttz is null;
update dq_emails_sent
   set wip = regexp_replace(wip, ': ', ':', 'g')
       where sent_ttz is null;
update dq_emails_sent set sent_ttz = try_cast_timestamp(wip)
    where sent_ttz is null;
update dq_emails_sent
   set wip = regexp_replace(wip, ':([0-9]) ', ':\1', 'g')
   where sent_ttz is null;
update dq_emails_sent set sent_ttz = try_cast_timestamp(wip)
   where sent_ttz is null;
-- fix dates
update dq_emails_sent
   set wip = regexp_replace(wip, 'Mo n,', 'Mon,')
   where sent_ttz is null;
update dq_emails_sent
   set wip = regexp_replace(wip, 'Mon ,', 'Mon,')
   where sent_ttz is null;
update dq_emails_sent set sent_ttz = try_cast_timestamp(wip)
   where sent_ttz is null;
--
-- fix months
update dq_emails_sent
    set wip = regexp_replace(wip, ' Ap r', ' Apr')
    where sent_ttz is null;
update dq_emails_sent set sent_ttz = try_cast_timestamp(wip)
      where sent_ttz is null;


-- remove junk at end
update dq_emails_sent
   set wip = regexp_replace(wip, ' (\+0000|AM|PM).*', ' \1')
   where sent_ttz is null;
update dq_emails_sent set sent_ttz = try_cast_timestamp(wip)
         where sent_ttz is null;
---
update dq_emails_sent set sent_ttz = try_cast_timestamp(substr(wip, 5))
   where sent_ttz is null;
---
-- check date range
--    watch out for TODAY, look to substitute
update emails e
    set sent = (select sent_ttz from dq_emails_sent dq
                    where dq.email_id = e.email_id)
    where exists (select 1 from dq_emails_sent dq
                     where dq.email_id = e.email_id and
                           dq.sent_ttz is not null);

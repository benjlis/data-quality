create table dq_emails_sent as
select email_id, sent, sent wip from emails
   where sent is not null;
alter table dq_emails_sent add sent_ttz timestamp with time zone;
update dq_emails_sent set sent_ttz = try_cast_timestamp(sent);
--
alter table dq_emails_sent add clean boolean;
update dq_emails_sent add
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
update dq_emails_sent
    set wip = regexp_replace(wip, ' 2020([0-9])', ' 2020 \1')
    where sent_ttz is null;
update dq_emails_sent set sent_ttz = try_cast_timestamp(wip)
      where sent_ttz is null;
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

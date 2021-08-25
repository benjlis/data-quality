create table dq_emails_from_email as
select email_id, from_email, from_email normal from emails;
-- remove [E] which appears is often misread
update dq_emails_from_email set normal = regexp_replace(normal, ' \[E.', '', 'g');
-- remove actual emails that were not redacted
update dq_emails_from_email set normal = regexp_replace(normal, '<.*>', '');
update dq_emails_from_email set normal = regexp_replace(normal, '""', '', 'g');
--
-- levenshtein
update dq_emails_from_email set normal = 'Fauci, Anthony (NIH/NIAID)'
   where levenshtein_less_equal('Fauci, Anthony (NIH/NIAID)', normal, 6) < 6;
update dq_emails_from_email set normal = '(b)(6)'
   where levenshtein_less_equal('(b)(6)', normal, 3) < 3;

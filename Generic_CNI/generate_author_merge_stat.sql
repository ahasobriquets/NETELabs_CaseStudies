



with
sid_per_full_name as (select full_name, count(auth_sid) as sid_count_per_FullName from alemtuzumab_author_pir_rrbr_final group by full_name ),
sid_per_last_first_inital as ( select last_first_initial, count(auth_sid) as sid_count_per_lastNameFirst_inital from alemtuzumab_author_pir_rrbr_final group by last_first_initial),
lastname_first_initial_per_full_name as ( select last_first_initial, count(full_name) as full_name_count_per_lastNameFirst_inital from alemtuzumab_author_pir_rrbr_final group by last_first_initial)
select a.auth_sid,b.full_name,c.last_first_initial,b.sid_count_per_FullName,c.sid_count_per_lastNameFirst_inital,d.full_name_count_per_lastNameFirst_inital, a.doc_count_test as pub_count_in_network, a.doc_count_total as pub_count_total, a.auth_pir
from alemtuzumab_author_pir_rrbr_final a
inner join sid_per_full_name  b on  a.full_name=b.full_name
inner join sid_per_last_first_inital c on  a.last_first_initial = c.last_first_initial
inner join lastname_first_initial_per_full_name d on a.last_first_initial=d.last_first_initial;

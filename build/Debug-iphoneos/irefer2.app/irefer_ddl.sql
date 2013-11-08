create table if not exists t_users ( user_id integer primary key, last_name text, first_name text, email text, act_code text, my_prac_id integer, my_hos_id integer, my_county_id integer, need_to_sync integer, update_setting integer, last_sync_time text, last_admin_sync_time text);
create table if not exists t_practice ( prac_id integer primary key, name text, address text);
create table if not exists t_hospital ( hos_id integer primary key, name text, address text);
create table if not exists t_insurance ( ins_id integer primary key, name text, address text);
create table if not exists t_county ( county_id integer primary key, name text, code text, state_code text);
create table if not exists t_speciality ( spec_id integer primary key, name text, spec_type integer);
create table if not exists t_doctor ( doc_id integer, last_name text, first_name text, mid_name text, degree text, doc_phone text, language text, grade integer, gender text, image_url text, zip_code text, res_flag integer, see_patient integer, doc_fax text, npi text, office_hour text, u_rank integer, up_rank integer, prac_id integer, hos_id integer, spec_id integer, ins_id integer, county_id integer, rank_update integer, quality integer, cost integer, rank_user_number integer, avg_rank numeric);
create table if not exists t_doc_report ( doc_id integer primary key, user_id integer, description text, report_time text, submit_time text);
create table if not exists t_statistics ( count_type integer, count integer);
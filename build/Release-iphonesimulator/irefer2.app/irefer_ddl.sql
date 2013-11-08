create table if not exists t_users ( user_id integer primary key, last_name text, first_name text, email text, act_code text, my_prac_id integer, my_hos_id integer, my_county_id integer, need_to_sync integer, update_setting integer);
create table if not exists t_practice ( prac_id integer primary key, name text, address text);
create table if not exists t_hospital ( hos_id integer primary key, name text, address text);
create table if not exists t_insurance ( ins_id integer primary key, name text, address text);
create table if not exists t_county ( county_id integer primary key, name text, code text);
create table if not exists t_speciality ( spec_id integer primary key, name text, address text, spec_type integer);
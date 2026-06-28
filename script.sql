create database pa4;

DROP TABLE IF EXISTS users CASCADE;
DROP TABLE IF EXISTS accounts CASCADE;
DROP TABLE IF EXISTS account_presence CASCADE;
DROP TABLE IF EXISTS contacts CASCADE;
DROP TABLE IF EXISTS chat_members CASCADE;
DROP TABLE IF EXISTS messages CASCADE;

create table if not exists users(
    user_id int generated always as identity primary key,
    first_name varchar not null,
    last_name varchar not null,
    age int,
    email varchar not null,
    phone varchar not null
);
create table if not exists accounts(
    account_id int generated always as identity primary key,
    user_id int not null REFERENCES users(user_id) ON DELETE CASCADE,
    nickname varchar not null,
    description varchar not null,
    status varchar default 'active'
);
create table if not exists account_presence(
    account_id int not null primary key REFERENCES accounts(account_id) ON DELETE CASCADE,
    is_online boolean default false
);
create table if not exists contacts(
    account_id int not null REFERENCES accounts(account_id) ON DELETE CASCADE,
    contact_id int not null REFERENCES accounts(account_id) ON DELETE CASCADE,
    primary key(account_id, contact_id)
);
create table if not exists chats(
    chat_id int generated always as identity primary key,
    chat_name varchar not null,
    created_at timestamp default current_timestamp
);
create table if not exists chat_members(
    member_id int not null REFERENCES accounts(account_id) ON DELETE CASCADE,
    chat_id int not null REFERENCES chats(chat_id) ON DELETE CASCADE,
    primary key(member_id, chat_id)
);
create table if not exists messages(
    message_id int generated always as identity primary key,
    sender_id int not null REFERENCES accounts(account_id) ON DELETE CASCADE,
    chat_id int not null REFERENCES chats(chat_id) ON DELETE CASCADE,
    content varchar not null,
    sent_time timestamp default current_timestamp
);
create table if not exists user_log(
	log_id int generated always as identity primary key,
    user_id int not null REFERENCES users(user_id) ON DELETE CASCADE,
    action varchar,
    log_date timestamp default current_timestamp
);
    
    
--функція для trigger, що записує логи при створенні нового user
create or replace function log_user_created()
returns trigger
language plpgsql
as $$
begin
	--вставляємо новий запис в user_log
	--використовуємо new, тому що це tigger для insert
	insert into user_log(user_id, action, log_date)
	values(new.user_id, new.account_id, 'created user', current_timestamp);
	return new;
end;	
$$;
--сам trigger
create trigger log_user_created
--срацбовує після insert
after insert on users
for each row
execute function log_user_created();


--процедура для створення чату з заданими користувачами
--приймає назву чату і список користувачів 
create or replace procedure create_chat(p_chat_name varchar, p_members_id int[])
language plpgsql
as $$
declare
	v_chat_id int;
	v_member_id int;
begin
	insert into chats(chat_name) values (p_chat_name)
	returning chat_id into v_chat_id;
	
	--проходимось по всім заданим користувачам і додаємо їх до цчасників чату
	foreach v_member_id in array p_members_id
	loop
		insert into chat_members(member_id, chat_id) 
		values(v_member_id, v_chat_id);
	end loop;

end;
$$;



create or replace view chats_info as(
with chat_general_info as(select c.chat_id, c.chat_name, count( m.member_id) as members_total, 
	count( m.member_id) filter (where ap.is_online = true) as members_online
from chats as c join chat_members as m 
on c.chat_id = m.chat_id
left join account_presence as ap
on ap.account_id = m.member_id
group by c.chat_id, c.chat_name),
chat_messages_total as(
select chat_id, count(message_id) as messages_total
from messages
group by chat_id)
select  i.chat_id, i.chat_name, i.members_total, i.members_online, coalesce(m.messages_total,0) as messages_total
from chat_general_info as i
left join chat_messages_total m on i.chat_id = m.chat_id);




drop INDEX IF EXISTS idx_user_id;
drop INDEX IF EXISTS idx_account_id;
drop INDEX IF EXISTS idx_account_id_presence;
drop INDEX IF EXISTS idx_account_is_online;
drop INDEX IF EXISTS idx_account_id_contact_id_contacts;
drop INDEX IF EXISTS idx_members_chat_id;
drop INDEX IF exists idx_chat_name_id;
drop INDEX IF EXISTS idx_message_іd_chat_id;

CREATE INDEX IF NOT EXISTS idx_user_id ON users(user_id);
CREATE INDEX IF NOT EXISTS idx_account_id ON accounts(account_id);
CREATE INDEX IF NOT EXISTS idx_account_id_presence ON account_presence(account_id);
CREATE INDEX IF NOT EXISTS idx_account_id_is_online ON account_presence(account_id, is_online);
CREATE INDEX IF NOT EXISTS idx_account_id_contact_id_contacts ON contacts(account_id, contact_id);
CREATE INDEX IF NOT EXISTS idx_members_chat_id ON chat_members(chat_id);
CREATE INDEX IF NOT EXISTS idx_chat_name_id ON chats(chat_id, chat_name);
CREATE INDEX IF NOT EXISTS idx_message_іd_chat_id on messages(chat_id);



--запит покаже інформацію про чат з id = 500
set enable_seqscan = on;
set enable_indexscan = off;
explain analyze
select * from chats_info where chat_id = 500;

--перевірка,чи змінився час
set enable_seqscan = off;
set enable_indexscan = on ;
explain analyze
select * from chats_info where chat_id = 500;
	

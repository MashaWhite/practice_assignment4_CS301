# practice_assignment4_CS301
database for messenger

schema consists of such tables:
-users;
-accounts;
-account_presence - is online or nor;
-contacts;
-chats;
-chat_members;
-messages;
-user_log;

1:1 connections:
users:accounts
accounts:accounts_presence

1:many connections:
accounts:contacts (1 person has many contacts)
accounts:messages (1 person sends many messeges)
chats:messages (1 chat has many messages)

many:many connections:
chats:chat_members (1 chat has many members and 1 person can be member of several chats)






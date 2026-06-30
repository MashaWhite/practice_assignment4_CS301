# practice_assignment4_CS301

database for messenger

schema consists of such tables:
- users;
- accounts;
- account_presence - is online or nor;
- contacts;
- chats;
- chat_members;
- messages;
- user_log;


1:1 connections:
- accounts:accounts_presence

1:many connections:
- users:accounts (1 user can have many accounts)
- users:user_logs (1 user has many logs)
- accounts:contacts (1 person has many contacts)
- accounts:messages (1 person sends many messeges)
- chats:messages (1 chat has many messages)

many:many connections:
- chats:chat_members (1 chat has many members and 1 person can be member of several chats)

created: 
- view chat_info to show chat information, such as id, name, total number of members, number of members online, number of messages
- trigger to write logs, whenever user is created
- procedure to create chat with given accounts
- testing to show everything works properly
- 3 roles with different permissions

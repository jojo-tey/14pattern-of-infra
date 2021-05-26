# 14 Patterns of Infrastructure

- [Event site](#Event-site)
- [Buisness site](#Buisness-site)



## Event site

#### Things to consider

- It will be used only for a month
- User will be access via Internet
- It might be not many users, which means no need a high-performance server
- LAMP(Linux, Apache, PHP, MySQL) environment
- First consider is cost-effective, so no need multiplexing or backup

#### Design

![Image](/images/eventsite.png)

1. Choose Region
2. Set up EC2 instance
3. Connect through domain
4. Network setting
5. OS setting as web server


## Buisness site

#### Things to consider

- This is a public website, and users are customers and job applicants
- It is mainly static content
- Prepare for failure by multiplexing servers
- Configure the server so that it can be added when the load is high
- Manual operation of replacement and addition of faulty servers
- Consideration of response time and cost


#### Design

![Image](/images/buisnesssite.png)

1. Web server multiplexing
2. DB server multiplexing
3. Transferring static content using CDN and object storage


# 14 Patterns of Infrastructure

- [Event site](#Event-site)



### Event site

- It will be used only for a month
- User will be access via Internet
- It might be not many users, which means no need a high-performance server
- LAMP(Linux, Apache, PHP, MySQL) environment
- First consider is cost-effective, so no need multiplexing or backup

#### Design

![Image](../images/eventsite.png)

1. Choose Region
2. Set up EC2 instance
3. Connect through domain
4. Network setting
5. OS setting as web server



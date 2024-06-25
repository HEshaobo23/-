# 登录和打卡接口

本项目实现了登录和打卡功能的接口。

## 主要功能

### 登录接口

`login`方法实现了用户登录功能,主要流程如下:

1. 获取系统配置信息
2. 发送登录请求获取token 
3. 构造登录数据并计算签名
4. 发送登录请求
5. 解析登录响应结果
6. 缓存用户ID
7. 处理登录失败情况

### 打卡接口  

`punchCard`方法实现了用户打卡功能,主要流程如下:

1. 获取系统字典配置
2. 调用登录接口获取token
3. 构造打卡数据并计算签名  
4. 发送打卡请求
5. 解析打卡响应结果
6. 处理各种打卡结果(成功/失败/已打卡等)
7. 记录打卡日志

## 注意事项

- 本代码仅供学习研究使用,不得用于非法用途
- 使用本代码产生的任何后果由使用者自行承担

## 版权声明

本项目代码版权归作者所有,未经授权不得用于商业用途。
本项目已有完整前端后端，批量自动化打卡系统功能。u盾绕过访问登录网页等功能。需要商用请联系作者微信：en88888886 QQ：869544850 手机号：17620940271
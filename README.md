# 中大小教务 (SYSUJwxt-iOS)（已废弃）
第三方中山大学教务系统 iOS 客户端

## 说明
**该项目已废弃，不适用于目前版本的教务系统，欢迎 Fork 和 Fix**

## **以下内容已过时**

### 功能

这个 App 可以让你在手机上直接查成绩、课表、学分、绩点，另外还加入了**导出课表到系统日历**📆、**成绩更新提醒**🎊等功能。

### 原理与安全

`JwxtApiClient.swift` 直连学校官方教务系统的接口并解析回应数据，不经任何服务器中转。

密码只会保存在手机本地 KeyChain 🔐。

成绩更新提醒利用的是 Background Fetch 接口。（测试中）

所以这个 App 就**和你直接访问学校官方教务系统的安全性一样**。（除了登录以外都没有用 HTTPS）

我（开发者）是没有办法看到你的 NetID 或密码的🙈。

### TODO
- 成绩更新提醒测试
- 课程／成绩详情
- 学分完成情况
- 更多……

## 开源许可

本项目（图标除外）采用 三句版BSD 许可证，详见 [LICENSE](https://github.com/benwwchen/sysujwxt-ios/blob/master/LICENSE) 文件内容。

但希望你不要直接把这个库的源代码编译后上传到 App Store。

## 致谢
- 访问官方教务系统的 API 部分参考了 [sysu-jwxt-api](https://github.com/luosch/sysu-jwxt-api)，感谢 [luosch](https://github.com/luosch)。
- 本项目受到 [InSYSU](http://insysu.com/) / [微教务](http://wjw.sysu.edu.cn/) 的启发，感谢该项目的开发者们。
- 感谢 [gracece](https://github.com/gracece) 师兄提供了一个分项成绩的 API。
- 使用了 [Kanna](https://github.com/tid-kijyun/Kanna)，一个 Swift 语言的 XML/HTML 解析库，感谢 [tid-kijyun](https://github.com/tid-kijyun)。

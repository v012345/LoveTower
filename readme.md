xxxConfig 就是对象
xxxConfigData 就是生成对象用的数据

Window.lua 里管理 窗口 与 Room 的相关配置

Render 相关的设置在 render.csv 里, 对它 GameCfg 去拿到


如何才能把 Node 与 App 解耦啊

现在这个架构很奇怪
需要先启动 App, 然后再启动引擎


## 事件系统说明
Event 在初始化里, 在 config 里指明 trigger 

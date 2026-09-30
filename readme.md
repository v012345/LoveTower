1. 先实现窗口的可变化




xxxConfig 就是对象
xxxConfigData 就是生成对象用的数据

Window.lua 里管理 窗口 与 Room 的相关配置

Render 相关的设置在 render.csv 里, 对它 GameCfg 去拿到


如何才能把 Node 与 App 解耦啊

现在这个架构很奇怪
需要先启动 App, 然后再启动引擎
因为引擎里 Node , Event , Timer 全都依赖 App


## 事件系统说明
Event 在初始化里, 在 config 里指明 trigger



## 推荐的类名

| 中文 | 推荐类名 | 主要职责 |
| --- | --- | --- |
| 同步器 | Synchronizer | 同步数据或状态 |
| 初始化器 | Initializer | 初始化对象或系统 |
| 生成器 | Generator | 生成对象或数据 |
| 更新器 | Updater | 更新数据或状态 |
| 处理器 | Processor | 执行数据处理逻辑 |
| 控制器 | Controller | 控制对象的行为 |
| 管理器 | Manager | 管理多个对象或资源 |
| 调度器 | Scheduler | 安排任务执行顺序 |
| 分发器 | Dispatcher | 分发事件或任务 |
| 构建器 | Builder | 分步骤构建复杂对象 |
| 验证器 | Validator | 验证数据或状态 |
| 解析器 | Parser | 解析数据 |
| 执行器 | Executor | 执行指定任务 |

## app
全局变量 , 唯一单例 , 

## game
游戏代码逻辑

## ui
ui 代码

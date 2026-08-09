# Love2D Debugger for Cursor

在 Cursor 中调试 Love2D（LuaJIT）游戏。

## 功能

- 断点（运行中增删实时生效）
- 单步：step over (F10) / step into (F11) / step out (Shift+F11)
- 暂停 / 继续
- 调用栈、局部变量、upvalue，table 逐层展开
- 运行时错误自动断在出错行，并显示错误信息
- 游戏 print 输出实时显示在调试控制台（自动关闭 stdout 缓冲）

## 使用方式

1. 在游戏 `main.lua` 顶部加入调试器注入代码：

```lua
local debugger_path = os.getenv("LOVE_DEBUGGER")
if debugger_path then
    local f = assert(io.open(debugger_path, "r"))
    local src = f:read("*a")
    f:close()
    assert(loadstring(src, "@debugger.lua"))()
end
```

2. 在 `.vscode/launch.json` 中添加配置：

```json
{
    "type": "love2d",
    "request": "launch",
    "name": "Debug Love2D",
    "projectRoot": "${workspaceFolder}",
    "lovePath": "lovec"
}
```

3. 按 F5 启动调试。

## launch.json 配置项

| 字段 | 说明 | 默认值 |
| --- | --- | --- |
| `projectRoot` | Love2D 项目目录（包含 main.lua） | `${workspaceFolder}` |
| `lovePath` | love/lovec 可执行文件路径 | `lovec` |
| `args` | 传给游戏的额外命令行参数 | `[]` |
| `port` | 调试器 TCP 端口 | `56789` |
| `stopOnEntry` | 启动后立即暂停 | `false` |

## 注意事项

- 调试时自动执行 `jit.off()`（JIT 编译的代码不触发 line hook），游戏帧率会明显下降，属正常现象
- 命中断点暂停时游戏窗口会失去响应（主线程被挂起），这是预期行为
- 只调试主线程，`love.thread` 创建的线程不受影响也无法断点

## 实现原理

- 插件端（TypeScript）实现 Debug Adapter Protocol，启动 `lovec` 并监听 TCP 端口
- 游戏端 `lua/debugger.lua` 通过 `LOVE_DEBUGGER` 环境变量注入，用 `debug.sethook` 监听行事件，命中断点时阻塞主线程，通过 luasocket 与插件端交换 JSON 消息
- 运行时错误通过包装 `love.errorhandler` 捕获（错误处理器执行时栈尚未展开）

## 开发

```
npm install
npm run compile        # 或 npm run watch
npm run package        # 打包 .vsix
node test/harness.js       # 端到端测试：断点/变量/单步（需要上级目录是 love 项目）
node test/harness-error.js # 端到端测试：错误断住/表展开
```

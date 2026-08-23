conf.lua  LÖVE 第一个读取的文件

love.load() —— 启动时跑一次，初始化用
love.update(dt) —— 每帧跑，dt 是距上一帧的秒数，所有运动逻辑放这
love.draw() —— 每帧跑，只负责画画
如果显式写了 love.run
那么就是
run:
love.load()
while 1 then
love.update(dt) 
love.draw()
end


当前版本是 11.5 , love2D 还不原生支持 https 请求
可以自己 编译[https://love2d.org/wiki/lua-https?__cf_chl_f_tk=8xHxIuPeULV6VHiP47TyfpkqTMQSWsAHfN_m7JKmoHs-1783162388-1.0.1.1-ogCHzu4FJwWjwbVpMsdMEMjJMbjhfyi7DOAEJe9cK2g]

目前还有去研究 love2D 和 https 的源码编译

https.dll 是直接从 小丑牌 里拿来的

2026-08-23 08:11

分析 controller.lua
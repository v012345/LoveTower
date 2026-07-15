require "bit"

---@enum RoleType
RoleType = {
    Minor = 1, -- 主角色
    Major = 2, -- 子角色
    Glued = 3, -- 粘连角色
}

---@enum BondType
BondType = {
    Strong = 1, -- 强绑定
    Weak = 2,   -- 弱绑定
}

local b_1 = bit.lshift(1, 0)
local b_2 = bit.lshift(1, 1)
local b_3 = bit.lshift(1, 2)
local b_4 = bit.lshift(1, 3)
local b_5 = bit.lshift(1, 4)
local b_6 = bit.lshift(1, 5)
local b_7 = bit.lshift(1, 6)
local b_8 = bit.lshift(1, 7)
---@enum AlignmentType
AlignmentType = {
    none = 0,
    a    = b_1,                    -- 无对齐，使用原始角色偏移
    m    = b_2,                    -- 水平居中 offset.x = 0.5 * major.w - mid.w/2
    c    = b_3,                    -- 垂直居中 offset.y = 0.5 * major.h - mid.h/2
    b    = b_4,                    -- 底部对齐 内部: offset.x = major.w - self.w，外部: offset.x = major.w
    t    = b_5,                    -- 顶部对齐 内部: offset.y = 0，外部: offset.y = -self.h
    l    = b_6,                    -- 左对齐 默认，或内部: offset.x = 0，外部: offset.x = -self.w
    r    = b_7,                    -- 右对齐 内部: offset.x = major.w - self.w，外部: offset.x = major.w
    i    = b_8,                    -- 当非中心对齐时, 是不是在对齐对象的内部
    cm   = bit.bor(b_2, b_3),      --水平和垂直都居中（centered middle）
    tmi  = bit.bor(b_5, b_2, b_8), --顶部 + 水平居中 + 内侧（top middle inner）
    bmi  = bit.bor(b_4, b_2, b_8), --底部 + 水平居中 + 内侧
    cli  = bit.bor(b_3, b_6, b_8), --垂直居中 + 左侧 + 内侧
    tri  = bit.bor(b_5, b_7, b_8), --顶部 + 右侧 + 内侧
    bm   = bit.bor(b_4, b_2),      --底部 + 水平居中（外侧，在 major 下方）
    tm   = bit.bor(b_5, b_2),      --顶部 + 水平居中（外侧，在 major 上方
}

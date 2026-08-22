local id = 0

---生成唯一ID
---@return number
function generate_id()
    id = id + 1
    return id
end

---创建节点状态
---@return NodeStates
function create_node_states()
    return {
        visible = true,
        collide = { can = false, is = false },
        focus = { can = false, is = false },
        hover = { can = true, is = false },
        click = { can = true, is = false },
        drag = { can = true, is = false },
        release_on = { can = true, is = false }
    }
end

---创建帧计数器
---@return FrameCounter
function create_frame_counter()
    return { draw = -1, move = -1 }
end

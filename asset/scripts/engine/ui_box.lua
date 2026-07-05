---@class UIBox: Moveable
---@field UIRoot UIElement
UIBox = Moveable:extend()

--The base level and container of a graph of 1 or more UIElements. These UIEs are\
--essentially a node based UI implementation. As the root node of the graph, this\
--node is the first called for any movement, updates, or changes to ensure that all child\
--nodes are updated and modified in the correct order.\\
--The UI_definitions file houses the majority of the definition tables needed for UIBox initialization.
--
---@param args {T: table, definition: table, config: table}
--**T** A standard transform in game units describing the inital position and size of the object with x, y, w, h\
--ex - {x = 1, y = 5, w = 2, h = 2, r = 0}
--
--**definition** A table containing a valid UIBox definition. These are mostly generated from UI_definitions
--
--**config** A configuration table for the UIBox
--ex - { align = 'cm', offset = {x = 1, y = 1}, parent_rect = A, attach_rect = B, can_collide = true }
function UIBox:init(args)
    --First initialize the moveable
    Moveable.init(self, { args.T })

    --Initialization of fields
    self.states.drag.can = false
    self.draw_layers = {} --if we need to explicitly change the draw order of the UIEs

    --The definition table that contains the schematic of this UIBox
    self.definition = args.definition

    if args.config then
        self.config = args.config
        args.config.major = args.config.major or args.config.parent or self

        self:set_alignment({
            major = args.config.major,
            type = args.config.align or args.config.type or '',
            bond = args.config.bond or 'Strong',
            offset = args.config.offset or { x = 0, y = 0 },
            lr_clamp = args.config.lr_clamp
        })
        self:set_role {
            xy_bond = args.config.xy_bond,
            r_bond = args.config.r_bond,
            wh_bond = args.config.wh_bond or 'Weak',
            scale_bond = args.config.scale_bond or 'Weak'
        }
        self.states.collide.can = true

        if args.config.can_collide == nil then
            self.states.collide.can = true
        else
            self.states.collide.can = args.config.can_collide
        end

        self.parent = self.config.parent
    end

    --inherit the layered_parallax from the parent if there is any
    --self.layered_parallax = self.role.major and self.role.major.layered_parallax or self.layered_parallax

    --Initialization of the UIBox from the definition
    --First, set parent-child relationships to create the tree structure of the box

    self:set_parent_child(self.definition, nil)
    --Set the midpoint for any future alignments to use
    self.Mid = self.Mid or self.UIRoot
    --Calculate the correct and width/height and offset for each node
    self:calculate_xywh(self.UIRoot, self.T)

    --set the transform w/h to equal that of the calculated box
    self.T.w = self.UIRoot.T.w
    self.T.h = self.UIRoot.T.h
    --Then, calculate the correct width and height for each container
    self.UIRoot:set_wh()
    --Then, set all of the correct alignments for the ui elements\

    self.UIRoot:set_alignments()

    self:align_to_major()
    self.VT.x, self.VT.y = self.T.x, self.T.y
    self.VT.w, self.VT.h = self.T.w, self.T.h

    if self.Mid ~= self and self.Mid.parent and false then
        self.VT.x = self.VT.x - self.Mid.role.offset.x + (self.Mid.parent.config.padding or 0)
        self.VT.y = self.VT.y - self.Mid.role.offset.y + (self.Mid.parent.config.padding or 0)
    end

    if self.alignment and self.alignment.lr_clamp then
        self:lr_clamp()
    end

    self.UIRoot:initialize_VT(true)
    if getmetatable(self) == UIBox then
        if args.config.instance_type then
            table.insert(G.I[args.config.instance_type], self)
        else
            table.insert(G.I.UIBOX, self)
        end
    end
end

function UIBox:get_UIE_by_ID(id, node)
    if not node then node = self.UIRoot end
    if node.config and node.config.id == id then return node end
    for k, v in pairs(node.children) do
        local res = self:get_UIE_by_ID(id, v)
        if res then
            return res
        elseif v.config.object and v.config.object.get_UIE_by_ID then
            res = v.config.object:get_UIE_by_ID(id, nil)
            if res then
                return res
            end
        end
    end
    return nil
end

function UIBox:calculate_xywh(node, _T, recalculate, _scale)
    do return end
    node.ARGS.xywh_node_trans = node.ARGS.xywh_node_trans or {}
    local _nt = node.ARGS.xywh_node_trans
    local _ct = {}

    _ct.x, _ct.y, _ct.w, _ct.h = 0, 0, 0, 0

    local padding = node.config.padding or Enum.UI.padding
    --current node does not contain anything
    if node.UIT == Enum.UI.B or node.UIT == Enum.UI.T or node.UIT == Enum.UI.O then
        _nt.x, _nt.y, _nt.w, _nt.h =
            _T.x,
            _T.y,
            node.config.w or (node.config.object and node.config.object.T.w),
            node.config.h or (node.config.object and node.config.object.T.h)

        if node.UIT == Enum.UI.T then
            node.config.text_drawable = nil
            local scale = node.config.scale or 1
            if node.config.ref_table and node.config.ref_value then
                node.config.text = tostring(node.config.ref_table[node.config.ref_value])
                if node.config.func and not recalculate then App.instance.FUNCS[node.config.func](node) end
            end
            if not node.config.text then node.config.text = '[UI ERROR]' end
            node.config.lang = node.config.lang or App.instance.LANG
            local tx = node.config.lang.font.FONT:getWidth(node.config.text) * node.config.lang.font.squish * scale *
                App.instance.TILESCALE * node.config.lang.font.FONTSCALE
            local ty = node.config.lang.font.FONT:getHeight() * scale * App.instance.TILESCALE *
                node.config.lang.font.FONTSCALE *
                node.config.lang.font.TEXT_HEIGHT_SCALE
            if node.config.vert then
                local thunk = tx; tx = ty; ty = thunk
            end
            _nt.x, _nt.y, _nt.w, _nt.h =
                _T.x,
                _T.y,
                tx / (App.instance.TILESIZE * App.instance.TILESCALE),
                ty / (App.instance.TILESIZE * App.instance.TILESCALE)

            node.content_dimensions = node.content_dimensions or {}
            node.content_dimensions.w = _T.w
            node.content_dimensions.h = _T.h
            node:set_values(_nt, recalculate)
        elseif node.UIT == Enum.UI.B or node.UIT == Enum.UI.O then
            node.content_dimensions = node.content_dimensions or {}
            node.content_dimensions.w = _nt.w
            node.content_dimensions.h = _nt.h
            node:set_values(_nt, recalculate)
        end
        return _nt.w, _nt.h
    else --For all other node containers, treat them explicitly like a column
        for i = 1, 2 do
            if i == 1 or (i == 2 and ((node.config.maxw and _ct.w > node.config.maxw) or (node.config.maxh and _ct.h > node.config.maxh))) then
                local fac = _scale or 1
                if i == 2 then
                    local restriction = node.config.maxw or node.config.maxh
                    fac = fac * restriction / (node.config.maxw and _ct.w or _ct.h)
                end
                _nt.x, _nt.y, _nt.w, _nt.h =
                    _T.x,
                    _T.y,
                    node.config.minw or 0,
                    node.config.minh or 0

                if node.UIT == Enum.UI.ROOT then
                    _nt.x, _nt.y, _nt.w, _nt.h = 0, 0, node.config.minw or 0, node.config.minh or 0
                end
                _ct.x, _ct.y, _ct.w, _ct.h = _nt.x + padding, _nt.y + padding, 0, 0
                local _tw, _th
                for k, v in ipairs(node.children) do
                    if getmetatable(v) == UIElement then
                        if v.config and v.config.scale then v.config.scale = v.config.scale * fac end
                        _tw, _th = self:calculate_xywh(v, _ct, recalculate, fac)
                        if _th and _tw then
                            if v.UIT == Enum.UI.R then
                                _ct.h = _ct.h + _th + padding
                                _ct.y = _ct.y + _th + padding
                                if _tw + padding > _ct.w then _ct.w = _tw + padding end
                                if v.config and v.config.emboss then
                                    _ct.h = _ct.h + v.config.emboss
                                    _ct.y = _ct.y + v.config.emboss
                                end
                            else
                                _ct.w = _ct.w + _tw + padding
                                _ct.x = _ct.x + _tw + padding
                                if _th + padding > _ct.h then _ct.h = _th + padding end
                                if v.config and v.config.emboss then
                                    _ct.h = _ct.h + v.config.emboss
                                end
                            end
                        end
                    end
                end
            end
        end

        node.content_dimensions = node.content_dimensions or {}
        node.content_dimensions.w = _ct.w + padding
        node.content_dimensions.h = _ct.h + padding
        _nt.w = math.max(_ct.w + padding, _nt.w)
        _nt.h = math.max(_ct.h + padding, _nt.h) --
        node:set_values(_nt, recalculate)
        return _nt.w, _nt.h
    end
end

function UIBox:remove_group(node, group)
    node = node or self.UIRoot
    for k, v in pairs(node.children) do
        if self:remove_group(v, group) then node.children[k] = nil end
    end
    if node.config and node.config.group and node.config.group == group then
        node:remove(); return true
    end

    if not node.parent or true then
        self:calculate_xywh(self.UIRoot, self.T, true); self.UIRoot:set_wh(); self.UIRoot:set_alignment()
    end --self:recalculate() end
end

function UIBox:get_group(node, group, ingroup)
    node = node or self.UIRoot
    ingroup = ingroup or {}
    for k, v in pairs(node.children) do
        self:get_group(v, group, ingroup)
    end
    if node.config and node.config.group and node.config.group == group then
        table.insert(ingroup, node); return ingroup
    end
    return ingroup
end

function UIBox:set_parent_child(node, parent)
    local UIE = UIElement(parent, self, node.n, node.config)

    --set the group of the element
    if parent and parent.config and parent.config.group then
        if UIE.config then
            UIE.config.group = parent.config.group
        else
            UIE.config = {
                group =
                    parent.config.group
            }
        end
    end

    --set the button for the element
    if parent and parent.config and parent.config.button then
        if UIE.config then
            UIE.config.button_UIE = parent
        else
            UIE.config = {
                button_UIE =
                    parent
            }
        end
    end
    if parent and parent.config and parent.config.button_UIE then
        if UIE.config then
            UIE.config.button_UIE = parent
                .config.button_UIE
        else
            UIE.config = { button = parent.config.button }
        end
    end

    if node.n and node.n == Enum.UI.O and UIE.config.button then
        UIE.config.object.states.click.can = false
    end

    --current node is a container
    if (node.n and node.n == Enum.UI.C or node.n == Enum.UI.R or node.n == Enum.UI.ROOT) and node.nodes then
        for k, v in pairs(node.nodes) do
            self:set_parent_child(v, UIE)
        end
    end

    if not parent then
        self.UIRoot = UIE
        self.UIRoot.parent = self
    else
        table.insert(parent.children, UIE)
    end
    if node.config and node.config.mid then
        self.Mid = UIE
    end
end

function UIBox:remove()
    if self == App.instance.OVERLAY_MENU then App.instance.REFRESH_ALERTS = true end
    self.UIRoot:remove()
    for k, v in pairs(G.I[self.config.instance_type or 'UIBOX']) do
        if v == self then
            table.remove(G.I[self.config.instance_type or 'UIBOX'], k)
            break;
        end
    end
    remove_all(self.children)
    Moveable.remove(self)
end

function UIBox:draw()
    if self.FRAME.DRAW >= App.instance.FRAMES.DRAW and not App.instance.OVERLAY_TUTORIAL then return end
    self.FRAME.DRAW = App.instance.FRAMES.DRAW

    for k, v in pairs(self.children) do
        if k ~= 'h_popup' and k ~= 'alert' then v:draw() end
    end

    if self.states.visible then
        add_to_drawhash(self)
        self.UIRoot:draw_self()
        self.UIRoot:draw_children()
        for k, v in ipairs(self.draw_layers) do
            if v.draw_self then v:draw_self() else v:draw() end
            if v.draw_children then v:draw_children() end
        end
    end

    if self.children.alert then self.children.alert:draw() end

    self:draw_boundingrect()
end

function UIBox:recalculate()
    --Calculate the correct dimensions and width/height and offset for each node
    self:calculate_xywh(self.UIRoot, self.T, true)
    --Then, calculate the correct width and height for each container
    self.UIRoot:set_wh()
    --Then, set all of the correct alignments for the ui elements
    self.UIRoot:set_alignments()
    self.T.w = self.UIRoot.T.w
    self.T.h = self.UIRoot.T.h
    G.REFRESH_FRAME_MAJOR_CACHE = (G.REFRESH_FRAME_MAJOR_CACHE or 0) + 1
    self.UIRoot:initialize_VT()
    G.REFRESH_FRAME_MAJOR_CACHE = (G.REFRESH_FRAME_MAJOR_CACHE > 1 and G.REFRESH_FRAME_MAJOR_CACHE - 1 or nil)
end

function UIBox:move(dt)
    Moveable.move(self, dt)
    Moveable.move(self.UIRoot, dt)
end

function UIBox:drag(offset)
    Moveable.drag(self, offset)
    Moveable.move(self.UIRoot, dt)
end

function UIBox:add_child(node, parent)
    self:set_parent_child(node, parent)
    self:recalculate()
end

function UIBox:set_container(container)
    self.UIRoot:set_container(container)
    Node.set_container(self, container)
end

function UIBox:print_topology(indent)
    local box_str = '| UIBox | - ID:' .. self.ID .. ' w/h:' .. self.T.w .. '/' .. self.T.h
    local indent = indent or 0
    box_str = box_str .. self.UIRoot:print_topology(indent)
    return box_str
end

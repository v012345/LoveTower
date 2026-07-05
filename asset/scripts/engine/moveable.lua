---@class Moveable: Node
Moveable = Node:extend()

--Moveable represents any game object that has the ability to move about the gamespace.\
--All Moveables have a T (transform) that describes their desired transform in game units, as\
--well as a VT (Visible Transform) that eases to T over time. This allows for simplified movement where\
--we only need to set T.x, T.y, etc. to their final position and the engine will ensure the Moveable\
--VT eases to that final location, regargless of any events or timing.
--
---@param args {T: table, container: Node}
--**T** The transform ititializer, with keys of x|1, y|2, w|3, h|4, r|5\
--**container** optional container for this Node, defaults to G.ROOM
function Moveable:init(X, Y, W, H)
    local args = (type(X) == 'table') and X or { T = { X or 0, Y or 0, W or 0, H or 0 } }
    Node.init(self, args)

    --The Visible transform is initally set to the same values as the transform T.
    --Note that the VT has an extra 'scale' factor, this is used to manipulate the center-adjusted
    --scale of any objects that need to be drawn larger or smaller
    self.VT = {
        x = self.T.x,
        y = self.T.y,
        w = self.T.w,
        h = self.T.h,
        r = self.T.r,
        scale = self.T.scale
    }

    --To determine location of VT, we need to keep track of the velocity of VT as it approaches T for the next frame
    self.velocity = { x = 0, y = 0, r = 0, scale = 0, mag = 0 }

    --For more robust drawing, attaching, movement and fewer redundant movement calculations, Moveables each have a 'role'
    --that describes a heirarchy of move() calls. Any Moveables with 'Major' role type behave normally, essentially recalculating their
    --VT every frame to ensure smooth movement. Moveables can be set to 'Minor' role and attached to some 'Major' moveable
    --to weld the Minor moveable to the Major moveable. This makes the dependent moveable set their T and VT to be equal to
    --the corresponding 'Major' T and VT, plus some defined offset.
    --For finer control over what parts of T and VT are inherited, xy_bond, wh_bond, and r_bond can be set to one of
    --'Strong' or 'Weak'. Strong simply copies the values, Weak allows the 'Minor' moveable to calculate their own.
    self.role = {
        role_type = 'Major',       --Major dictates movement, Minor is welded to some major
        offset = { x = 0, y = 0 }, --Offset from Minor to Major
        major = nil,
        draw_major = self,
        xy_bond = 'Strong',
        wh_bond = 'Strong',
        r_bond = 'Strong',
        scale_bond = 'Strong'
    }

    self.alignment = {
        type = 'a',
        offset = { x = 0, y = 0 },
        prev_type = '',
        prev_offset = { x = 0, y = 0 },
    }

    --the pinch table is used to modify the VT.w and VT.h compared to T.w and T.h. If either x or y pinch is
    --set to true, the VT width and or height will ease to 0. If pinch is false, they ease to T.w or T.h
    self.pinch = { x = false, y = false }

    --Keep track of the last time this Moveable was moved via :move(dt). When it is successfully moved, set to equal
    --the current G.TIMERS.REAL, and if it is called again this frame, doesn't recalculate move(dt)
    self.last_moved = -1
    self.last_aligned = -1

    self.static_rotation = false

    self.offset = { x = 0, y = 0 }
    self.Mid = self

    self.shadow_parrallax = { x = 0, y = -1.5 }
    self.layered_parallax = { x = 0, y = 0 }
    self.shadow_height = 0.2

    self:calculate_parrallax()

    table.insert(App.instance.MOVEABLES, self)
    if getmetatable(self) == Moveable then
        table.insert(App.instance.I.MOVEABLE, self)
    end
end

function Moveable:calculate_parrallax()
    if not App.instance.ROOM then return end
    self.shadow_parrallax.x = (self.T.x + self.T.w / 2 - App.instance.ROOM.T.w / 2) / (App.instance.ROOM.T.w / 2) * 1.5
end

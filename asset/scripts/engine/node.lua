---@class Node
Node = Object:extend()

---Node represent any game object that needs to have some transform available in the game itself.\
---Everything that you see in the game is a Node, and some invisible things like the G.ROOM are also\
---represented here.
---
--**T** The transform ititializer, with keys of x|1, y|2, w|3, h|4, r|5\
--**container** optional container for this Node, defaults to G.ROOM
---@param args {T: table, container: Node}
function Node:init(args)
    --From args, set the values of self transform
    args = args or {}
    args.T = args.T or {}

    --Store all argument and return tables here for reuse, because Lua likes to generate garbage
    self.ARGS = self.ARGS or {}
    self.RETS = {}

    --Config table used for any metadata about this node
    self.config = self.config or {}

    --For transform init, accept params in the form x|1, y|2, w|3, h|4, r|5
    self.T = {
        x = args.T.x or args.T[1] or 0,
        y = args.T.y or args.T[2] or 0,
        w = args.T.w or args.T[3] or 1,
        h = args.T.h or args.T[4] or 1,
        r = args.T.r or args.T[5] or 0,
        scale = args.T.scale or args.T[6] or 1,
    }
    --Transform to use for collision detection
    self.CT = self.T

    --Create the offset tables, used to determine things like drag offset and 3d shader effects
    self.click_offset = { x = 0, y = 0 }
    self.hover_offset = { x = 0, y = 0 }

    --To keep track of all nodes created on pause. If true, this node moves normally even when the G.TIMERS.TOTAL doesn't increment
    -- self.created_on_pause = G.SETTINGS.paused

    --ID tracker, every Node has a unique ID
    self.ID = App.instance:generate_id()

    --Frame tracker to aid in not doing too many extra calculations
    self.FRAME = {
        DRAW = -1,
        MOVE = -1
    }

    --The states for this Node and all derived nodes. This is how we control the visibility and interactibility of any object
    --All nodes do not collide by default. This reduces the size of n for the O(n^2) collision detection
    self.states = {
        visible = true,
        collide = { can = false, is = false },
        focus = { can = false, is = false },
        hover = { can = true, is = false },
        click = { can = true, is = false },
        drag = { can = true, is = false },
        release_on = { can = true, is = false }
    }

    --If we provide a container, all nodes within that container are translated with that container as the reference frame.
    --For example, if G.ROOM is set at x = 5 and y = 5, and we create a new game object at 0, 0, it will actually be drawn at
    --5, 5. This allows us to control things like screen shake, room positioning, rotation, padding, etc. without needing to modify
    --every game object that we need to draw
    -- self.container = args.container or G.ROOM

    --The list of children give Node a treelike structure. This can be used for things like drawing, deterministice movement and parallax
    --calculations when child nodes rely on updated information from parents, and inherited attributes like button click functions
    if not self.children then
        self.children = {}
    end

    --Add this object to the appropriate instance table only if the metatable matches with NODE
    -- if getmetatable(self) == Node then
    --     table.insert(G.I.NODE, self)
    -- end

    -- --Unless node was created during a stage transition (when G.STAGE_OBJECT_INTERRUPT is true), add all nodes to their appropriate
    -- --stage object table so they can be easily deleted on stage transition
    -- if not G.STAGE_OBJECT_INTERRUPT then
    --     table.insert(G.STAGE_OBJECTS[G.STAGE], self)
    -- end
end

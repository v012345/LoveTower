Font = Object:extend()

---注册字体
function Font:init()
    self.FONTS = {
        [1] = {
            file = "asset/resources/fonts/m6x11plus.ttf",
            render_scale = Tile.instance.TILESIZE * 10,
            TEXT_HEIGHT_SCALE = 0.83,
            TEXT_OFFSET = {
                x = 10,
                y = -20
            },
            FONTSCALE = 0.1,
            squish = 1,
            DESCSCALE = 1
        },
        [2] = {
            file = "asset/resources/fonts/NotoSansSC-Bold.ttf",
            render_scale = Tile.instance.TILESIZE * 7,
            TEXT_HEIGHT_SCALE = 0.7,
            TEXT_OFFSET = {
                x = 0,
                y = -35
            },
            FONTSCALE = 0.12,
            squish = 1,
            DESCSCALE = 1.1
        },
        [3] = {
            file = "asset/resources/fonts/NotoSansTC-Bold.ttf",
            render_scale = Tile.instance.TILESIZE * 7,
            TEXT_HEIGHT_SCALE = 0.7,
            TEXT_OFFSET = {
                x = 0,
                y = -35
            },
            FONTSCALE = 0.12,
            squish = 1,
            DESCSCALE = 1.1
        },
        [4] = {
            file = "asset/resources/fonts/NotoSansKR-Bold.ttf",
            render_scale = Tile.instance.TILESIZE * 7,
            TEXT_HEIGHT_SCALE = 0.8,
            TEXT_OFFSET = {
                x = 0,
                y = -20
            },
            FONTSCALE = 0.12,
            squish = 1,
            DESCSCALE = 1
        },
        [5] = {
            file = "asset/resources/fonts/NotoSansJP-Bold.ttf",
            render_scale = Tile.instance.TILESIZE * 7,
            TEXT_HEIGHT_SCALE = 0.8,
            TEXT_OFFSET = {
                x = 0,
                y = -20
            },
            FONTSCALE = 0.12,
            squish = 1,
            DESCSCALE = 1
        },
        [6] = {
            file = "asset/resources/fonts/NotoSans-Bold.ttf",
            render_scale = Tile.instance.TILESIZE * 7,
            TEXT_HEIGHT_SCALE = 0.65,
            TEXT_OFFSET = {
                x = 0,
                y = -40
            },
            FONTSCALE = 0.12,
            squish = 1,
            DESCSCALE = 1
        },
        [7] = {
            file = "asset/resources/fonts/m6x11plus.ttf",
            render_scale = Tile.instance.TILESIZE * 10,
            TEXT_HEIGHT_SCALE = 0.9,
            TEXT_OFFSET = {
                x = 10,
                y = 15
            },
            FONTSCALE = 0.1,
            squish = 1,
            DESCSCALE = 1
        },
        [8] = {
            file = "asset/resources/fonts/GoNotoCurrent-Bold.ttf",
            render_scale = Tile.instance.TILESIZE * 10,
            TEXT_HEIGHT_SCALE = 0.8,
            TEXT_OFFSET = {
                x = 10,
                y = -20
            },
            FONTSCALE = 0.1,
            squish = 1,
            DESCSCALE = 1
        },
        [9] = {
            file = "asset/resources/fonts/GoNotoCJKCore.ttf",
            render_scale = Tile.instance.TILESIZE * 10,
            TEXT_HEIGHT_SCALE = 0.8,
            TEXT_OFFSET = {
                x = 10,
                y = -20
            },
            FONTSCALE = 0.1,
            squish = 1,
            DESCSCALE = 1
        }
    }
    for _, v in ipairs(self.FONTS) do
        if love.filesystem.getInfo(v.file) then
            v.FONT = love.graphics.newFont(v.file, v.render_scale)
        end
    end
    for _, v in pairs(Language.instance.LANGUAGES) do
        v.font = self.FONTS[v.font_id]
    end
end

Font.instances = Font()

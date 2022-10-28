LevelUpMenuState = Class{__includes = BaseState}

--[[
    levelUpStats is a table of stats that each have a
        name: string,
        base: number,
        increase: number
    onClose is a callback function called after this LevelUpMenu is closed
]]
function LevelUpMenuState:init(levelUpStats, onClose)
    local statItems = {}
    for i, stat in pairs(levelUpStats) do
        table.insert(statItems, {
            text = stat.name .. ': '  .. stat.base .. ' + ' .. stat.increase .. ' = ' .. tostring(stat.base + stat.increase)
        })
    end
    self.levelUpMenu = Menu {
        x = VIRTUAL_WIDTH - 96,
        y = VIRTUAL_HEIGHT - 96,
        width = 96,
        height = 96,
        isReadOnly = true,
        items = statItems
    }
    self.onClose = onClose or function() end
end

function LevelUpMenuState:close()
    gStateStack:pop()
    self.onClose()
end

function LevelUpMenuState:update(dt)
    self.levelUpMenu:update(dt)
    if love.keyboard.wasPressed('space') or love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        self:close()
    end
end

function LevelUpMenuState:render()
    love.graphics.setFont(gFonts['small'])
    self.levelUpMenu:render()
end

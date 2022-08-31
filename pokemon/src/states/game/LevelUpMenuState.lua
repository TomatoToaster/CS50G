LevelUpMenuState = Class{__includes = BaseState}

function LevelUpMenuState:init(battleState)
    self.battleState = battleState
    self.levelUpMenu = Menu {
        x = VIRTUAL_WIDTH - 64,
        y = VIRTUAL_HEIGHT - 64,
        width = 64,
        height = 64,
        isReadOnly = true,
        --TODO
        items = {

        }
    }
end

function LevelUpMenuState:update(dt)
    self.battleMenu:update(dt)
end

function LevelUpMenuState:render()
    self.battleMenu:render()
end

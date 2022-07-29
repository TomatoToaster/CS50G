--[[
    GD50
    Legend of Zelda

    Author: All Me
]]

PlayerLiftState = Class{__includes = BaseState}

function PlayerLiftState:init(player, dungeon)
    self.player = player
    self.dungeon = dungeon

    -- render offset for spaced character sprite (negated in render function of state)
    self.player.offsetY = 5
    self.player.offsetX = 0
end

function PlayerLiftState:enter(params)
    self.player.currentAnimation:refresh()

    local direction = self.player.direction
    self.player:changeAnimation('lift-' .. direction)

    if direction == 'left' then
    elseif direction == 'right' then
    elseif direction == 'up' then
    else
    end
end


function PlayerLiftState:update(dt)
    -- if we've fully elapsed through one cycle of animation, change back to idle state
    if self.player.currentAnimation.timesPlayed > 0 then
        self.player.currentAnimation.timesPlayed = 0
        self.player:changeState('idle')
    else
        print(self.player.currentAnimation.currentFrame)
    end
end

function PlayerLiftState:render()
    self.player.currentAnimation:render(self.player.x, self.player.y, self.player.offsetX, self.player.offsetY)
end

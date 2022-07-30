--[[
    GD50
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

PlayerIdleState = Class{__includes = EntityIdleState}

function PlayerIdleState:init(entity)
    EntityIdleState.init(self, entity)
    self.entity:changeAnimation((self.entity.heldItem and 'hold-' or '') .. 'idle-' .. self.entity.direction)
end

function PlayerIdleState:enter(params)

    -- render offset for spaced character sprite (negated in render function of state)
    self.entity.offsetY = 5
    self.entity.offsetX = 0
end

function PlayerIdleState:update(dt)
    if love.keyboard.isDown('left') or love.keyboard.isDown('right') or
       love.keyboard.isDown('up') or love.keyboard.isDown('down') then
        self.entity:changeState('walk')
    end

    if not self.entity.heldItem then
        if love.keyboard.wasPressed('space') then
            self.entity:changeState('swing-sword')
        end

        if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
            self.entity:changeState('lift')
        end
    else
        if love.keyboard.wasPressed('space') then
            self.entity.heldItem:fire(self.entity)
        end
    end
end

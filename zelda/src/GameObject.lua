--[[
    GD50
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

GameObject = Class{}

function GameObject:init(def, x, y)
    -- string identifying this object type
    self.type = def.type

    self.texture = def.texture
    self.frame = def.frame or 1

    -- whether it acts as an obstacle or not
    self.solid = def.solid

    -- whether this object is consumed after colliding with by the player
    self.consumable = def.consumable

    self.defaultState = def.defaultState
    self.state = self.defaultState
    self.states = def.states

    self.projectile = false
    self.destroyed = false

    -- dimensions
    self.x = x
    self.y = y
    self.width = def.width
    self.height = def.height

    -- default speed
    self.dx, self.dy = 0, 0

    -- default empty collision callback
    self.onCollide = function() end
end

function GameObject:fire(player)
    local dx, dy
    if player.direction == 'left' then
        self.dx, self.dy = -POT_FIRE_SPEED, 0
    elseif player.direction == 'right' then
        self.dx, self.dy = POT_FIRE_SPEED, 0
    elseif player.direction == 'up' then
        self.dx, self.dy = 0, -POT_FIRE_SPEED
    else
        self.dx, self.dy = 0, POT_FIRE_SPEED
    end
    player.heldItem = nil
    self.distanceTraveled = 0;
    self.projectile = true

    player:changeState('idle')

    -- lets lower the pot to the player's height when its thrown
    self.y = player.y
end

function GameObject:destroy()
    self.destroyed = true
    self.dx = 0
    self.dy = 0
end

function GameObject:update(dt)
    if self.dx ~= 0 or self.dy ~= 0 then
        self.x = self.x + self.dx * dt
        self.y = self.y + self.dy * dt
        self.distanceTraveled = self.distanceTraveled + math.abs(self.dx * dt) + math.abs(self.dy * dt)

        if self.distanceTraveled >= POT_FIRE_TILE_LIMIT * TILE_SIZE then
            self:destroy()
        end

        local bottomEdge = VIRTUAL_HEIGHT - (VIRTUAL_HEIGHT - MAP_HEIGHT * TILE_SIZE)
            + MAP_RENDER_OFFSET_Y - TILE_SIZE
        if self.x <= MAP_RENDER_OFFSET_X + TILE_SIZE
        or self.x + self.width >= VIRTUAL_WIDTH - TILE_SIZE * 2
        or self.y <= MAP_RENDER_OFFSET_Y + TILE_SIZE - self.height / 2
        or self.y + self.height >= bottomEdge then
            self:destroy()
        end

    end
end

function GameObject:render(adjacentOffsetX, adjacentOffsetY)
    local renderFrame = self.states and self.states[self.state].frame or self.frame
    love.graphics.draw(gTextures[self.texture], gFrames[self.texture][renderFrame],
        self.x + adjacentOffsetX, self.y + adjacentOffsetY)
end

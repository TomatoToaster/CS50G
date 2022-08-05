--[[
    GD50
    -- Super Mario Bros. Remake --

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

GameObject = Class{}

function GameObject:init(def)
    self.x = def.x
    self.y = def.y
    self.texture = def.texture
    self.width = def.width
    self.height = def.height
    self.frame = def.frame
    self.solid = def.solid
    self.consumable = def.consumable
    self.onCollide = def.onCollide
    self.onConsume = def.onConsume
    self.hit = def.hit
end

function GameObject:collides(target, isPlayer, fromBelow)
    local addedPlayerLeeway = isPlayer and 3 or 0
    return not (target.x + addedPlayerLeeway > self.x + self.width or self.x > target.x + target.width - addedPlayerLeeway or
            target.y > self.y + self.height or self.y > target.y + target.height)
end

function GameObject:update(dt)

end

function GameObject:render()
    -- Flip the flags
    if self.texture == 'flags' then
        love.graphics.draw(gTextures[self.texture], gFrames[self.texture][self.frame], self.x + self.width, self.y, 0, -1, 1)
    else
        love.graphics.draw(gTextures[self.texture], gFrames[self.texture][self.frame], self.x, self.y)
    end
end

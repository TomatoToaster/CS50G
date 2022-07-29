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
    local direction = self.player.direction
    self.player:changeAnimation('lift-' .. direction)
    self.player.currentAnimation:refresh()


    -- Same hitbox code as the sword but for the lifting
    if direction == 'left' then
        hitboxWidth = 8
        hitboxHeight = 16
        hitboxX = self.player.x - hitboxWidth
        hitboxY = self.player.y + 2
    elseif direction == 'right' then
        hitboxWidth = 8
        hitboxHeight = 16
        hitboxX = self.player.x + self.player.width
        hitboxY = self.player.y + 2
    elseif direction == 'up' then
        hitboxWidth = 16
        hitboxHeight = 8
        hitboxX = self.player.x
        hitboxY = self.player.y - hitboxHeight
    else
        hitboxWidth = 16
        hitboxHeight = 8
        hitboxX = self.player.x
        hitboxY = self.player.y + self.player.height
    end

    -- separate hitbox for the player's sword; will only be active during this state
    self.liftHitbox = Hitbox(hitboxX, hitboxY, hitboxWidth, hitboxHeight)

    for k, object in pairs(self.dungeon.currentRoom.objects) do
        if self.liftHitbox:collides(object) then
            self.player.heldItem = object
        end
    end

    -- Do this separately from above so that in case two pots are next to eachother, we only treat the last one collided
    -- as a held item
    if self.player.heldItem then
        self.player.heldItem.solid = false
        local liftAnimation = self.player.currentAnimation
        local liftAnimationLength = #liftAnimation.frames * liftAnimation.interval
        Timer.tween(liftAnimationLength, {
            [self.player.heldItem] = {x = self.player.x, y = self.player.y - self.player.heldItem.height + PLAYER_HELD_ITEM_Y_OFFSET}
        })
    end
end


function PlayerLiftState:update(dt)
    -- if we've fully elapsed through one cycle of animation, change back to idle state
    if self.player.currentAnimation.timesPlayed > 0 then
        self.player.currentAnimation.timesPlayed = 0
        self.player:changeState('idle')
    end
end

function PlayerLiftState:render()
    self.player.currentAnimation:render(self.player.x, self.player.y, self.player.offsetX, self.player.offsetY)
end

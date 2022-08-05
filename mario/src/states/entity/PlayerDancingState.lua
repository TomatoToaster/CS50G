--[[
    GD50
    Super Mario Bros. Remake

    Author: Amal Nazeem
    amalnazeem@gmail.com
]]

PlayerDancingState = Class{__includes = BaseState}

function PlayerDancingState:init(player)
    self.player = player

    self.animation = Animation {
        frames = {6, 7, 6, 7, 8, 9, 10, 11, 8, 9, 10, 11},
        interval = DANCE_TIME / 24
    }

    self.player.currentAnimation = self.animation

    -- Switch sides halfway through the dance
    Timer.after (DANCE_TIME / 2, function ()
        self.player.direction = self.player.direction == 'right' and 'left' or 'right'
    end)
end

function PlayerDancingState:update(dt)
    self.player.currentAnimation:update(dt)
end

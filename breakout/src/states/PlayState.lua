--[[
    GD50
    Breakout Remake

    -- PlayState Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Represents the state of the game in which we are actively playing;
    player should control the paddle, with the ball actively bouncing between
    the bricks, walls, and the paddle. If the ball goes below the paddle, then
    the player should lose one point of health and be taken either to the Game
    Over screen if at 0 health or the Serve screen otherwise.
]]

PlayState = Class{__includes = BaseState}

--[[
    We initialize what's in our PlayState via a state table that we pass between
    states as we go from playing to serving.
]]
function PlayState:enter(params)
    self.paddle = params.paddle
    self.bricks = params.bricks
    self.powerups = params.powerups
    self.health = params.health
    self.score = params.score
    self.highScores = params.highScores
    self.balls = {params.ball}
    self.level = params.level

    self.recoverPoints = 5000

    -- give the start ball random starting velocity
    self.balls[1].dx = math.random(-200, 200)
    self.balls[1].dy = math.random(-50, -60)

    -- give a random timing threshold to spawn a new powerup
    self.secondsTillPowerup = math.random(MIN_TIME_POWERUP, MAX_TIME_POWERUP)

end

function PlayState:update(dt)
    if self.paused then
        if love.keyboard.wasPressed('space') then
            self.paused = false
            gSounds['pause']:play()
            gSounds['music']:play()
        else
            return
        end
    elseif love.keyboard.wasPressed('space') then
        self.paused = true
        gSounds['pause']:play()
        gSounds['music']:pause()
        return
    end

    -- update positions based on velocity
    self.paddle:update(dt)

    -- have the powerups slowly sink
    for k, powerup in pairs(self.powerups) do
        if powerup.inPlay then
            powerup:update(dt)
            if Collides(self.paddle, powerup) then
                gSounds['powerup']:play()
                powerup.inPlay = false

                -- Only using two powerups right now
                if powerup.type == 9 then
                    -- Add a new ball to the play
                    local newBall = Ball(math.random(7))
                    newBall.x = self.balls[1].x
                    newBall.y = self.balls[1].y
                    -- give ball random starting velocity
                    newBall.dx = math.random(-200, 200)
                    newBall.dy = math.random(-50, -60)
                    table.insert(self.balls, newBall)
                elseif powerup.type == 10 then
                    -- Clear out the locked bricks
                    for k, brick in pairs(self.bricks) do
                        brick.isLocked = false
                    end
                end
            end
        end
    end

    for k, ball in pairs(self.balls) do
        -- Update the position of the ball
        ball:update(dt)

        -- Action for ball colliding with paddle
        if ball:collides(self.paddle) then
            -- raise ball above paddle in case it goes below it, then reverse dy
            ball.y = self.paddle.y - 8
            ball.dy = -ball.dy

            --
            -- tweak angle of bounce based on where it hits the paddle
            --

            -- if we hit the paddle on its left side while moving left...
            if ball.x < self.paddle.x + (self.paddle.width / 2) and self.paddle.dx < 0 then
                ball.dx = -50 + -(8 * (self.paddle.x + self.paddle.width / 2 - ball.x))

            -- else if we hit the paddle on its right side while moving right...
            elseif ball.x > self.paddle.x + (self.paddle.width / 2) and self.paddle.dx > 0 then
                ball.dx = 50 + (8 * math.abs(self.paddle.x + self.paddle.width / 2 - ball.x))
            end

            gSounds['paddle-hit']:play()
        end

        -- detect collision across all bricks with this ball
        for kbrick, brick in pairs(self.bricks) do

            -- only check collision if we're in play
            if brick.inPlay and ball:collides(brick) then

                -- add to score
                local scoreIncrease = brick.tier * 200 + brick.color * 25
                self.score = self.score + scoreIncrease
                self.paddle:addToScore(scoreIncrease)

                -- trigger the brick's hit function, which removes it from play
                brick:hit()

                -- if we have enough points, recover a point of health
                if self.score > self.recoverPoints then
                    -- can't go above 3 health
                    self.health = math.min(3, self.health + 1)

                    -- multiply recover points by 2
                    self.recoverPoints = math.min(100000, self.recoverPoints * 2)

                    -- play recover sound effect
                    gSounds['recover']:play()
                end

                -- go to our victory screen if there are no more bricks left
                if self:checkVictory() then
                    gSounds['victory']:play()

                    gStateMachine:change('victory', {
                        level = self.level,
                        paddle = self.paddle,
                        health = self.health,
                        score = self.score,
                        highScores = self.highScores,
                        ball = ball,
                        recoverPoints = self.recoverPoints
                    })
                end

                --
                -- collision code for bricks
                --
                -- we check to see if the opposite side of our velocity is outside of the brick;
                -- if it is, we trigger a collision on that side. else we're within the X + width of
                -- the brick and should check to see if the top or bottom edge is outside of the brick,
                -- colliding on the top or bottom accordingly
                --

                -- left edge; only check if we're moving right, and offset the check by a couple of pixels
                -- so that flush corner hits register as Y flips, not X flips
                if ball.x + 2 < brick.x and ball.dx > 0 then

                    -- flip x velocity and reset position outside of brick
                    ball.dx = -ball.dx
                    ball.x = brick.x - 8

                -- right edge; only check if we're moving left, , and offset the check by a couple of pixels
                -- so that flush corner hits register as Y flips, not X flips
                elseif ball.x + 6 > brick.x + brick.width and ball.dx < 0 then

                    -- flip x velocity and reset position outside of brick
                    ball.dx = -ball.dx
                    ball.x = brick.x + 32

                -- top edge if no X collisions, always check
                elseif ball.y < brick.y then

                    -- flip y velocity and reset position outside of brick
                    ball.dy = -ball.dy
                    ball.y = brick.y - 8

                -- bottom edge if no X collisions or top collision, last possibility
                else

                    -- flip y velocity and reset position outside of brick
                    ball.dy = -ball.dy
                    ball.y = brick.y + 16
                end

                -- slightly scale the y velocity to speed up the game, capping at +- 150
                if math.abs(ball.dy) < 150 then
                    ball.dy = ball.dy * 1.02
                end

                -- only allow colliding with one brick, for corners
                break
            end
        end

        -- if ball goes below bounds, remove it from play
        if ball.y >= VIRTUAL_HEIGHT then
            ball.inPlay = false
        end
    end

    -- Filter and flush out the balls not in play
    self.balls = table.filter(self.balls, function (ball) return ball.inPlay end)

    if #self.balls <= 0 then
        self.health = self.health - 1
        gSounds['hurt']:play()
        self.paddle:dropSize()

        if self.health == 0 then
            gStateMachine:change('game-over', {
                score = self.score,
                highScores = self.highScores
            })
        else
            gStateMachine:change('serve', {
                paddle = self.paddle,
                bricks = self.bricks,
                powerups = self.powerups,
                health = self.health,
                score = self.score,
                highScores = self.highScores,
                level = self.level,
                recoverPoints = self.recoverPoints
            })
        end
    end

    -- for rendering particle systems
    for k, brick in pairs(self.bricks) do
        brick:update(dt)
    end

    -- Flush out consumed powerups and bricks
    local oldLen = #self.bricks
    self.powerups = table.filter(self.powerups, function (powerup) return powerup.inPlay end)
    self.bricks = table.filter(self.bricks, function (brick) return brick.inPlay end)
    if oldLen ~= #self.bricks then
        print(oldLen)
        print(#self.bricks)
    end

    self.secondsTillPowerup = self.secondsTillPowerup - dt

    if self.secondsTillPowerup <= 0 then
        self.secondsTillPowerup = math.random(MIN_TIME_POWERUP, MAX_TIME_POWERUP)

        -- For now we are only spawning bonus ball type powerups
        local type =  9

        table.insert(self.powerups, Powerup(type))
    end


    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end
end

function PlayState:render()
    -- render bricks
    for k, brick in pairs(self.bricks) do
        brick:render()
    end

    -- render all particle systems
    for k, brick in pairs(self.bricks) do
        brick:renderParticles()
    end

    for k, powerup in pairs(self.powerups) do
        powerup:render()
    end

    self.paddle:render()

    for k, ball in pairs(self.balls) do
        if ball.inPlay then
            ball:render()
        end
    end

    renderScore(self.score)
    renderHealth(self.health)

    -- pause text, if paused
    if self.paused then
        love.graphics.setFont(gFonts['large'])
        love.graphics.printf("PAUSED", 0, VIRTUAL_HEIGHT / 2 - 16, VIRTUAL_WIDTH, 'center')
    end
end

function PlayState:checkVictory()
    for k, brick in pairs(self.bricks) do
        if brick.inPlay then
            return false
        end
    end

    return true
end

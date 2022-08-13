--[[
    GD50
    Angry Birds

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

Alien = Class{}

function Alien:init(world, type, x, y, userData)
    self.world = world
    self.type = type or 'square'

    self.body = love.physics.newBody(self.world,
        x or math.random(VIRTUAL_WIDTH), y or math.random(VIRTUAL_HEIGHT - 35),
        'dynamic')

    -- different shape and sprite based on type passed in
    if self.type == 'square' then
        self.shape = love.physics.newRectangleShape(35, 35)
        self.sprite = math.random(5)
    else
        self.shape = love.physics.newCircleShape(17.5)
        self.sprite = 9
    end

    self.fixture = love.physics.newFixture(self.body, self.shape)

    self.fixture:setUserData(userData)

    -- used to keep track of despawning the Alien and flinging it
    self.launched = false
end

-- return whether the alien is done moving
function Alien:isDoneMoving()
    local xPos, yPos = self.body:getPosition()
    local xVel, yVel = self.body:getLinearVelocity()

    -- if we fired our alien to the left or is barely moving it is done moving
    return xPos < 0 or (math.abs(xVel) + math.abs(yVel) < ALIEN_DONE_MOVING_VELOCITY_TOTAL)
end

function Alien:render()
    love.graphics.draw(gTextures['aliens'], gFrames['aliens'][self.sprite],
        math.floor(self.body:getX()), math.floor(self.body:getY()), self.body:getAngle(),
        1, 1, 17.5, 17.5)
end

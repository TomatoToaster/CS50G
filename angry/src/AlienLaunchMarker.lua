--[[
    GD50
    Angry Birds

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

AlienLaunchMarker = Class{}

function AlienLaunchMarker:init(world)
    self.world = world

    -- starting coordinates for launcher used to calculate launch vector
    self.baseX = 90
    self.baseY = VIRTUAL_HEIGHT - 100

    -- shifted coordinates when clicking and dragging launch alien
    self.shiftedX = self.baseX
    self.shiftedY = self.baseY

    -- whether our arrow is showing where we're aiming
    self.aiming = false

    -- whether we launched the alien and should stop rendering the preview
    self.launched = false

    -- our alien we will eventually spawn
    self.alien = nil

    -- extra aliens we will spawn above and below if the spacebar is pressed and conditions are met
    self.bonusAliens = nil

    -- whether we should block spawning bonus aliens (for example if we've already destroyed something)
    -- since a new AlienLaunchMaker is created every time we launch again, this flag will reset with
    -- every launch.
    self.blockBonusAliens = false

end

function AlienLaunchMarker:update(dt)

    -- perform everything here as long as we haven't launched yet
    if not self.launched then

        -- grab mouse coordinates
        local x, y = push:toGame(love.mouse.getPosition())

        -- if we click the mouse and haven't launched, show arrow preview
        if love.mouse.wasPressed(1) and not self.launched then
            self.aiming = true

        -- if we release the mouse, launch an Alien
        elseif love.mouse.wasReleased(1) and self.aiming then
            self.launched = true

            -- spawn new alien in the world, passing in user data of player
            self.alien = Alien(self.world, 'round', self.shiftedX, self.shiftedY, 'Player')

            -- apply the difference between current X,Y and base X,Y as launch vector impulse
            self.alien.body:setLinearVelocity((self.baseX - self.shiftedX) * 10, (self.baseY - self.shiftedY) * 10)

            -- make the alien pretty bouncy
            self.alien.fixture:setRestitution(0.4)
            self.alien.body:setAngularDamping(1)

            -- we're no longer aiming
            self.aiming = false

        -- re-render trajectory
        elseif self.aiming then

            self.shiftedX = math.min(self.baseX + 30, math.max(x, self.baseX - 30))
            self.shiftedY = math.min(self.baseY + 30, math.max(y, self.baseY - 30))
        end
    end
end

function AlienLaunchMarker:render()
    if not self.launched then

        -- render base alien, non physics based
        love.graphics.draw(gTextures['aliens'], gFrames['aliens'][9],
            self.shiftedX - 17.5, self.shiftedY - 17.5)

        if self.aiming then

            -- render arrow if we're aiming, with transparency based on slingshot distance
            local impulseX = (self.baseX - self.shiftedX) * 10
            local impulseY = (self.baseY - self.shiftedY) * 10

            -- draw 18 circles simulating trajectory of estimated impulse
            local trajX, trajY = self.shiftedX, self.shiftedY
            local gravX, gravY = self.world:getGravity()

            -- http://www.iforce2d.net/b2dtut/projected-trajectory
            for i = 1, 90 do

                -- magenta color that starts off slightly transparent
                love.graphics.setColor(255/255, 80/255, 255/255, ((255 / 24) * i) / 255)

                -- trajectory X and Y for this iteration of the simulation
                trajX = self.shiftedX + i * 1/60 * impulseX
                trajY = self.shiftedY + i * 1/60 * impulseY + 0.5 * (i * i + i) * gravY * 1/60 * 1/60

                -- render every fifth calculation as a circle
                if i % 5 == 0 then
                    love.graphics.circle('fill', trajX, trajY, 3)
                end
            end
        end

        love.graphics.setColor(1, 1, 1, 1)
    else
        self.alien:render()
        if self.bonusAliens then
            for i = 1, #self.bonusAliens do
                self.bonusAliens[i]:render()
            end
        end
    end
end

-- encasulates logic to launch aliens above and below the current alien
function AlienLaunchMarker:launchBonusAliens()
    -- don't do anything if we haven't launched yet or if we are told to block bonus alien launching
    if not self.launched or self.blockBonusAliens then
        return
    end
    self.bonusAliens = {}

    local alienX, alienY = self.alien.body:getX(), self.alien.body:getY()
    local linearX, linearY = self.alien.body:getLinearVelocity()

    -- alien going slightly above
    local alien1 = Alien(self.world, 'round', alienX, alienY, 'Player');
    alien1.body:setLinearVelocity(linearX, linearY + ALIEN_LAUNCH_Y_VELOCITY_DIFF)
    alien1.fixture:setRestitution(0.4)
    alien1.body:setAngularDamping(1)


    local alien2 = Alien(self.world, 'round', alienX, alienY, 'Player');
    alien2.body:setLinearVelocity(linearX, linearY - ALIEN_LAUNCH_Y_VELOCITY_DIFF)
    alien2.fixture:setRestitution(0.4)
    alien2.body:setAngularDamping(1)

    table.insert(self.bonusAliens, alien1)
    table.insert(self.bonusAliens, alien2)

    -- alien going slightly above
end

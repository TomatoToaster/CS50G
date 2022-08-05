--[[
  -- Powerup Class --
  Represents a powerup that players can pick up to add more balls or alter
  other things
]]

Powerup = Class{}

--[[
  Determine what type (1-9) and what x coordinate that this spawns on
]]
function Powerup:init(type)
  self.width = 16
  self.height = 16

  self.x = math.random(4, VIRTUAL_WIDTH - self.width - 4)
  self.y = math.random(20, VIRTUAL_HEIGHT / 2)

  -- Will be represented by the numbers 1-9
  self.type = type

  -- The powerups will be progressively by dy pixels per second
  self.dy = 40

  self.inPlay = true
end

function Powerup:update(dt)
  if self.inPlay then
    self.y = self.y + self.dy * dt

    -- After reaching to the bottom...
    if self.y >= VIRTUAL_HEIGHT then
      if self.type == 10 then
        -- Key type powerups should loop back to the top
        self.y = self.y % VIRTUAL_HEIGHT
      else
        -- Other powerups should just dissaper from play
        self.inPlay = false
      end
    end
  end
end

function Powerup:render()
  if self.inPlay then
    love.graphics.draw(gTextures['main'], gFrames['powerups'][self.type],
      self.x, self.y)
  end
end

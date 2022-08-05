--[[
    GD50
    Match-3 Remake

    -- Tile Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    The individual tiles that make up our game board. Each Tile can have a
    color and a variety, with the varietes adding extra points to the matches.
]]

Tile = Class{}

function Tile:init(x, y, color, variety)

    -- board positions
    self.gridX = x
    self.gridY = y

    -- coordinate positions
    self.x = (self.gridX - 1) * TILE_SIZE
    self.y = (self.gridY - 1) * TILE_SIZE

    -- tile appearance/points
    self.color = color
    self.variety = variety

    -- if the tile is shiny
    self.isShiny = math.random() < SHINY_CHANCE
end

function Tile:render(x, y)

    -- draw shadow
    love.graphics.setColor(34/255, 32/255, 52/255, 255/255)
    love.graphics.draw(gTextures['main'], gFrames['tiles'][self.color][self.variety],
        self.x + x + 2, self.y + y + 2)

    -- draw tile itself
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(gTextures['main'], gFrames['tiles'][self.color][self.variety],
        self.x + x, self.y + y)

    -- if the tile is shiny note that in some way
    if self.isShiny then
        love.graphics.setColor(1, 1, 0, 0.6)
        love.graphics.rectangle('fill', self.x + x + 12, self.y + y + 12, TILE_SIZE - 24, TILE_SIZE - 24)
    end
end

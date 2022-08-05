--[[
    GD50
    Super Mario Bros. Remake

    -- LevelMaker Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

LevelMaker = Class{}

function LevelMaker.generate(width, height)
    local tiles = {}
    local entities = {}
    local objects = {}

    local tileID = TILE_ID_GROUND

    -- whether we should draw our tiles with toppers
    local topper = true
    local tileset = math.random(20)
    local topperset = math.random(20)
    local keyType = math.random(#KEYS)
    local lockType = keyType + 4
    local poleType = math.random(#POLES)
    local flagType = math.random(#FLAGS)

    -- keep track of what indices have a special item on them so we don't overlap them
    local usedColumns = {}

    -- insert blank tables into tiles for later access
    for y = 1, height do
        table.insert(tiles, {})
    end

    -- column by column generation instead of row; sometimes better for platformers
    for x = 1, width do
        local tileID = TILE_ID_EMPTY

        -- lay out the empty space
        for y = 1, 6 do
            table.insert(tiles[y],
                Tile(x, y, tileID, nil, tileset, topperset))
        end

        -- chance to just be emptiness
        if math.random(7) == 1 then
            usedColumns[x] = true
            for y = 7, height do
                table.insert(tiles[y],
                    Tile(x, y, tileID, nil, tileset, topperset))
            end
        else
            tileID = TILE_ID_GROUND

            -- height at which we would spawn a potential jump block
            local blockHeight = 4

            for y = 7, height do
                table.insert(tiles[y],
                    Tile(x, y, tileID, y == 7 and topper or nil, tileset, topperset))
            end

            -- chance to generate a pillar
            if math.random(8) == 1 then
                blockHeight = 2

                -- chance to generate bush on pillar
                if math.random(8) == 1 then
                    table.insert(objects,
                        GameObject {
                            texture = 'bushes',
                            x = (x - 1) * TILE_SIZE,
                            y = (4 - 1) * TILE_SIZE,
                            width = 16,
                            height = 16,

                            -- select random frame from bush_ids whitelist, then random row for variance
                            frame = BUSH_IDS[math.random(#BUSH_IDS)] + (math.random(4) - 1) * 7,
                        }
                    )
                end

                -- pillar tiles
                tiles[5][x] = Tile(x, 5, tileID, topper, tileset, topperset)
                tiles[6][x] = Tile(x, 6, tileID, nil, tileset, topperset)
                tiles[7][x].topper = nil

            -- chance to generate bushes
            elseif math.random(8) == 1 then
                table.insert(objects,
                    GameObject {
                        texture = 'bushes',
                        x = (x - 1) * TILE_SIZE,
                        y = (6 - 1) * TILE_SIZE,
                        width = 16,
                        height = 16,
                        frame = BUSH_IDS[math.random(#BUSH_IDS)] + (math.random(4) - 1) * 7,
                    }
                )
            end

            -- chance to spawn a block
            if math.random(10) == 1 then
                usedColumns[x] = true
                table.insert(objects, GameObject {
                    texture = 'jump-blocks',
                    x = (x - 1) * TILE_SIZE,
                    y = (blockHeight - 1) * TILE_SIZE,
                    width = 16,
                    height = 16,

                    -- make it a random variant
                    frame = JUMP_BLOCKS[math.random(#JUMP_BLOCKS)],
                    hit = false,
                    solid = true,

                    -- collision function takes itself
                    onCollide = function(jumpBlock)

                        -- spawn a gem if we haven't already hit the block
                        if not jumpBlock.hit then

                            -- chance to spawn gem, not guaranteed
                            if math.random(2) == 1 then

                                -- maintain reference so we can set it to nil
                                local gem = GameObject {
                                    texture = 'gems',
                                    x = (x - 1) * TILE_SIZE,
                                    y = (blockHeight - 1) * TILE_SIZE - 4,
                                    width = 16,
                                    height = 16,
                                    frame = math.random(#GEMS),
                                    consumable = true,
                                    solid = false,

                                    -- gem has its own function to add to the player's score
                                    onConsume = function(player)
                                        gSounds['pickup']:play()
                                        player.score = player.score + 100
                                    end
                                }

                                -- make the gem move up from the block and play a sound
                                Timer.tween(0.1, {
                                    [gem] = {y = (blockHeight - 2) * TILE_SIZE}
                                })
                                gSounds['powerup-reveal']:play()

                                table.insert(objects, gem)
                            else
                                -- if it failed to make a gem, make it crumble so it breaks on the next hit
                                gSounds['empty-block']:play()
                                jumpBlock.hit = true
                                jumpBlock.consumable = true
                                jumpBlock.solid = false
                                jumpBlock.frame = jumpBlock.frame + 1
                            end
                        end
                    end,

                    onConsume = function (player)
                        gSounds['empty-block']:play()
                        gSounds['kill']:play()
                        gSounds['explosion']:play()
                    end
                })
            end
        end
    end


    -- Find an unused column for the key
    repeat
        keyColumn = math.random(1, width)
    until not usedColumns[keyColumn]
    usedColumns[keyColumn] = true
    table.insert(objects,
        GameObject {
            texture = 'keys-and-locks',
            frame = keyType,
            x = (keyColumn - 1) * TILE_SIZE,

            -- spawn height dependant on if there is a pillar there
            y = tiles[6][keyColumn].id == TILE_ID_EMPTY and (6 - 1) * TILE_SIZE or (4 - 1) * TILE_SIZE,
            width = 16,
            height = 16,
            consumable = true,
            solid = false,

            onConsume = function(player)
                gSounds['pickup']:play()

                -- Make all the corresponding locks consumable now
                for k, obj in pairs(objects) do
                    if (obj.texture == 'keys-and-locks' and obj.frame == keyType + 4) then
                        obj.solid = false
                        obj.consumable = true
                    end
                end
            end
        }
    )

    -- Find an unused column for the lock
    repeat
        lockColumn = math.random(1, width)
    until not usedColumns[lockColumn]
    usedColumns[lockColumn] = true
    table.insert(objects,
        GameObject {
            texture = 'keys-and-locks',
            frame = lockType,
            x = (lockColumn - 1) * TILE_SIZE,

            -- spawn height dependant on if there is a pillar there
            y = tiles[6][lockColumn].id == TILE_ID_EMPTY and (4 - 1) * TILE_SIZE or (2 - 1) * TILE_SIZE,
            width = 16,
            height = 16,
            consumable = false,
            solid = true,

            onCollide = function (lock)
                gSounds['locked']:play()
            end,

            onConsume = function (player)
                gSounds['pickup']:play()

                -- Find the last non empty column for the pole
                local poleColumn = width
                while tiles[7][poleColumn].id ~= TILE_ID_GROUND or usedColumns[poleColumn] do
                    poleColumn= poleColumn - 1
                end
                local poleX = (poleColumn - 1) * TILE_SIZE

                -- If it's on a pillar column, raise the pole up above the pillar
                local poleY = (tiles[5][poleColumn].id == TILE_ID_GROUND and 1 or 3) * TILE_SIZE

                LevelMaker.spawnFlag(objects, poleType, flagType, poleX, poleY, width)
            end,
        }
    )


    local map = TileMap(width, height)
    map.tiles = tiles

    return GameLevel(entities, objects, map)
end

function LevelMaker.spawnFlag(objects, poleType, flagType, poleX, poleY, currentLevelWidth)
    love.graphics.draw(gTextures['poles'], gFrames['poles'][5], poleX, poleY)
    love.graphics.draw(gTextures['flags'], gFrames['flags'][2], poleX + 9, poleY + 5)
    table.insert(objects,
        GameObject {
            texture = 'poles',
            frame = poleType,
            x = poleX,
            y = poleY,
            width = 16,
            height = 48,
            consumable = false,
            solid = false,
        }
    )
    table.insert(objects,
        GameObject {
            texture = 'flags',
            frame = flagType,
            x = poleX - 7,
            y = poleY + 5,
            width = 16,
            height = 16,
            consumable = true,
            solid = false,
            onConsume = function (player)
                gSounds['victory']:play()
                player.hasWon = true

                -- Give a bit of delay so the player can process the flag pickup and dance
                Timer.after(DANCE_TIME, function ()
                    gStateMachine:change('play', {
                        width = currentLevelWidth + LEVEL_GROWTH,
                        score = player.score
                    })
                end)
            end,
        }
    )
end

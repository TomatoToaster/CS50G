--[[
    GD50
    Pokemon

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

PlayState = Class{__includes = BaseState}

function PlayState:init()
    self.level = Level()

    gSounds['field-music']:setLooping(true)
    gSounds['field-music']:play()

    self.dialogueOpened = false
end

function PlayState:update(dt)
    if not self.dialogueOpened and love.keyboard.wasPressed('p') then
        
        -- heal player pokemon
        gSounds['heal']:play()
        self.level.player.party.pokemon[1].currentHP = self.level.player.party.pokemon[1].HP
        
        -- show a dialogue for it, allowing us to do so again when closed
        gStateStack:push(DialogueState('Your Pokemon has been healed!',
    
        function()
            self.dialogueOpened = false
        end))
    end

    if love.keyboard.wasPressed('l') then
        local testLevelUpStats = {
            {
                name = 'HP',
                base = math.random(1,5),
                increase = math.random(1,3)
            },
            {
                name = 'Atk',
                base = math.random(6,10),
                increase = math.random(1,3)
            },
            {
                name = 'Def',
                base = math.random(10,15),
                increase = math.random(1,3)
            },
            {
                name = 'Spd',
                base = math.random(15,20),
                increase = math.random(1,3)
            }
        }
        gStateStack:push(LevelUpMenuState(testLevelUpStats))
    end

    self.level:update(dt)
end

function PlayState:render()
    self.level:render()
end
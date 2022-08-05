--[[
    ScoreState Class
    Author: Colton Ogden
    cogden@cs50.harvard.edu

    A simple state used to display the player's score before they
    transition back into the play state. Transitioned to from the
    PlayState when they collide with a Pipe.
]]

ScoreState = Class{__includes = BaseState}

local FIRST_PLACE_IMG = love.graphics.newImage('medal_1st.png')
local SECOND_PLACE_IMG = love.graphics.newImage('medal_2nd.png')
local THIRD_PLACE_IMG = love.graphics.newImage('medal_3rd.png')

local POINTS_FOR_2ND = 5
local POINTS_FOR_1ST = 10

--[[
    Returns the appropriate medal for the for the points received
]]
local function getMedalForScore(score)
    if score > POINTS_FOR_1ST then
        return FIRST_PLACE_IMG
    elseif score > POINTS_FOR_2ND then
        return SECOND_PLACE_IMG
    else
        return THIRD_PLACE_IMG
    end
end

--[[
    When we enter the score state, we expect to receive the score
    from the play state so we know what to render to the State.
]]
function ScoreState:enter(params)
    self.score = params.score
    self.medal = getMedalForScore(params.score)
end

function ScoreState:update(dt)
    -- go back to play if enter is pressed
    if not gIsPaused and (love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return')) then
        -- TODO same to countdown
        gStateMachine:change('play')
    end
end

function ScoreState:render()
    -- simply render the score to the middle of the screen
    love.graphics.setFont(flappyFont)
    love.graphics.printf('Oof! You lost!', 0, 64, VIRTUAL_WIDTH, 'center')

    love.graphics.setFont(mediumFont)
    love.graphics.printf('Score: ' .. tostring(self.score), 0, 100, VIRTUAL_WIDTH, 'center')

    love.graphics.draw(self.medal,
        VIRTUAL_WIDTH / 2 - 16,
        120
    )

    love.graphics.printf('Press Enter to Play Again!', 1, 160, VIRTUAL_WIDTH, 'center')
end

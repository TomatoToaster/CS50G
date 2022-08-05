--[[
    GD50 2018
    Breakout Remake

    -- constants --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Some global constants for our application.
]]

-- size of our actual window
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

-- size we're trying to emulate with push
VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

-- paddle movement speed
PADDLE_SPEED = 200

-- Starting level value
START_LEVEL = 1

-- Paddle score to upgrade paddle size
PADDLE_SECRET_SCORE_THRESHOLD = 1000

-- Minimum time in seconds for a powerup to spawn
MIN_TIME_POWERUP = 5

-- Maximum time in seconds for a powerup to spawn
MAX_TIME_POWERUP = 15

-- Chance for lock key room (on in __)
LOCK_KEY_CHANCE = 3

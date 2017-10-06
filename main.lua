-- Global variables:
Controls = {
	UP = "up",
	DOWN = "down",
	LEFT = "left",
	RIGHT = "right",
	ACTION = "space"
}
Menu = require "src.menu"	-- Menu-state (return from minigame)
Timer = require "lib.timer"	-- Timer (might be used in minigames)
Venus = require "lib.venus"	-- Minigames & menu need to access this

local splash = require "src.splash"

function love.load()
	Venus.registerEvents()
	Venus.switch(splash)
end

function love.update(dt)
	Timer.update(dt)
end

function love.draw()

end

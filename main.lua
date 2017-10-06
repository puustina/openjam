-- Global variables:
require "controls"
Game = {
	paused = false,
	result = "",		-- minigame result (WIN|LOSE|"")
	maxLives = 3,
	curLives = 3,
	speed = 1,		-- speed/difficulty of minigames
	scale = 1,
	volume = 1,
	original = {
		w = love.graphics.getWidth(),
		h = love.graphics.getHeight()
	}
}
Timer = require "lib.timer"	-- Timer (might be used in minigames)
Venus = require "lib.venus"	-- Minigames & menu need to access this

local splash = require "src.splash"

function love.load()
	Venus.registerEvents()
	Venus.switch(splash)
end

function love.keypressed(key, scancode, isRepeat)
	local setScale = function() 
		Game.cooldown = true
		Timer.add(0.3, function() Game.cooldown = false end) 
		love.window.setMode(Game.original.w * Game.scale, Game.original.h * Game.scale)
	end

	if (key == "escape") then
		if Game.paused then
			love.event.quit()
		end
		Game.paused = true
	elseif Game.paused then
		Game.paused = false
	end

	if (key == "-") then
		if love.keyboard.isDown("rctrl") or love.keyboard.isDown("lctrl") then
			if Game.cooldown then return end
			Game.scale = math.max(1, Game.scale / 2)
			setScale()
		else
			Game.volume = math.max(0, Game.volume - 0.1)
		end
	elseif (key == "+") then
		if love.keyboard.isDown("rctrl") or love.keyboard.isDown("lctrl") then
			if Game.cooldown then return end
			Game.scale = math.min(3, Game.scale * 2)
			setScale()
		else
			Game.volume = math.min(1, Game.volume + 0.1)
		end
	end
end

function love.update(dt)
	if Game.paused then return end
	Timer.update(dt)
end

function preDraw()
	love.graphics.push()
	love.graphics.scale(Game.scale, Game.scale)
end

function postDraw()
	if Game.paused then
		love.graphics.setColor(255, 255, 255, 200)
		love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
		love.graphics.setColor(0, 0, 0)
		love.graphics.print("Game paused! Esc to exit, any key to continue.", 100, 100)
	end
	love.graphics.pop()
end

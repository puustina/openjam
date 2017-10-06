-- Global variables:
require "controls"
Game = {
	paused = false,
	pauseEnd = false,
	result = "",		-- minigame result (WIN|LOSE|"")
	maxLives = 3,
	curLives = 3,
	speed = 1,		-- speed/difficulty of minigames
	scale = 1,
	volume = 1,
	original = {
		w = love.graphics.getWidth(),
		h = love.graphics.getHeight()
	},
	font14 = love.graphics.newFont(14),
	font40 = love.graphics.newFont(40),
	font70 = love.graphics.newFont(70)
}
Game.font14:setFilter("nearest", "nearest", 0)
Game.font40:setFilter("nearest", "nearest", 0)
love.graphics.setFont(Game.font14)
Game.font70:setFilter("nearest", "nearest", 0)
Timer = require "lib.timer"	-- Timer (might be used in minigames)
Venus = require "lib.venus"	-- Minigames & menu need to access this
Venus.duration = 0.5

local splash = require "src.splash"

function love.load()
	Venus.registerEvents()
	Venus.switch(splash)
end

function love.keypressed(key, scancode, isRepeat)
	local setScale = function() 
		Game.cooldown = true
		love.window.setMode(Game.original.w * Game.scale, Game.original.h * Game.scale)
	end

	if (key == Controls["PAUSE"]) then
		if Game.paused then
			love.event.quit()
		end
		Game.paused = true
	elseif (Game.paused and key == Controls["ACTION"]) then
		Game.pauseEnd = true
	end

	if (key == "-") then
		if love.keyboard.isDown("rctrl") or love.keyboard.isDown("lctrl") then
			if Game.cooldown then 
				Game.cooldown = false
				return 
			end
			Game.scale = math.max(1, Game.scale / 2)
			setScale()
		else
			Game.volume = math.max(0, Game.volume - 0.1)
		end
	elseif (key == "+") then
		if love.keyboard.isDown("rctrl") or love.keyboard.isDown("lctrl") then
			if Game.cooldown then 
				Game.cooldown = false 
				return 
			end
			Game.scale = math.min(3, Game.scale * 2)
			setScale()
		else
			Game.volume = math.min(1, Game.volume + 0.1)
		end
	end
end

function love.update(dt)
	if Game.pauseEnd then 
		Game.paused = false 
		Game.pauseEnd = false	
	end
	if Game.paused then return end
	Timer.update(dt)
end

function preDraw()
	love.graphics.push()
	love.graphics.scale(Game.scale, Game.scale)
end

function postDraw()
	if Game.paused then
		love.graphics.setColor(220, 220, 220, 220)
		love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
		love.graphics.setColor(30, 30, 30, 255)
		love.graphics.setFont(Game.font40)
		local l1 = "Game paused!"
		local l2 = "PAUSE to exit. ACTION to resume."
		love.graphics.print(l1, Game.original.w/2 - Game.font40:getWidth(l1)/2, Game.original.h/2 - 40)
		love.graphics.setFont(Game.font14)
		love.graphics.print(l2, Game.original.w/2 - Game.font14:getWidth(l2)/2, Game.original.h/2 + 20)
	end
	love.graphics.pop()
end

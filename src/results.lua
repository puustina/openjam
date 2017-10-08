local menu = require "src.menu"
local gameRoulette = require "src.gameRoulette"
local results = {}

function results:init()
	self.timer = Timer.new()
end

function results:entering()
	self.delay = 3
	self.lifeDown = false
	if Game.mode == "END" then
		if Game.result == "WIN" then
			Game.minigameStreak = Game.minigameStreak + 1
			Game.minigamesWon = Game.minigamesWon + 1
			
			if Game.minigameStreak >= 3 then
				self.delay = self.delay + 1
				Game.speed = math.min(Game.maxSpeed, Game.multi * Game.speed)
				Venus.duration = (1/Game.speed) * Game.fadeDuration
				Game.minigameStreak = 0
			end
		else
			self.delay = self.delay + 1
			Game.minigameStreak = 0
			Game.curLives = Game.curLives - 1
			Game.speed = math.max(Game.minSpeed, (1/Game.multi) * Game.speed)
			Venus.duration = (1/Game.speed) * Game.fadeDuration
		end
	end
end

function results:entered()
	if Game.mode == "FP" then
		Venus.duration = Game.fadeDuration
		self.timer:add(1, function() Venus.switch(menu) end)
	else
		if Game.curLives > 0 then
			self.timer:add(self.delay * (1/Game.speed), function() Venus.switch(gameRoulette) end)
		else -- game over
			Venus.duration = Game.fadeDuration
			self.timer:add(10, function() Venus.switch(menu) end)
		end
	end
end

function results:left()
	Game.result = ""
	if Game.mode == "END" and Game.curLives < 1 then
		Game.minigameStreak = 0
		Game.minigamesWon = 0
	end
end

function results:update(dt)
	if Game.paused then return end
	self.timer:update(dt)	
end

function results:draw()
	preDraw()
	love.graphics.setBackgroundColor(30, 30, 30)
	love.graphics.setColor(170, 170, 170)
	local resultNiceText = Game.result == "WIN" and "Minigame won" or "Minigame lost"
	if Game.mode == "FP" then
		love.graphics.setFont(Game.font40)
		love.graphics.print(resultNiceText, Game.original.w/2 - Game.font40:getWidth(resultNiceText)/2,
			Game.original.h/2 - Game.font40:getHeight()/2)
	else
		love.graphics.setFont(Game.font40)
		love.graphics.print(resultNiceText, Game.original.w/2 - Game.font40:getWidth(resultNiceText)/2,
			Game.original.h/2 - Game.font40:getHeight()/2 - 80)
		love.graphics.setFont(Game.font40)
		local livesLeft = ""
		for i = 1, Game.curLives do livesLeft = livesLeft .. "<3 " end 
		for i = 1, Game.maxLives - Game.curLives do 
			if i == 1 and Game.result == "LOSE" then
				livesLeft = livesLeft .. "</3 "
			else
				livesLeft = livesLeft .. "* " 
			end
		end
		love.graphics.print(livesLeft, Game.original.w/2 - Game.font40:getWidth(livesLeft)/2,
			Game.original.h/2 - Game.font40:getHeight()/2 - 30)
		
		local trunc = function(nr)
			if (""..nr):find("%.") then
				return (""..nr):sub(1, (""..nr):find("%.") + 2)
			else
				return ""..nr
			end
		end
		if Game.curLives == 0 then
			love.graphics.setFont(Game.font40)
			love.graphics.print("GAME OVER", Game.original.w/2 - Game.font40:getWidth("GAME OVER")/2,
				Game.original.h/2 - Game.font40:getHeight()/2 + 40)
			love.graphics.setFont(Game.font20)
			local t1 = "Minigames beaten: " .. Game.minigamesWon
			local t2 = "Final speed: " .. trunc(Game.speed * Game.multi)
			love.graphics.print(t1, Game.original.w/2 - Game.font20:getWidth(t1)/2, 220)
			love.graphics.print(t2, Game.original.w/2 - Game.font20:getWidth(t2)/2, 250)
		else
			local changeSpeed = function(dir)
				love.graphics.setFont(Game.font20)
				local text = "Speed " .. (dir == 1 and "UP: " or "DOWN: ")
					.. (dir == 1 and trunc(Game.speed/Game.multi) or trunc(Game.speed*Game.multi))
					.. " -> " .. trunc(Game.speed)
				love.graphics.print(text, Game.original.w/2 - Game.font20:getWidth(text)/2,
					Game.original.h/2 - Game.font20:getHeight()/2 + 40)
			end

			if (Game.result == "WIN" and Game.minigameStreak == 0) then
				changeSpeed(1)
			elseif Game.result == "LOSE" then
				changeSpeed(-1)
			end
		end
	end
	postDraw()
end

return results

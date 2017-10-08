local menu = require "src.menu"
local gameRoulette = require "src.gameRoulette"
local results = {}

function results:init()
	self.timer = Timer.new()
end

function results:entering()
	self.delay = 2
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
			self.timer:add(5, function() Venus.switch(menu) end)
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
	love.graphics.setBackgroundColor(0, 0, 0)
	love.graphics.setColor(255, 255, 255)
	love.graphics.print(Game.result, 100, 100)
	if Game.mode == "END" then
		love.graphics.print(Game.minigamesWon, 110, 120)
		love.graphics.print(Game.curLives, 110, 140)
		love.graphics.print(Game.speed, 110, 160)
		if Game.result == "WIN" and Game.minigameStreak == 0 then
			love.graphics.print("SPEED UP", 110, 180)
		elseif Game.result == "LOSE" then
			love.graphics.print("SPEED DOWN", 110, 180)
			love.graphics.print("LIFE DOWN", 110, 200)
		end
	end
	postDraw()
end

return results

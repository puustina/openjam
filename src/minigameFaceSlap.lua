local results = require "src.results"
local countdown = require "src.countdown"

local faceSlap = {
	name = "Face Punch",
	description = "Punch the face.",
	controls = "LEFT RIGHT",
	thumbnail = nil,
	-- game specific
	maxTimeOrig = 5,
	timeLeft = 5,
	slapsNeeded = { 10, 10 },
	slapsCurrent = { 0, 0 },
	lose = love.graphics.newImage("assets/faceSlap/gloves.png"),
	playerGloveL = love.graphics.newImage("assets/faceSlap/player_glove.png")
}

local slapTime = 0.15
local bindings = {
	LEFT = function(minigame)
		if not minigame.hasControl then return end
		love.audio.play(Game.sources.punch)
		minigame.slapTimer[1] = slapTime
		minigame.slapsCurrent[1] = math.min(minigame.slapsNeeded[1], minigame.slapsCurrent[1] + 1)
	end,
	RIGHT = function(minigame)
		if not minigame.hasControl then return end
		love.audio.play(Game.sources.punch)
		minigame.slapTimer[2] = slapTime
		minigame.slapsCurrent[2] = math.min(minigame.slapsNeeded[2], minigame.slapsCurrent[2] + 1)
	end
}

function faceSlap:init()
	self.timer = Timer.new()
end

function faceSlap:entering()
	self.over = false
	self.pos = 0
	self.pos2 = Game.original.h
	self.maxTime = (1/Game.speed) * self.maxTimeOrig
	self.timeLeft = self.maxTime
	self.slapsCurrent = { 0, 0 }
	self.slapTimer = { 0, 0 }
	countdown:reset()
	countdown:start()
	self.faceCur = {
		Game.face.base,
		Game.face.hat[math.random(1, 4)],
		Game.face.eyes[math.random(1, 4)],
		Game.face.mouth[math.random(1, 4)],
		Game.face.nose[math.random(1, 4)]
	}
end

function faceSlap:keypressed(key, scancode, isRepeat)
	if Game.paused or not countdown:over() then return end
	if isRepeat then return end
	if self.over then return end

	for i, j in pairs(bindings) do
		if (key == Controls[i]) then j(self) end
	end

	if (self.slapsCurrent[1] == self.slapsNeeded[1] and self.slapsCurrent[2] == self.slapsNeeded[2]) then
		Game.result = "WIN"
		self.hasControl = false
		self.over = true
		self.timer:tween(1 * (1/Game.speed), self, { pos = Game.original.h }, "in-out-quad")
		self.timer:add(1 * (1/Game.speed), function() Venus.switch(results) end)
	end
end

function faceSlap:update(dt)
	if Game.paused then return end
	self.timer:update(dt)
	if not countdown:over() then
		countdown:update(dt)
		return
	else
		self.hasControl = true
	end

	self.slapTimer[1] = self.slapTimer[1] - dt
	self.slapTimer[2] = self.slapTimer[2] - dt
	if self.over then return end
	self.timeLeft = self.timeLeft - dt
	if (self.timeLeft < 0) then
		Game.result = "LOSE"
		self.hasControl = false
		self.over = true
		self.timer:tween(1 * (1/Game.speed), self, { pos2 = 0 }, "out-quad")
		self.timer:add(2 * (1/Game.speed), function() Venus.switch(results) end)
	end
end

function faceSlap:draw()
	preDraw()
	love.graphics.setBackgroundColor(30, 30, 30)
	love.graphics.setColor(255, 255, 255)
	for i, j in ipairs(self.faceCur) do
		love.graphics.draw(j, Game.original.w/2 - j:getWidth()/2, 30 + self.pos)
	end
	for i = 1, 2 do
		local s = self.slapsCurrent[i]/self.slapsNeeded[i]
		love.graphics.setColor(150, 25, 25, 222 * s)
		love.graphics.circle("fill", Game.original.w/2 + (i == 1 and -70 or 70), Game.original.h/2 + 60 + self.pos, 15 * (1 + s))
	end
	if Game.result == "LOSE" then
		love.graphics.setColor(255, 255, 255)
		love.graphics.draw(self.lose, Game.original.w/2 - self.lose:getWidth()/2, 30 + self.pos2)
		love.graphics.setFont(Game.font20)
		love.graphics.setColor(150, 150, 150, 255 * (1 - self.pos2/Game.original.h))
		love.graphics.print("My turn...", 20, 30)
	end
	love.graphics.setColor(255, 255, 255)
	for i, j in ipairs(self.slapTimer) do
		if j > 0 then
			local s = j/slapTime 
			love.graphics.draw(self.playerGloveL, Game.original.w/2 + (i == 1 and -1 or 1) * 110, 
				Game.original.h/2 + 100, 0, s * (i == 2 and -1 or 1), s, 
				self.playerGloveL:getWidth()/2, self.playerGloveL:getHeight()/2)
		end
	end
	love.graphics.setColor(50, 50, 50)
	love.graphics.rectangle("fill", 0, 0, Game.original.w, 10)
	love.graphics.rectangle("fill", 0, Game.original.h - 10, Game.original.w, 10)
	love.graphics.setColor(150, 150, 150)
	local sRL = self.slapsCurrent[1]/self.slapsNeeded[1]
	local sRR = self.slapsCurrent[2]/self.slapsNeeded[2]
	love.graphics.rectangle("fill", Game.original.w/2 * (1 - sRL),
		0, (Game.original.w/2) * sRL, 10)
	love.graphics.rectangle("fill", Game.original.w/2, 0, (Game.original.w/2) * sRR, 10)
	love.graphics.rectangle("fill", 0, Game.original.h - 10, Game.original.w * (self.timeLeft/self.maxTime), 10)
	love.graphics.setColor(30, 30, 30)
	love.graphics.setLineWidth(2)
	love.graphics.line(Game.original.w/2, 0, Game.original.w/2, 10)
	if not countdown:over() then countdown:draw() end
	postDraw()
end

return faceSlap

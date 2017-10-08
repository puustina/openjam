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
	lose = love.graphics.newImage("assets/faceSlap/gloves.png")
}

local bindings = {
	LEFT = function(minigame)
		if not minigame.hasControl then return end
		minigame.slapsCurrent[1] = math.min(minigame.slapsNeeded[1], minigame.slapsCurrent[1] + 1)
	end,
	RIGHT = function(minigame)
		if not minigame.hasControl then return end
		minigame.slapsCurrent[2] = math.min(minigame.slapsNeeded[2], minigame.slapsCurrent[2] + 1)
	end
}

function faceSlap:init()
	self.timer = Timer.new()
	local facePartNames = {
		"nose",
		"mouth",
		"hat",
		"eyes"
	}
	self.face = {
		base = love.graphics.newImage("assets/faceSlap/template.png")
	}
	for i, j in pairs(facePartNames) do
		self.face[j] = {}
		for k = 1, 4 do 
			self.face[j][k] = love.graphics.newImage("assets/faceSlap/" .. j .. k .. ".png")
		end
	end
end

function faceSlap:entering()
	self.over = false
	self.pos = 0
	self.pos2 = Game.original.h
	self.maxTime = (1/Game.speed) * self.maxTimeOrig
	self.timeLeft = self.maxTime
	self.slapsCurrent = { 0, 0 }
	countdown:reset()
	countdown:start()
	self.face.cur = {
		self.face.base,
		self.face.hat[math.random(1, 3)],
		self.face.eyes[math.random(1, 3)],
		self.face.mouth[math.random(1, 3)],
		self.face.nose[math.random(1, 3)]
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
	for i, j in ipairs(self.face.cur) do
		love.graphics.draw(j, Game.original.w/2 - j:getWidth()/2, 30 + self.pos)
	end
	if Game.result == "LOSE" then
		love.graphics.draw(self.lose, Game.original.w/2 - self.lose:getWidth()/2, 30 + self.pos2)
		love.graphics.setFont(Game.font20)
		love.graphics.setColor(150, 150, 150, 255 * (1 - self.pos2/Game.original.h))
		love.graphics.print("My turn...", 20, 30)
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

local results = require "src.results"
local countdown = require "src.countdown"

local faceSlap = {
	name = "Face Slap",
	description = "Slap the face.",
	controls = "LEFT RIGHT",
	thumbnail = nil,
	-- game specific
	maxTimeOrig = 5,
	timeLeft = 5,
	slapsNeeded = { 10, 10 },
	slapsCurrent = { 0, 0 }
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
		for k = 1, 3 do 
			self.face[j][k] = love.graphics.newImage("assets/faceSlap/" .. j .. k .. ".png")
		end
	end
end

function faceSlap:entering()
	self.over = false
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

	for i, j in pairs(bindings) do
		if (key == Controls[i]) then j(self) end
	end

	if (self.slapsCurrent[1] == self.slapsNeeded[1] and self.slapsCurrent[2] == self.slapsNeeded[2]) then
		Game.result = "WIN"
		self.hasControl = false
		self.over = true
		Venus.switch(results)
	end
end

function faceSlap:update(dt)
	if Game.paused then return end
	if not countdown:over() then
		countdown:update(dt)
		return
	else
		self.hasControl = true
	end

	self.timeLeft = self.timeLeft - dt
	if (self.timeLeft < 0 and not self.over) then
		Game.result = "LOSE"
		self.hasControl = false
		self.over = true
		Venus.switch(results)
	end
end

function faceSlap:draw()
	preDraw()
	love.graphics.setBackgroundColor(120, 120, 120)
	love.graphics.setColor(255, 255, 255)
	for i, j in ipairs(self.face.cur) do
		love.graphics.draw(j, Game.original.w/2 - j:getWidth()/2, 20)
	end
	local sRL = self.slapsCurrent[1]/self.slapsNeeded[1]
	local sRR = self.slapsCurrent[2]/self.slapsNeeded[2]
	love.graphics.rectangle("fill", Game.original.w/2 * (1 - sRL),
		0, (Game.original.w/2) * sRL, 20)
	love.graphics.rectangle("fill", Game.original.w/2, 0, (Game.original.w/2) * sRR, 20)
	love.graphics.rectangle("fill", 0, Game.original.h - 20, Game.original.w * (self.timeLeft/self.maxTime), 20)
	if not countdown:over() then countdown:draw() end
	postDraw()
end

return faceSlap

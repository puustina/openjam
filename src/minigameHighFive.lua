local results = require "src.results"
local countdown = require "src.countdown"

local highFive = {}
highFive = {
	name = "High Five",
	description = "Leave Mark hanging.",
	controls = "LEFT RIGHT",
	thumbnail = nil,
	-- game specific
	over = false,
	newTarget = function(self, first)
		local names = { "Jack", "Steve", "Wilson", "Eric", "Laura", 
			"James", "Stephanie", "Markus", "Margaret" }
		if not first then names[#names + 1] = "Mark" end
		self.target = {
			name = names[math.random(1, #names)],
			face = {
				Game.face.base,
				Game.face.hat[math.random(1, 4)],
				Game.face.eyes[math.random(1, 4)],
				Game.face.mouth[math.random(1, 4)],
				Game.face.nose[math.random(1, 4)]
			},
			hand = math.random() > 0.5 and 1 or -1,
			timerMax = 2 * (1/Game.speed),
			timerCur = 2 * (1/Game.speed)
		}
	end,
	gameOver = function(self, res, quick)
		self.over = true
		Game.result = res
		local delay = 2
		if quick then delay = delay/4 end
		self.timer:tween(delay * (1/Game.speed), highFive, { pos = Game.original.h }, "in-out-quad")
		self.timer:add(delay * (1/Game.speed), function() Venus.switch(results) end)
	end,
	palmR = love.graphics.newImage("assets/highFive/palmR.png"),
	handL = love.graphics.newImage("assets/highFive/handL.png")
}

function highFive:init()
	self.timer = Timer.new()
end

function highFive:entering()
	self.over = false
	self.maxSlapWait = 0.2 * (1/Game.speed)
	self.slapWait = 0
	self.pHandedness = math.random() > 0.5 and 1 or -1
	self:newTarget(true)
	countdown:reset()
	countdown:start()
	self.pos = 0
end

function highFive:keypressed(key, scancode, isRepeat)
	if isRepeat then return end
	if self.over then return end
	if not countdown:over() then return end
	if self.slapWait > 0 then return end
	if not (key == Controls["RIGHT"] or key == Controls["LEFT"]) then return end

	if key == Controls["RIGHT"] then
		self.slapped = 1
		self.slapWait = self.maxSlapWait
	elseif key == Controls["LEFT"] then
		self.slapped = -1
		self.slapWait = self.maxSlapWait
	end

	if (key == Controls["LEFT"] and self.target.hand == 1) or 
		(key == Controls["RIGHT"] and self.target.hand == -1) then
		self:gameOver("LOSE")
	else
		love.audio.play(Game.sources.slap)
		if self.target.name == "Mark" then
			self:gameOver("LOSE")
			return
		end
		self.timer:add(self.maxSlapWait, function() highFive:newTarget() end)
		self.timer:tween(self.maxSlapWait, highFive.target, { timerCur = highFive.target.timerMax })
	end
end

function highFive:update(dt)
	if Game.paused then return end
	if not countdown:over() then
		countdown:update(dt)
		return
	end
	self.timer:update(dt)
	if self.over then return end

	self.slapWait = self.slapWait - dt
	if self.slapWait <= 0 then
		self.target.timerCur = self.target.timerCur - dt
		if self.target.timerCur <= 0 then
			if self.target.name == "Mark" then
				self:gameOver("WIN")
			else
				self:gameOver("LOSE", true)
			end
		end
	end
end

function highFive:draw()
	preDraw()
	love.graphics.setBackgroundColor(30, 30, 30)
	love.graphics.setColor(255, 255, 255)
	for i, j in ipairs(self.target.face) do
		love.graphics.draw(j, Game.original.w/2 - j:getWidth()/2, 40)
	end
	local x = Game.original.w/2 + self.target.hand * 120
	local y = 230
	love.graphics.draw(self.palmR, x, y + (Game.result == "WIN" and self.pos or 0), 0, 
		self.target.hand, 1, self.palmR:getWidth()/2, self.palmR:getHeight()/2)
	if self.slapWait > 0 then
		love.graphics.draw(self.handL, Game.original.w/2 + self.slapped * 120, y + (Game.result == "LOSE" and self.pos or 0), 0, 
			self.pHandedness, 1, self.handL:getWidth()/2, self.handL:getHeight()/2)
	end
	love.graphics.setColor(50, 50, 50)
	love.graphics.rectangle("fill", 0, 0, Game.original.w, 40)
	love.graphics.rectangle("fill", 0, Game.original.h - 10, Game.original.w, 10)
	love.graphics.setColor(200, 200, 200)
	love.graphics.setFont(Game.font20)
	love.graphics.print(self.target.name, Game.original.w/2 - Game.font20:getWidth(self.target.name)/2,
		20 - Game.font20:getHeight()/2)
	love.graphics.setColor(150, 150, 150)
	love.graphics.rectangle("fill", 0, Game.original.h - 10, Game.original.w * (self.target.timerCur/self.target.timerMax), 10)

	if not countdown:over() then countdown:draw() end
	postDraw()
end

return highFive

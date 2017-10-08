local results = require "src.results"
local countdown = require "src.countdown"

local highFive = {
	name = "High Five",
	description = "Leave Mark hanging.",
	controls = "LEFT RIGHT",
	thumbnail = nil,
	-- game specific
	over = false,
	newTarget = function(self)
		local names = { "Jack", "Steve", "Wilson", "Mark", 
			"James", "Stephanie", "Markus", "Margaret" }
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
			timerMax = 1.75 * (1/Game.speed),
			timerCur = 1.75 * (1/Game.speed)
		}
	end,
	gameOver = function(self, res)
		self.over = true
		Game.result = res
		self.timer:add(2 * (1/Game.speed), function() Venus.switch(results) end)
	end
}

function highFive:init()
	self.timer = Timer.new()
end

function highFive:entering()
	self.over = false
	self:newTarget()
	countdown:reset()
	countdown:start()
end

function highFive:keypressed(key, scancode, isRepeat)
	if isRepeat then return end
	if self.over then return end
	if not countdown:over() then return end
	
	if (self.target.name == "Mark") or (key == Controls["LEFT"] and self.target.hand == 1) or 
		(key == Controls["RIGHT"] and self.target.hand == -1) then
		self:gameOver("LOSE")
	elseif self.target.name ~= "Mark" then
		self:newTarget()
	end
end

function highFive:update(dt)
	if Game.paused then return end
	if not countdown:over() then
		countdown:update(dt)
		return
	end
	if self.over then return end

	self.target.timerCur = self.target.timerCur - dt
	if self.target.timerCur <= 0 then
		if self.target.name == "Mark" then
			self:gameOver("WIN")
		else
			self:gameOver("LOSE")
		end
	end
	self.timer:update(dt)
end

function highFive:draw()
	preDraw()
	love.graphics.setBackgroundColor(30, 30, 30)

	love.graphics.setColor(255, 255, 255)
	for i, j in ipairs(self.target.face) do
		love.graphics.draw(j, Game.original.w/2 - j:getWidth()/2, 40)
	end
	love.graphics.circle("fill", Game.original.w/2 + self.target.hand * 150, 200, 20)
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

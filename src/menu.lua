local gameRoulette = require "src.gameRoulette"

local LEFT = -Game.original.w
local RIGHT = Game.original.w
local UP = -Game.original.h
local DOWN = Game.original.h
local SHOW = 0
local DELAY = 0.15
local lvl2MenuBG = function()
	love.graphics.setColor(100, 100, 100)
	love.graphics.rectangle("fill", 20, 20, Game.original.w - 40, Game.original.h - 40)
end
local lvl1MenuBG = function()
	love.graphics.setColor(70, 70, 70)
	love.graphics.rectangle("fill", 10, 10, Game.original.w - 20, Game.original.h - 20)
end
local colorAtMenuLVL = {
	[0] = { 170, 170, 170 },
	{ 200, 200, 200 },
	{ 220, 220, 220 }
}
local triangles = {
	UP = love.graphics.newMesh({ { -5, 5 }, { 0, -5 }, { 5, 5 } }),
	DOWN = love.graphics.newMesh({ { 5, -5 }, { 0, 5 }, { -5, -5 } }),
	LEFT = love.graphics.newMesh({ { 5, -5 }, { 5, 5 }, { -5, 0 } }),
	RIGHT = love.graphics.newMesh({ { -5, 5 }, { -5, -5 }, { 5, 0 } })
}
local drawInstructions = function(inst, menuLVL, noC)
	local margin = menuLVL and 5 + (menuLVL + 1) * 10 or 0
	for i, j in pairs(inst) do
		local trianglePos = {
			UP = {
				Game.original.w/2,
				margin
			},
			DOWN = {
				Game.original.w/2,
				Game.original.h - margin
			},
			LEFT = {
				margin,
				Game.original.h/2
			},
			RIGHT = {
				Game.original.w - margin,
				Game.original.h/2
			}
		}
		local textPos = {
			UP = {
				Game.original.w/2 - Game.font14:getWidth(j)/2,
				margin + 10
			},
			DOWN = {
				Game.original.w/2 - Game.font14:getWidth(j)/2,
				Game.original.h - margin - 10 - Game.font14:getHeight()
			},
			LEFT = {
				margin + 10,
				Game.original.h/2 - Game.font14:getHeight()/2
			},
			RIGHT = {
				Game.original.w - margin - 10 - Game.font14:getWidth(j),
				Game.original.h/2 - Game.font14:getHeight()/2
			}
		}
		if not noC then love.graphics.setColor(colorAtMenuLVL[menuLVL]) end
		love.graphics.setFont(Game.font14)
		love.graphics.print(j, math.floor(textPos[i][1]), math.floor(textPos[i][2]))
		love.graphics.draw(triangles[i], trianglePos[i][1], trianglePos[i][2])
	end
end
local printCenter = function(text, digits)
	if digits and (""..text):find("%.") then 
		text = (""..text):sub(1, (""..text):find("%.") + 2)
	end
	love.graphics.print(text, Game.original.w/2 - love.graphics.getFont():getWidth(text)/2, 
		Game.original.h/2 - love.graphics.getFont():getHeight()/2)
end
local voidHandle = function(menu, index)
	if menu.structure[index].handle then
		menu.timer:cancel(menu.structure[index].handle)
		menu.structure[index].handle = nil
	end
end
local menu = {
	structure = {
		[-3] = { -- secret
			origPos = UP,
			pos = UP,
			face = {},
			draw = function(self, menu)
				lvl1MenuBG()
				love.graphics.setColor(255, 255, 255)
				for i, j in ipairs(self.face) do
					love.graphics.draw(j, Game.original.w/2 - j:getWidth()/2, 30)
				end
				love.graphics.setColor(30, 30, 30)
				love.graphics.setFont(Game.font20)
				love.graphics.push()
				love.graphics.translate(0, -127)
				printCenter("Secret found!")
				love.graphics.pop()
				drawInstructions({ DOWN = "Back" }, 1, true)
			end
		},
		[-2] = { -- freeplay game speed
			origPos = LEFT,
			pos = LEFT,
			speed = 1,
			draw = function(self, menu)
				lvl2MenuBG()
				drawInstructions({ LEFT = "Start", RIGHT = "Back", UP = "Speed UP", DOWN = "Speed DOWN" }, 2)
				love.graphics.setColor(colorAtMenuLVL[2])
				love.graphics.setFont(Game.font70)
				printCenter(self.speed, true)
			end
		},
		[-1] = { -- freeplay minigame
			origPos = LEFT,
			pos = LEFT,
			index = 1,
			draw = function(self, menu)
				lvl1MenuBG()
				drawInstructions({ LEFT = "Next", RIGHT = "Back", UP = "Select game", DOWN = "Select game" }, 1)
				love.graphics.setColor(colorAtMenuLVL[1])
				drawMinigameInfo(self.index, { 80, 80, 80 }, colorAtMenuLVL[2])
			end	
		},
		[0] = { -- main screen
			origPos = SHOW,
			pos = SHOW,
			draw = function(self, menu)
				drawInstructions({ LEFT = "Freeplay", RIGHT = "Endurance", DOWN = "Quit" }, 0)
				love.graphics.setFont(Game.font70)
				love.graphics.setColor(colorAtMenuLVL[0])
				love.graphics.print("UNKO", math.floor(Game.original.w/2 - Game.font70:getWidth("UNKO")/2),
					math.floor(Game.original.h/4 - Game.font70:getHeight()/2))
			end
		},
		{ -- endurance initial lives
			origPos = RIGHT,
			pos = RIGHT,
			lives = 3,
			draw = function(self, menu)
				lvl1MenuBG()
				drawInstructions({ LEFT = "Back", RIGHT = "Next", UP = "Lives UP", DOWN = "Lives DOWN" }, 1)
				love.graphics.setColor(colorAtMenuLVL[1])
				love.graphics.setFont(Game.font70)
				printCenter(self.lives)
			end
		},
		{ -- endurance initial speed
			origPos = RIGHT,
			pos = RIGHT,
			speed = 1,
			draw = function(self, menu)
				lvl2MenuBG()
				drawInstructions({ LEFT = "Back", RIGHT = "Start", UP = "Speed UP", DOWN = "Speed DOWN" }, 2)
				love.graphics.setColor(colorAtMenuLVL[2])
				love.graphics.setFont(Game.font70)
				printCenter(self.speed, true)
			end
		},
		{ -- quit confirm
			origPos = DOWN,
			pos = DOWN,
			draw = function(self, menu)
				lvl1MenuBG()
				drawInstructions({ DOWN = "Quit", UP = "Back" }, 1)
				love.graphics.setColor(colorAtMenuLVL[1])
				love.graphics.setFont(Game.font40)
				printCenter("Had enough?")
			end
		}
	},
	screen = 0,
	timer = Timer.new()
}

local bindingsEvent = {
	LEFT = function(menu)
		if math.abs(menu.screen) == 3 then 
			return 
		end
		if menu.screen - 1 < -2 then
			love.audio.play(Game.sources.selection)
			Game.mode = "FP"
			Game.speed = menu.structure[-2].speed
			setPitch()
			Venus.duration = (1/Game.speed) * Game.fadeDuration
			Venus.switch(Game.minigames[Game.minigameNames[menu.structure[-1].index] ])
		else
			love.audio.play(Game.sources.blip)
			if (menu.screen > 0) then
				voidHandle(menu, menu.screen)
				menu.structure[menu.screen].handle = 
					menu.timer:tween(DELAY, menu.structure[menu.screen], { pos = menu.structure[menu.screen].origPos }, "in-out-quad")
			end
			voidHandle(menu, menu.screen - 1)
			menu.structure[menu.screen - 1].handle =
				menu.timer:tween(DELAY, menu.structure[menu.screen - 1], { pos = SHOW }, "in-out-quad")
		end
		menu.screen = math.max(-2, menu.screen - 1)
	end,
	RIGHT = function(menu)
		if math.abs(menu.screen) == 3 then 
			return 
		end
		if menu.screen + 1 > 2 then 
			love.audio.play(Game.sources.selection)
			Game.mode = "END"
			Game.speed = menu.structure[2].speed
			setPitch()
			Venus.duration = (1/Game.speed) * Game.fadeDuration
			Game.maxLives = menu.structure[1].lives
			Game.curLives = Game.maxLives
			Venus.switch(gameRoulette)
		else
			love.audio.play(Game.sources.blip)
			if (menu.screen < 0) then 
				voidHandle(menu, menu.screen)
				menu.structure[menu.screen].handle =
					menu.timer:tween(DELAY, menu.structure[menu.screen], { pos = menu.structure[menu.screen].origPos }, "in-out-quad")
			end
			voidHandle(menu, menu.screen + 1)
			menu.structure[menu.screen + 1].handle =
				menu.timer:tween(DELAY, menu.structure[menu.screen + 1], { pos = SHOW }, "in-out-quad")
		end
		menu.screen = math.min(2, menu.screen + 1)
	end,
	UP = function(menu)
		if (menu.screen == 0 or menu.screen == 3) then
			love.audio.play(Game.sources.blip)
			voidHandle(menu, menu.screen)
			menu.structure[menu.screen].handle = 
				menu.timer:tween(DELAY, menu.structure[menu.screen], { pos = menu.structure[menu.screen].origPos }, "in-out-quad")
			menu.screen = menu.screen - 3
			voidHandle(menu, menu.screen)
			menu.structure[menu.screen].handle =
				menu.timer:tween(DELAY, menu.structure[menu.screen], { pos = SHOW }, "in-out-quad")
		elseif (menu.screen == 1) then
			local l = menu.structure[menu.screen].lives
			if (l + 1 <= 5) then	
				love.audio.play(Game.sources.blip)
			else
				love.audio.play(Game.sources.errorBlip)
			end
			menu.structure[menu.screen].lives = math.min(5, l + 1)
		elseif (menu.screen == -1) then
			love.audio.play(Game.sources.blip)
			local i = menu.structure[menu.screen].index - 1
			if i < 1 then i = i + #Game.minigameNames end
			menu.structure[menu.screen].index = i
		end
	end,
	DOWN = function(menu)
		if (menu.screen == 0 or menu.screen == -3) then
			love.audio.play(Game.sources.blip)
			voidHandle(menu, menu.screen)
			menu.structure[menu.screen].handle = 
				menu.timer:tween(DELAY, menu.structure[menu.screen], { pos = menu.structure[menu.screen].origPos }, "in-out-quad")
			menu.screen = menu.screen + 3
			voidHandle(menu, menu.screen)
			menu.structure[menu.screen].handle = 
				menu.timer:tween(DELAY, menu.structure[menu.screen], { pos = SHOW }, "in-out-quad")
		elseif (menu.screen == 3) then
			love.event.quit()
		elseif (menu.screen == 1) then
			local l = menu.structure[menu.screen].lives
			if (l - 1 >= 1) then
				love.audio.play(Game.sources.blip)
			else
				love.audio.play(Game.sources.errorBlip)
			end
			menu.structure[menu.screen].lives = math.max(1, l - 1)
		elseif (menu.screen == -1) then
			love.audio.play(Game.sources.blip)
			local i = menu.structure[menu.screen].index + 1
			if i > #Game.minigameNames then i = i - #Game.minigameNames end
			menu.structure[menu.screen].index = i
		end
	end
}

local bindingsUpdate = {
	UP = function(menu, dt)
		if (math.abs(menu.screen) == 2) then
			local s = menu.structure[menu.screen].speed
			
			if s + dt < Game.maxSpeed then
				menu.scrolled = 1
			else
				menu.scrolled = 2
			end
			menu.structure[menu.screen].speed = math.min(Game.maxSpeed, s + dt)
		end
	end,
	DOWN = function(menu, dt)
		if (math.abs(menu.screen) == 2) then
			local s = menu.structure[menu.screen].speed
			
			if s - dt > Game.minSpeed then
				menu.scrolled = 1
			else
				menu.scrolled = 2
			end
			menu.structure[menu.screen].speed = math.max(Game.minSpeed, s - dt)
		end
	end
}

function menu:entering()
	Game.speed = 1
	setPitch()
	self.timer:clear()
	self.structure[-3].face = {
		Game.face.base
	}
	local order = { "", "hat", "eyes", "mouth", "nose" }
	for i = 2, 5 do
		self.structure[-3].face[i] = Game.face[order[i] ][math.random(1, 4)]
		self.timer:addPeriodic(0.25 + 0.5 * math.random(), function() menu.structure[-3].face[i] = 
			Game.face[order[i] ][math.random(1, 4)] end)
	end
	self.screen = 0
	for i = -3, 3 do
		self.structure[i].pos = self.structure[i].origPos
	end
end

function menu:keypressed(key, scancode, isRepeat)
	if Game.paused then return end
	for i, j in pairs(Controls) do
		if j == key and bindingsEvent[i] then bindingsEvent[i](self) end
	end
end

function menu:update(dt)
	if Game.paused then return end
	self.timer:update(dt)
	self.scrolledLast = self.scrolled
	if not self.scrolledLast then self.scrolledLast = 0 end
	self.scrolled = 0
	local buttons = 0
	for i, j in pairs(bindingsUpdate) do
		if love.keyboard.isDown(Controls[i]) then 
			buttons = buttons + 1
			j(self, dt) 
		end
	end
	if self.scrolled == 0 or buttons == 2 then
		if self.scrolling then
			self.scrolling:pause()
			self.scrolling = nil
		end
	elseif self.scrolled == 1 and not self.scrolling then
		self.scrolling = love.audio.play(Game.sources.rolling)
	elseif self.scrolled == 2 and not self.scrolling then
		self.scrolling = love.audio.play(Game.sources.rollingError)
	elseif self.scrolledLast ~= self.scrolled then
		self.scrolling:pause()
		self.scrolling = (self.scrolled == 1 and love.audio.play(Game.sources.rolling) or love.audio.play(Game.sources.rollingError))
	end
end

function menu:draw()
	love.graphics.setBackgroundColor(30, 30, 30)
	preDraw()
	local drawScreen = function(scr, trY)
		if (math.abs(scr.pos - scr.origPos) > 0.01) or (scr.origPos == SHOW) then
			love.graphics.push()
			if not trY then
				love.graphics.translate(scr.pos, 0)
			else
				love.graphics.translate(0, scr.pos)
			end
			scr:draw(self)
			love.graphics.pop()
		end
	end
	for i = 0, 2, 1 do
		drawScreen(self.structure[i])
	end
	for i = -1, -2, -1 do
		drawScreen(self.structure[i])
	end
	for i = -3, 3, 6 do
		drawScreen(self.structure[i], true)
	end
	postDraw()
end

return menu

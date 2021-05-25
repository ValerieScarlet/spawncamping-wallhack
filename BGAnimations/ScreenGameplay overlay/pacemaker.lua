local baseline = SCREEN_HEIGHT*0.39											
local meterheight = SCREEN_HEIGHT*0.75
local notes = GAMESTATE:GetCurrentSteps(pn):GetRadarValues(pn):GetValue(0)
local progress = 0
local maxcombo = 0
local percent
local passflag = 0
local target = playerConfig:get_data(pn_to_profile_slot(PLAYER_1)).TargetGoal
local targetTrackerMode = playerConfig:get_data(pn_to_profile_slot(PLAYER_1)).TargetTrackerMode
local color1 = color("#4073bf")--getMainColor("highlight")
local color2 = color("#6abf40")
local color3 =color("#bf4048")

local t = Def.ActorFrame{
	Name="Pacemaker",
	InitCommand=function(self)
		self:xy(SCREEN_WIDTH*11/12,SCREEN_CENTER_Y)
	end;
	JudgmentMessageCommand=function (self,msg)
	if msg.Judgment == "TapNoteScore_W1" or
		msg.Judgment == "TapNoteScore_W2" or
		msg.Judgment == "TapNoteScore_W3" or
		msg.Judgment == "TapNoteScore_W4" or
		msg.Judgment == "TapNoteScore_W5" or
		msg.Judgment == "TapNoteScore_Miss" then
		progress = progress + 1
		percent = msg.WifePercent
		self:playcommand("Update")
	end
	if targetTrackerMode == 1 and msg.WifePBGoal ~= nil and progress <= 1 then
		target = msg.WifePBGoal*100
		self:queuecommand("Update2")
	end
	end;
	--base
	Def.Quad{
		InitCommand=function(self)
			self:zoomto(SCREEN_WIDTH/6,SCREEN_HEIGHT)
			self:diffuse(.05,.05,.05,0.8)
		end;
	},
	--current score meter
	Def.Quad{
		InitCommand=function(self)
			self:xy(-0.03*SCREEN_WIDTH,baseline):align(0.5,1)
			self:zoomto(SCREEN_WIDTH*0.05,0)
			self:diffuse(color1)
			self:diffusealpha(0.75)
			self:glowshift():effectcolor1(0.5,0.5,0.5,0.4):effectcolor2(0.75,0.75,0.75,0.5):effectperiod(2)
		end;
		UpdateCommand=function (self,msg)
			if percent < 0 then
				self: zoomtoheight(0)
			else
				self:zoomtoheight(meterheight*percent/100):croptop(1-(progress/notes))
			end
		end
	},

	--target score meter
	Def.Quad{
		InitCommand=function(self)
			self:xy(0.03*SCREEN_WIDTH,baseline):align(0.5,1)
			self:zoomto(SCREEN_WIDTH*0.05,meterheight*target/100)
			self:diffuse(.5,.5,.5,0.5)
		end;
		Update2Command=function (self,msg)
				self:zoomtoheight(meterheight*target/100)
		end
	},
	Def.Quad{
		OnCommand=function(self)
			self:xy(0.03*SCREEN_WIDTH,baseline):align(0.5,1)
			self:zoomto(SCREEN_WIDTH*0.05-3,meterheight*target/100-1.5)
			self:MaskSource()
		end;
		Update2Command=function (self)
			self:zoomtoheight(meterheight*target/100-1.5)
		end
	},
	Def.Quad{
		InitCommand=function(self)
			self:xy(0.03*SCREEN_WIDTH,baseline):align(0.5,1)
			self:zoomto(SCREEN_WIDTH*0.05,meterheight*target/100)
			self:diffuse(1,1,1,0.5)
			self:MaskDest()
		end;
		UpdateCommand=function (self)
			self:cropbottom(progress/notes)
		end;
		Update2Command=function (self,msg)
				self:zoomtoheight(meterheight*target/100)
		end
	},
	Def.Quad{
		InitCommand=function(self)
			self:xy(0.03*SCREEN_WIDTH,baseline):align(0.5,1)
			self:zoomto(SCREEN_WIDTH*0.05,0)
			self:diffuse(color2)
			self:diffusealpha(0.75)
			self:glowshift():effectcolor1(0.5,0.5,0.5,0.4):effectcolor2(0.75,0.75,0.75,0.5):effectperiod(2)
		end;
		UpdateCommand=function (self)
			self:zoomtoheight(meterheight*target/100):croptop(1-(progress/notes))
		end;
			Update2Command=function(self)
			self:diffuse(color3)
			self:diffusealpha(0.5)
			end
	},
	--label
	Def.ActorFrame{
		InitCommand=function(self)
			self:xy(-1/24*SCREEN_WIDTH+0.7,baseline+12)
		end;
		Def.Quad{
			InitCommand=function(self)
				self:zoomto(1/12*SCREEN_WIDTH-4,15)
				self:diffuse(color1):glow(0.5,0.5,0.5,0.5)
				self:diffusealpha(0.7)
			end;
		};
		Def.BitmapText{
			Font="Common normal",
			InitCommand=function(self)
				self:settext("CURRENT SCORE")
				self:zoom(0.4):maxwidth(160):y(-1)
			end;
		}
	};
	Def.ActorFrame{
		InitCommand=function(self)
			self:xy(1/24*SCREEN_WIDTH-0.7,baseline+12)
		end;
		Def.Quad{
			InitCommand=function(self)
				self:zoomto(1/12*SCREEN_WIDTH-4,15)
				self:diffuse(color2):glow(0.5,0.5,0.5,0.5)
				self:diffusealpha(0.7)
			end;
			Update2Command=function(self)
				self:diffuse(color3)
				self:diffusealpha(0.7)
			end
		};
		Def.BitmapText{
			Font="Common normal",
			InitCommand=function(self)
				self:settext("SET PERCENT")
				self:zoom(0.4):maxwidth(160):y(-1)
			end;
			Update2Command=function(self)
				self:settext("PERSONAL BEST")
			end
		}
	};
	--overlay
	Def.ActorFrame{
		--score point
		Def.BitmapText{
			Font="Common normal",
			InitCommand=function(self)
				self:settextf("%2.2f",0)
				self:xy(-0.03*SCREEN_WIDTH,baseline-2):align(0.5,1):zoom(0.45)
			end;
			UpdateCommand=function (self,msg)
				self:settextf("%2.2f",progress*percent/50)
			end
		};
		Def.BitmapText{
			Font="Common normal",
			InitCommand=function(self)
				self:settextf("%2.2f",0)
				self:xy(0.03*SCREEN_WIDTH,baseline-2):align(0.5,1):zoom(0.45)
			end;
			UpdateCommand=function (self,msg)
				self:settextf("%2.2f",progress*target/50)
			end
		};
		--pass flag
		LoadFont("Common normal") ..{
			InitCommand=function(self)
				self:xy(0,baseline-(meterheight*0.997)-2):align(0.5,1):zoom(0.5)
				self:diffusealpha(0)
			end;
			UpdateCommand=function (self)
				if progress/notes*percent>60  and passflag == 0 then
					passflag = 1
					self:stoptweening()
					self:settext("Rank C Pass"):y(baseline-(meterheight*0.6)-3)
					self:diffusealpha(0):x(SCREEN_WIDTH/6):linear(0.2):diffusealpha(1):x(0)
					self:sleep(1):linear(0.2):x(SCREEN_WIDTH/6)
					self:sleep(1):linear(0.2):x(SCREEN_WIDTH/6)
				elseif progress/notes*percent>70  and passflag == 1 then
					passflag = 2
					self:stoptweening()
					self:settext("Rank B Pass"):y(baseline-(meterheight*0.7)-3)
					self:diffusealpha(0):x(SCREEN_WIDTH/6):linear(0.2):diffusealpha(1):x(0)
					self:sleep(1):linear(0.2):x(SCREEN_WIDTH/6)
				elseif progress/notes*percent>80  and passflag == 2 then
					passflag = 3
					self:stoptweening()
					self:settext("Rank A Pass"):y(baseline-(meterheight*0.8)-3)
					self:diffusealpha(0):x(SCREEN_WIDTH/6):linear(0.2):diffusealpha(1):x(0)
					self:sleep(1):linear(0.2):x(SCREEN_WIDTH/6)
				elseif progress/notes*percent>93  and passflag == 3 then
					passflag = 4
					self:stoptweening()
					self:settext("Rank AA Pass"):y(baseline-(meterheight*0.93)-3)
					self:diffusealpha(0):x(SCREEN_WIDTH/6):linear(0.2):diffusealpha(1):x(0)
					self:sleep(1):linear(0.2):x(SCREEN_WIDTH/6)
				elseif progress/notes*percent>99.7 and progress/notes*percent <99.955  and passflag == 4 then
					passflag = 5
					self:stoptweening()
					self:settext("Rank AAA Pass"):y(baseline-(meterheight*0.997)-3)
					self:diffusealpha(0):x(SCREEN_WIDTH/6):linear(0.2):diffusealpha(1):x(0)
					self:sleep(1):linear(0.2):x(SCREEN_WIDTH/6)
				elseif progress/notes*percent>=99.955 and progress/notes*percent <99.9935 and passflag < 6 then
					passflag = 6
					self:stoptweening()
					self:settext("Rank AAAA Pass"):y(baseline-(meterheight*0.99955)-3)
					self:diffusealpha(0):x(SCREEN_WIDTH/6):linear(0.2):diffusealpha(1):x(0)
					self:sleep(1):linear(0.2):x(SCREEN_WIDTH/6)
				elseif progress/notes*percent>=99.9935 and passflag < 7 then
					passflag = 7
					self:stoptweening()
					self:settext("Rank AAAAA Pass"):y(baseline-(meterheight)-3)
					self:diffusealpha(0):x(SCREEN_WIDTH/6):linear(0.2):diffusealpha(1):x(0)
					self:sleep(1):linear(0.2):x(SCREEN_WIDTH/6)
				end
			end
		},
		Def.Quad{
			InitCommand=function(self)
				self:zoomto(SCREEN_WIDTH/6,2):y(baseline):align(0.5,0)
				self:diffusealpha(0.5)
			end;
		},
		--AAA
		Def.Quad{
			InitCommand=function(self)
				self:zoomto(SCREEN_WIDTH/6,2):y(baseline-(meterheight*0.997)):align(0.5,1)
				self:diffusealpha(0.5)
			end;
			UpdateCommand=function (self)
				if progress/notes*percent>99.7 then
					self:diffuse(1,1,0,0.7)
				end
			end
		},
		LoadFont("Common normal") ..{
			InitCommand=function(self)
				self:xy(-1/12*SCREEN_WIDTH+1,baseline-(meterheight*0.997)-2):align(0,1):settext("AAA"):zoom(0.4)
				self:diffusealpha(0.3)
			end;
			UpdateCommand=function (self)
				if progress/notes*percent>=99.9935 then
					self:diffuse(0.5,1,1,1):settext("AAAAA")
				elseif progress/notes*percent>=99.955 then
					self:diffuse(0.5,1,1,1):settext("AAAA")
				elseif progress/notes*percent>=99.7 then
					self:diffuse(1,0.8,0.5,1)
				end
			end
		},
		--AA
		Def.Quad{
			InitCommand=function(self)
				self:zoomto(SCREEN_WIDTH/6,2):y(baseline-(meterheight*0.93)):align(0.5,1)
				self:diffusealpha(0.3)
			end;
			UpdateCommand=function (self)
				if progress/notes*percent>93 then
					self:diffuse(1,1,0,0.5)
				end
			end
		},
		LoadFont("Common normal") ..{
			InitCommand=function(self)
				self:xy(-1/12*SCREEN_WIDTH+1,baseline-(meterheight*0.93)-2):align(0,1):settext("AA"):zoom(0.4)
				self:diffusealpha(0.3)
			end;
			UpdateCommand=function (self)
				if progress/notes*percent>93 then
					self:diffuse(0.5,1,0.5,1)
				end
			end
		},
		--A
		Def.Quad{
			InitCommand=function(self)
				self:zoomto(SCREEN_WIDTH/6,2):y(baseline-(meterheight*0.8)):align(0.5,1)
				self:diffusealpha(0.3)
			end;
			UpdateCommand=function (self)
				if progress/notes*percent>80 then
					self:diffuse(1,1,0,0.5)
				end
			end
		},
		LoadFont("Common normal") ..{
			InitCommand=function(self)
				self:xy(-1/12*SCREEN_WIDTH+1,baseline-(meterheight*0.8)-2):align(0,1):settext("A"):zoom(0.4)
				self:diffusealpha(0.3)
			end;
			UpdateCommand=function (self)
				if progress/notes*percent>80 then
					self:diffuse(1,0.5,0.5,1)
				end
			end
		},
		--B
		Def.Quad{
			InitCommand=function(self)
				self:zoomto(SCREEN_WIDTH/6,2):y(baseline-(meterheight*0.7)):align(0.5,1)
				self:diffusealpha(0.3)
			end;
			UpdateCommand=function (self)
				if progress/notes*percent>70 then
					self:diffuse(1,1,0,0.5)
				end
			end
		},
		LoadFont("Common normal") ..{
			InitCommand=function(self)
				self:xy(-1/12*SCREEN_WIDTH+1,baseline-(meterheight*0.7)-2):align(0,1):settext("B"):zoom(0.4)
				self:diffusealpha(0.3)
			end;
			UpdateCommand=function (self)
				if progress/notes*percent>70 then
					self:diffuse(0.4,0.5,1,1)
				end
			end
		},
		--C
		Def.Quad{
			InitCommand=function(self)
				self:zoomto(SCREEN_WIDTH/6,2):y(baseline-(meterheight*0.6)):align(0.5,1)
				self:diffusealpha(0.3)
			end;
			UpdateCommand=function (self)
				if progress/notes*percent>60 then
					self:diffuse(1,1,0,0.5)
				end
			end
		},
		LoadFont("Common normal") ..{
			InitCommand=function(self)
				self:xy(-1/12*SCREEN_WIDTH+1,baseline-(meterheight*0.6)-2):align(0,1):settext("C"):zoom(0.4)
				self:diffusealpha(0.3)
			end;
			UpdateCommand=function (self)
				if progress/notes*percent>60 then
					self:diffuse(0.8,0.5,1,1)
				end
			end
		},
	},
}



return t
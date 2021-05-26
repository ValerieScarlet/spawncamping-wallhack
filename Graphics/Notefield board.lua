local t = Def.ActorFrame{}


local function ScreenFilter()
	return Def.Quad{
		InitCommand = function(self)
			self:visible(false)
		end,
		PlayerStateSetCommand = function(self,param)
			local pn = param.PlayerNumber
			local style = GAMESTATE:GetCurrentStyle(pn)
			local cols = style:ColumnsPerPlayer()
			local evenCols = cols - cols%2
			local width = style:GetWidth(pn) + 8 + (MovableValues.NotefieldSpacing and MovableValues.NotefieldSpacing or 0) * evenCols
			local filterColor = color(colorConfig:get_data().gameplay.ScreenFilter)
			local filterAlpha = playerConfig:get_data(pn_to_profile_slot(pn)).ScreenFilter
			if filterAlpha == 0 then
				self:visible(false)
				return
			end
			self:visible(true)
			self:SetWidth(width)
			self:addx(cols % 2 == 0 and -(MovableValues.NotefieldSpacing and MovableValues.NotefieldSpacing or 0) / 2 or 0)
			self:SetHeight(SCREEN_HEIGHT*4096)
			self:diffuse(filterColor)
			self:diffusealpha(filterAlpha)
		end
	}
end

local function LaneHighlight()
	local t = Def.ActorFrame{}
	local alpha = 0.4
	local judgeThreshold = Enum.Reverse(TapNoteScore)[playerConfig:get_data(pn_to_profile_slot(PLAYER_1)).CBHighlightMinJudge]

	local style = GAMESTATE:GetCurrentStyle(PLAYER_1)
	local width = style:GetWidth(PLAYER_1)
	local cols = style:ColumnsPerPlayer()
	local colWidth = width/cols
	local hCols = math.floor(cols / 2)
	local reverse = GAMESTATE:GetPlayerState():GetCurrentPlayerOptions():UsingReverse()
	local receptor = reverse and THEME:GetMetric("Player", "ReceptorArrowsYStandard") or THEME:GetMetric("Player", "ReceptorArrowsYReverse")
	local border = 4

	for i=1,cols do
		t[#t+1] = Def.Quad{
			InitCommand = function(self)
				self:visible(false)
			end,
			PlayerStateSetCommand = function(self,param)
				self:SetWidth(colWidth-border)
				self:SetHeight(SCREEN_HEIGHT)
				self:diffusealpha(alpha)
				self:xy((i-(cols/2)-(1/2))*colWidth,-receptor)
				self:addx((i - hCols - 1) * (MovableValues.NotefieldSpacing and MovableValues.NotefieldSpacing or 0))
				self:fadebottom(0.6):fadetop(0.6)
				self:visible(false)
			end,
			JudgmentMessageCommand=function(self,params)
				local notes = params.Notes
				local firstTrack = params.FirstTrack+1

				if params.HoldNoteScore or params.FromReplay then return end

				if params.TapNoteScore then
					local enum  = Enum.Reverse(TapNoteScore)[params.TapNoteScore]

					if enum <= judgeThreshold and enum > 3 and
						i == firstTrack then

						self:stoptweening()
						self:visible(true)
						self:diffuse(color(colorConfig:get_data().judgment[params.TapNoteScore]))
						self:diffusealpha(alpha)
						self:easeIn(0.25)
						self:diffusealpha(0)
					end
				end
			end
		}
	end

	return t
end


t[#t+1] = ScreenFilter()

local highlightEnabled = playerConfig:get_data(pn_to_profile_slot(PLAYER_1)).CBHighlight
if highlightEnabled then
	t[#t+1] = LaneHighlight()
end

return t
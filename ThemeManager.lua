local cloneref = (cloneref or clonereference or function(instance: any)
    return instance
end)
local clonefunction = (clonefunction or copyfunction or function(func)
    return func
end)

local httprequest = request or http_request or (http and http.request)
local getassetfunc = getcustomasset

local HttpService: HttpService = cloneref(game:GetService("HttpService"))
local RunService: RunService = cloneref(game:GetService("RunService"))
local isfolder, isfile, listfiles = isfolder, isfile, listfiles;

local assert = function(condition, errorMessage)
    if (not condition) then
        error(if errorMessage then errorMessage else "assert failed", 3)
    end
end

if typeof(clonefunction) == "function" then

    local
        isfolder_copy,
        isfile_copy,
        listfiles_copy = clonefunction(isfolder), clonefunction(isfile), clonefunction(listfiles)

    local isfolder_success, isfolder_error = pcall(function()
        return isfolder_copy("test" .. tostring(math.random(1000000, 9999999)))
    end)

    if isfolder_success == false or typeof(isfolder_error) ~= "boolean" then
        isfolder = function(folder)
            local success, data = pcall(isfolder_copy, folder)
            return (if success then data else false)
        end

        isfile = function(file)
            local success, data = pcall(isfile_copy, file)
            return (if success then data else false)
        end

        listfiles = function(folder)
            local success, data = pcall(listfiles_copy, folder)
            return (if success then data else {})
        end
    end
end

local ThemeManager = {} do
	local ThemeFields = { "FontColor", "MainColor", "AccentColor", "BackgroundColor", "OutlineColor", "VideoLink" }
	ThemeManager.Folder = "LinoriaLibSettings"

	ThemeManager.Library = nil
	ThemeManager.BuiltInThemes = {
		['Default']       = { 1, { FontColor = "ffffff", MainColor = "1c1c1c", AccentColor = "0055ff", BackgroundColor = "141414", OutlineColor = "323232" } },
		['BBot']          = { 2, { FontColor = "ffffff", MainColor = "1e1e1e", AccentColor = "7e48a3", BackgroundColor = "232323", OutlineColor = "141414" } },
		['Fatality']      = { 3, { FontColor = "ffffff", MainColor = "1e1842", AccentColor = "c50754", BackgroundColor = "191335", OutlineColor = "3c355d" } },
		['Jester']        = { 4, { FontColor = "ffffff", MainColor = "242424", AccentColor = "db4467", BackgroundColor = "1c1c1c", OutlineColor = "373737" } },
		['Mint']          = { 5, { FontColor = "ffffff", MainColor = "242424", AccentColor = "3db488", BackgroundColor = "1c1c1c", OutlineColor = "373737" } },
		['Tokyo Night']   = { 6, { FontColor = "ffffff", MainColor = "191925", AccentColor = "6759b3", BackgroundColor = "16161f", OutlineColor = "323232" } },
		['Ubuntu']        = { 7, { FontColor = "ffffff", MainColor = "3e3e3e", AccentColor = "e2581e", BackgroundColor = "323232", OutlineColor = "191919" } },
		['Quartz']        = { 8, { FontColor = "ffffff", MainColor = "232330", AccentColor = "426e87", BackgroundColor = "1d1b26", OutlineColor = "27232f" } },
		['Halloween']     = { 9, { FontColor = "ffe9d2", MainColor = "17111f", AccentColor = "ff7a00", BackgroundColor = "0d0912", OutlineColor = "3a2650" } },
	}

	function ApplyBackgroundVideo(videoLink)
		if
			typeof(videoLink) ~= "string" or
			not (getassetfunc and writefile and readfile and isfile) or
			not (ThemeManager.Library and ThemeManager.Library.InnerVideoBackground)
		then return; end;

		local videoInstance = ThemeManager.Library.InnerVideoBackground;
		local extension = videoLink:match(".*/(.-)?") or videoLink:match(".*/(.-)$"); extension = tostring(extension);
		local filename = string.sub(extension, 0, -6);
		local _, domain = videoLink:match("^(https?://)([^/]+)"); domain = tostring(domain);

		if videoLink == "" then
			videoInstance:Pause();
			videoInstance.Video = "";
			videoInstance.Visible = false;
			return
		end
		if #extension > 5 and string.sub(extension, -5) ~= ".webm" then return; end;

		local videoFile = ThemeManager.Folder .. "/themes/" .. string.gsub(domain .. filename, 0, 249) .. ".webm";
		if not isfile(videoFile) then
			local success, requestRes = pcall(httprequest, { Url = videoLink, Method = 'GET' })
			if not (success and typeof(requestRes) == "table" and typeof(requestRes.Body) == "string") then return; end;

			writefile(videoFile, requestRes.Body)
		end

		videoInstance.Video = getassetfunc(videoFile);
		videoInstance.Visible = true;
		videoInstance:Play();
	end

	function ThemeManager:SetLibrary(library)
		self.Library = library
	end

	function ThemeManager:GetPaths()
	    local paths = {}

		local parts = self.Folder:split('/')
		for idx = 1, #parts do
			paths[#paths + 1] = table.concat(parts, '/', 1, idx)
		end

		paths[#paths + 1] = self.Folder .. '/themes'

		return paths
	end

	function ThemeManager:BuildFolderTree()
		local paths = self:GetPaths()

		for i = 1, #paths do
			local str = paths[i]
			if isfolder(str) then continue end
			makefolder(str)
		end
	end

	function ThemeManager:CheckFolderTree()
		if isfolder(self.Folder) then return end
		self:BuildFolderTree()

		task.wait(0.1)
	end

	function ThemeManager:SetFolder(folder)
		self.Folder = folder;
		self:BuildFolderTree()
	end

	function ThemeManager:ClearDecoration()
		if self.DecorationConnection then
			self.DecorationConnection:Disconnect()
			self.DecorationConnection = nil
		end

		if self.Decoration then
			self.Decoration:Destroy()
			self.Decoration = nil
		end
	end

	local function CreateLine(parent, ox, oy, a, b, color, transparency, thickness, zindex)
		local delta = b - a
		local mid = (a + b) / 2

		local line = Instance.new("Frame")
		line.AnchorPoint = Vector2.new(0.5, 0.5)
		line.Position = UDim2.new(ox, mid.X, oy, mid.Y)
		line.Size = UDim2.fromOffset(delta.Magnitude + 1, thickness)
		line.Rotation = math.deg(math.atan2(delta.Y, delta.X))
		line.BackgroundColor3 = color
		line.BackgroundTransparency = transparency
		line.BorderSizePixel = 0
		line.ZIndex = zindex
		line.Parent = parent

		return line
	end

	local function CreateWeb(parent, ox, oy, startAngle, endAngle, radius, spokes, rings)
		local color = Color3.fromRGB(235, 235, 245)
		local origin = Vector2.new(0, 0)
		local directions = {}

		for Index = 1, spokes do
			local angle = math.rad(startAngle + (endAngle - startAngle) * (Index - 1) / (spokes - 1))
			directions[Index] = Vector2.new(math.cos(angle), math.sin(angle))
			CreateLine(parent, ox, oy, origin, directions[Index] * radius, color, 0.55, 1, 10)
		end

		for Ring = 1, rings do
			local distance = radius * Ring / rings

			for Index = 1, spokes - 1 do
				local a = directions[Index] * distance
				local b = directions[Index + 1] * distance
				local sag = ((a + b) / 2) * 0.86

				CreateLine(parent, ox, oy, a, sag, color, 0.6, 1, 10)
				CreateLine(parent, ox, oy, sag, b, color, 0.6, 1, 10)
			end
		end
	end

	local function CreateCircle(parent, x, y, w, h, color, zindex)
		local circle = Instance.new("Frame")
		circle.AnchorPoint = Vector2.new(0.5, 0.5)
		circle.Position = UDim2.new(0.5, x, 0.5, y)
		circle.Size = UDim2.fromOffset(w, h)
		circle.BackgroundColor3 = color
		circle.BorderSizePixel = 0
		circle.ZIndex = zindex
		circle.Parent = parent

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(1, 0)
		corner.Parent = circle

		return circle
	end

	local function AddStroke(object, color, thickness)
		local stroke = Instance.new("UIStroke")
		stroke.Color = color
		stroke.Thickness = thickness
		stroke.Parent = object
	end

	local function CreateSpider(parent, offsetX)
		local orange = Color3.fromRGB(255, 122, 0)
		local dark = Color3.fromRGB(14, 10, 20)

		local thread = Instance.new("Frame")
		thread.AnchorPoint = Vector2.new(0.5, 0)
		thread.Position = UDim2.new(1, offsetX, 0, 0)
		thread.Size = UDim2.fromOffset(1, 40)
		thread.BackgroundColor3 = Color3.fromRGB(235, 235, 245)
		thread.BackgroundTransparency = 0.35
		thread.BorderSizePixel = 0
		thread.ZIndex = 12
		thread.Parent = parent

		local spider = Instance.new("Frame")
		spider.AnchorPoint = Vector2.new(0.5, 0.5)
		spider.Position = UDim2.new(1, offsetX, 0, 56)
		spider.Size = UDim2.fromOffset(48, 48)
		spider.BackgroundTransparency = 1
		spider.ZIndex = 13
		spider.Parent = parent

		local hipY = { -3, -1, 1, 3 }
		local upperAngle = { -78, -42, -12, 18 }
		local lowerAngle = { 38, 48, 58, 68 }

		for Index = 1, 4 do
			for _, side in next, { 1, -1 } do
				local hip = Vector2.new(side * 4, hipY[Index])
				local upper = math.rad(upperAngle[Index])
				local lower = math.rad(lowerAngle[Index])
				local knee = hip + Vector2.new(side * math.cos(upper), math.sin(upper)) * 12
				local foot = knee + Vector2.new(side * math.cos(lower), math.sin(lower)) * 13

				CreateLine(spider, 0.5, 0.5, hip, knee, orange, 0.05, 2, 13)
				CreateLine(spider, 0.5, 0.5, knee, foot, orange, 0.05, 2, 13)
			end
		end

		local abdomen = CreateCircle(spider, 0, -6, 18, 22, dark, 14)
		AddStroke(abdomen, orange, 1.5)

		CreateCircle(spider, 0, -9, 7, 7, orange, 15)
		CreateCircle(spider, 0, -2, 4, 4, orange, 15)

		local head = CreateCircle(spider, 0, 9, 12, 10, dark, 15)
		AddStroke(head, orange, 1.5)

		for _, eye in next, { { -3, 8 }, { 3, 8 }, { -1.5, 11 }, { 1.5, 11 } } do
			CreateCircle(spider, eye[1], eye[2], 2.5, 2.5, Color3.fromRGB(255, 40, 40), 16)
		end

		CreateLine(spider, 0.5, 0.5, Vector2.new(-2.5, 14), Vector2.new(-1.5, 18), orange, 0, 1.5, 16)
		CreateLine(spider, 0.5, 0.5, Vector2.new(2.5, 14), Vector2.new(1.5, 18), orange, 0, 1.5, 16)

		return thread, spider
	end

	local function CreateGhost(parent, size)
		local height = size * 1.2

		local ghost = Instance.new("CanvasGroup")
		ghost.AnchorPoint = Vector2.new(0.5, 0.5)
		ghost.Size = UDim2.fromOffset(size, height)
		ghost.BackgroundTransparency = 1
		ghost.GroupTransparency = 0.4
		ghost.BorderSizePixel = 0
		ghost.ZIndex = 11
		ghost.Parent = parent

		local white = Color3.fromRGB(242, 242, 255)
		local face = Color3.fromRGB(24, 18, 36)

		local head = Instance.new("Frame")
		head.Size = UDim2.fromOffset(size, size)
		head.BackgroundColor3 = white
		head.BorderSizePixel = 0
		head.ZIndex = 12
		head.Parent = ghost

		local headCorner = Instance.new("UICorner")
		headCorner.CornerRadius = UDim.new(1, 0)
		headCorner.Parent = head

		local body = Instance.new("Frame")
		body.Position = UDim2.fromOffset(0, size * 0.5)
		body.Size = UDim2.fromOffset(size, size * 0.52)
		body.BackgroundColor3 = white
		body.BorderSizePixel = 0
		body.ZIndex = 12
		body.Parent = ghost

		local bump = size / 3
		for Index = 0, 2 do
			local skirt = Instance.new("Frame")
			skirt.Position = UDim2.fromOffset(bump * Index, height - bump)
			skirt.Size = UDim2.fromOffset(bump, bump)
			skirt.BackgroundColor3 = white
			skirt.BorderSizePixel = 0
			skirt.ZIndex = 12
			skirt.Parent = ghost

			local skirtCorner = Instance.new("UICorner")
			skirtCorner.CornerRadius = UDim.new(1, 0)
			skirtCorner.Parent = skirt
		end

		for _, eyeX in next, { 0.32, 0.68 } do
			local eye = Instance.new("Frame")
			eye.AnchorPoint = Vector2.new(0.5, 0.5)
			eye.Position = UDim2.fromOffset(size * eyeX, size * 0.4)
			eye.Size = UDim2.fromOffset(size * 0.14, size * 0.2)
			eye.BackgroundColor3 = face
			eye.BorderSizePixel = 0
			eye.ZIndex = 13
			eye.Parent = ghost

			local eyeCorner = Instance.new("UICorner")
			eyeCorner.CornerRadius = UDim.new(1, 0)
			eyeCorner.Parent = eye
		end

		local mouth = Instance.new("Frame")
		mouth.AnchorPoint = Vector2.new(0.5, 0.5)
		mouth.Position = UDim2.fromOffset(size * 0.5, size * 0.68)
		mouth.Size = UDim2.fromOffset(size * 0.16, size * 0.2)
		mouth.BackgroundColor3 = face
		mouth.BorderSizePixel = 0
		mouth.ZIndex = 13
		mouth.Parent = ghost

		local mouthCorner = Instance.new("UICorner")
		mouthCorner.CornerRadius = UDim.new(1, 0)
		mouthCorner.Parent = mouth

		return ghost
	end

	function ThemeManager:ApplyDecoration(theme)
		self:ClearDecoration()

		if self.Library and self.Library.SetPumpkinSliders then
			self.Library:SetPumpkinSliders(theme == "Halloween")
		end

		local window = self.Library and self.Library.WindowFrame
		if theme ~= "Halloween" or not window then return end

		local decoration = Instance.new("Frame")
		decoration.Name = "HalloweenDecoration"
		decoration.BackgroundTransparency = 1
		decoration.BorderSizePixel = 0
		decoration.Size = UDim2.fromScale(1, 1)
		decoration.ClipsDescendants = true
		decoration.Active = false
		decoration.ZIndex = 10
		decoration.Parent = window

		CreateWeb(decoration, 1, 0, 90, 180, 120, 6, 5)
		CreateWeb(decoration, 0, 1, 270, 360, 90, 5, 4)

		local offsetX = -64
		local thread, spider = CreateSpider(decoration, offsetX)

		local ghosts = {
			{ object = CreateGhost(decoration, 26), x = 0.2, y = 0.3, phase = 0, speed = 1.1 },
			{ object = CreateGhost(decoration, 22), x = 0.58, y = 0.84, phase = 2.1, speed = 0.8 },
			{ object = CreateGhost(decoration, 30), x = 0.9, y = 0.58, phase = 4.2, speed = 1.4 },
		}

		self.Decoration = decoration
		self.DecorationConnection = RunService.Heartbeat:Connect(function()
			local time = os.clock()
			local length = 46 + math.sin(time * 1.3) * 22
			local sway = math.sin(time * 0.9) * 3

			thread.Size = UDim2.fromOffset(1, length)
			spider.Position = UDim2.new(1, offsetX + sway, 0, length + 19)
			spider.Rotation = math.sin(time * 0.9) * 4

			for _, ghost in next, ghosts do
				local drift = math.sin(time * 0.5 * ghost.speed + ghost.phase) * 0.04
				local float = math.sin(time * 1.5 * ghost.speed + ghost.phase) * 7
				ghost.object.Position = UDim2.new(ghost.x + drift, 0, ghost.y, float)
			end
		end)
	end

	function ThemeManager:ApplyTheme(theme)
		local customThemeData = self:GetCustomTheme(theme)
		local data = customThemeData or self.BuiltInThemes[theme]

		if not data then return end

		if self.Library.InnerVideoBackground ~= nil then
			self.Library.InnerVideoBackground.Visible = false
		end

		self:ApplyDecoration(customThemeData == nil and theme or nil)

		local scheme = data[2]
		for idx, col in next, customThemeData or scheme do
			if idx == "VideoLink" then
				self.Library[idx] = col

				if self.Library.Options[idx] then
					self.Library.Options[idx]:SetValue(col)
				end

				ApplyBackgroundVideo(col)
			else
				self.Library[idx] = Color3.fromHex(col)

				if self.Library.Options[idx] then
					self.Library.Options[idx]:SetValueRGB(Color3.fromHex(col))
				end
			end
		end

		self:ThemeUpdate()
	end

	function ThemeManager:ThemeUpdate()

		if self.Library.InnerVideoBackground ~= nil then
			self.Library.InnerVideoBackground.Visible = false
		end

		for i, field in next, ThemeFields do
			if self.Library.Options and self.Library.Options[field] then
				self.Library[field] = self.Library.Options[field].Value

				if field == "VideoLink" then
					ApplyBackgroundVideo(self.Library.Options[field].Value)
				end
			end
		end

		self.Library.AccentColorDark = self.Library:GetDarkerColor(self.Library.AccentColor);
		self.Library:UpdateColorsUsingRegistry()
	end

	function ThemeManager:GetCustomTheme(file)
		local path = self.Folder .. '/themes/' .. file .. '.json'
		if not isfile(path) then
			return nil
		end

		local data = readfile(path)
		local success, decoded = pcall(HttpService.JSONDecode, HttpService, data)

		if not success then
			return nil
		end

		return decoded
	end

	function ThemeManager:LoadDefault()
		local theme = 'Default'
		local content = isfile(self.Folder .. '/themes/default.txt') and readfile(self.Folder .. '/themes/default.txt')

		local isDefault = true
		if content then
			if self.BuiltInThemes[content] then
				theme = content
			elseif self:GetCustomTheme(content) then
				theme = content
				isDefault = false;
			end
		elseif self.BuiltInThemes[self.DefaultTheme] then
			theme = self.DefaultTheme
		end

		if isDefault then
			self.Library.Options.ThemeManager_ThemeList:SetValue(theme)
		else
			self:ApplyTheme(theme)
		end
	end

	function ThemeManager:SaveDefault(theme)
		writefile(self.Folder .. '/themes/default.txt', theme)
	end

	function ThemeManager:SaveCustomTheme(file)
		if file:gsub(' ', '') == '' then
			self.Library:Notify('Invalid file name for theme (empty)', 3)
			return
		end

		local theme = {}
		for _, field in next, ThemeFields do
			if field == "VideoLink" then
				theme[field] = self.Library.Options[field].Value
			else
				theme[field] = self.Library.Options[field].Value:ToHex()
			end
		end

		writefile(self.Folder .. '/themes/' .. file .. '.json', HttpService:JSONEncode(theme))
	end

	function ThemeManager:Delete(name)
		if (not name) then
			return false, 'no config file is selected'
		end

		local file = self.Folder .. '/themes/' .. name .. '.json'
		if not isfile(file) then return false, 'invalid file' end

		local success = pcall(delfile, file)
		if not success then return false, 'delete file error' end

		return true
	end

	function ThemeManager:ReloadCustomThemes()
		local list = listfiles(self.Folder .. '/themes')

		local out = {}
		for i = 1, #list do
			local file = list[i]
			if file:sub(-5) == '.json' then

				local pos = file:find('.json', 1, true)
				local start = pos

				local char = file:sub(pos, pos)
				while char ~= '/' and char ~= '\\' and char ~= '' do
					pos = pos - 1
					char = file:sub(pos, pos)
				end

				if char == '/' or char == '\\' then
					table.insert(out, file:sub(pos + 1, start - 1))
				end
			end
		end

		return out
	end

	function ThemeManager:CreateThemeManager(groupbox)
		groupbox:AddLabel('Background color'):AddColorPicker('BackgroundColor', { Default = self.Library.BackgroundColor });
		groupbox:AddLabel('Main color')	:AddColorPicker('MainColor', { Default = self.Library.MainColor });
		groupbox:AddLabel('Accent color'):AddColorPicker('AccentColor', { Default = self.Library.AccentColor });
		groupbox:AddLabel('Outline color'):AddColorPicker('OutlineColor', { Default = self.Library.OutlineColor });
		groupbox:AddLabel('Font color')	:AddColorPicker('FontColor', { Default = self.Library.FontColor });
		groupbox:AddInput('VideoLink', { Text = '.webm Video Background (Link)', Default = self.Library.VideoLink });

		local ThemesArray = {}
		for Name, Theme in next, self.BuiltInThemes do
			table.insert(ThemesArray, Name)
		end

		table.sort(ThemesArray, function(a, b) return self.BuiltInThemes[a][1] < self.BuiltInThemes[b][1] end)

		groupbox:AddDivider()

		groupbox:AddDropdown('ThemeManager_ThemeList', { Text = 'Theme list', Values = ThemesArray, Default = 1 })
		groupbox:AddButton('Set as default', function()
			self:SaveDefault(self.Library.Options.ThemeManager_ThemeList.Value)
			self.Library:Notify(string.format('Set default theme to %q', self.Library.Options.ThemeManager_ThemeList.Value))
		end)

		self.Library.Options.ThemeManager_ThemeList:OnChanged(function()
			self:ApplyTheme(self.Library.Options.ThemeManager_ThemeList.Value)
		end)

		groupbox:AddDivider()

		groupbox:AddInput('ThemeManager_CustomThemeName', { Text = 'Custom theme name' })
		groupbox:AddButton('Create theme', function()
			local name = self.Library.Options.ThemeManager_CustomThemeName.Value
			if name:gsub(" ", "") == "" then
                self.Library:Notify("Invalid theme name (empty)", 2)
                return
            end

            self:SaveCustomTheme(name)

            self.Library:Notify(string.format("Created theme %q", name))
			self.Library.Options.ThemeManager_CustomThemeList:SetValues(self:ReloadCustomThemes())
			self.Library.Options.ThemeManager_CustomThemeList:SetValue(nil)
		end)

		groupbox:AddDivider()

		groupbox:AddDropdown('ThemeManager_CustomThemeList', { Text = 'Custom themes', Values = self:ReloadCustomThemes(), AllowNull = true, Default = 1 })
		groupbox:AddButton('Load theme', function()
			local name = self.Library.Options.ThemeManager_CustomThemeList.Value

			self:ApplyTheme(name)
			self.Library:Notify(string.format('Loaded theme %q', name))
		end)
		groupbox:AddButton('Overwrite theme', function()
			local name = self.Library.Options.ThemeManager_CustomThemeList.Value

			self:SaveCustomTheme(name)
			self.Library:Notify(string.format('Overwrote config %q', name))
		end)
		groupbox:AddButton('Delete theme', function()
			local name = self.Library.Options.ThemeManager_CustomThemeList.Value

			local success, err = self:Delete(name)
			if not success then
				self.Library:Notify('Failed to delete theme: ' .. err)
				return
			end

			self.Library:Notify(string.format('Deleted theme %q', name))
			self.Library.Options.ThemeManager_CustomThemeList:SetValues(self:ReloadCustomThemes())
			self.Library.Options.ThemeManager_CustomThemeList:SetValue(nil)
		end)
		groupbox:AddButton('Refresh list', function()
			self.Library.Options.ThemeManager_CustomThemeList:SetValues(self:ReloadCustomThemes())
			self.Library.Options.ThemeManager_CustomThemeList:SetValue(nil)
		end)
		groupbox:AddButton('Set as default', function()
			if self.Library.Options.ThemeManager_CustomThemeList.Value ~= nil and self.Library.Options.ThemeManager_CustomThemeList.Value ~= '' then
				self:SaveDefault(self.Library.Options.ThemeManager_CustomThemeList.Value)
				self.Library:Notify(string.format('Set default theme to %q', self.Library.Options.ThemeManager_CustomThemeList.Value))
			end
		end)
		groupbox:AddButton('Reset default', function()
			local success = pcall(delfile, self.Folder .. '/themes/default.txt')
			if not success then
				self.Library:Notify('Failed to reset default: delete file error')
				return
			end

			self.Library:Notify('Set default theme to nothing')
			self.Library.Options.ThemeManager_CustomThemeList:SetValues(self:ReloadCustomThemes())
			self.Library.Options.ThemeManager_CustomThemeList:SetValue(nil)
		end)

		self:LoadDefault()

		local function UpdateTheme() self:ThemeUpdate() end
		self.Library.Options.BackgroundColor:OnChanged(UpdateTheme)
		self.Library.Options.MainColor:OnChanged(UpdateTheme)
		self.Library.Options.AccentColor:OnChanged(UpdateTheme)
		self.Library.Options.OutlineColor:OnChanged(UpdateTheme)
		self.Library.Options.FontColor:OnChanged(UpdateTheme)
	end

	function ThemeManager:CreateGroupBox(tab)
		assert(self.Library, 'ThemeManager:CreateGroupBox -> Must set ThemeManager.Library first!')
		return tab:AddLeftGroupbox('Themes')
	end

	function ThemeManager:ApplyToTab(tab)
		assert(self.Library, 'ThemeManager:ApplyToTab -> Must set ThemeManager.Library first!')
		local groupbox = self:CreateGroupBox(tab)
		self:CreateThemeManager(groupbox)
	end

	function ThemeManager:ApplyToGroupbox(groupbox)
		assert(self.Library, 'ThemeManager:ApplyToGroupbox -> Must set ThemeManager.Library first!')
		self:CreateThemeManager(groupbox)
	end

	ThemeManager:BuildFolderTree()
end

getgenv().LinoriaThemeManager = ThemeManager
return ThemeManager

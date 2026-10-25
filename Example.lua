local Repo = "https://raw.githubusercontent.com/Ali-lov3/LinUi/refs/heads/main/"

local Library = loadstring(game:HttpGet(Repo .. "Source.lua"))()
local ThemeManager = loadstring(game:HttpGet(Repo .. "ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(Repo .. "SaveManager.lua"))()

local Window = Library:CreateWindow({
    Title = "Example",
    Logo = 18467582982,
    Center = true,
    AutoShow = true,
    TabPadding = 1,
    SidebarWidth = 40,
    MenuFadeTime = 0.2,
})

local Tabs = {
    Example = Window:AddTab("Example", "layout-grid"),
    UiSettings = Window:AddTab("UiSettings", "settings"),
}

local Main = Tabs.Example:AddLeftGroupbox("Example")

Main:AddLabel("Example Label")

Main:AddLabel("Example Wrapped Label with a longer text that wraps onto several lines", true)

Main:AddLabel("ExampleColorLabel", { Text = "Example Color" }):AddColorPicker("ExampleLabelColor", {
    Default = Color3.fromRGB(255, 80, 120),
    Title = "Example Color",
})

Main:AddDivider()

Main:AddDivider("Example Divider")

Main:AddToggle("ExampleToggle", {
    Text = "Example Toggle",
    Default = false,
    Tooltip = "Example Tooltip",
    Callback = function(Value)
        print("Example Toggle:", Value)
    end,
})

Main:AddToggle("ExampleColorToggle", {
    Text = "Example Color Toggle",
    Default = true,
}):AddColorPicker("ExampleToggleColor", {
    Default = Color3.fromRGB(80, 160, 255),
    Title = "Example Toggle Color",
})

Main:AddButton({
    Text = "Example Button",
    Func = function()
        Library:Notify("Example Button clicked", 3)
    end,
    Tooltip = "Example Button Tooltip",
})

Main:AddButton("Example Button Two", function()
    Library:Notify("Example Button Two clicked", 3)
end)

Main:AddSlider("ExampleSlider", {
    Text = "Example Slider",
    Default = 50,
    Min = 0,
    Max = 100,
    Rounding = 0,
    Suffix = "%",
    Callback = function(Value)
        print("Example Slider:", Value)
    end,
})

Main:AddSlider("ExampleDecimalSlider", {
    Text = "Example Decimal Slider",
    Default = 1.5,
    Min = 0,
    Max = 5,
    Rounding = 1,
    Prefix = "x",
})

Main:AddInput("ExampleInput", {
    Text = "Example Input",
    Default = "Example",
    Placeholder = "Example Placeholder",
    Finished = false,
    ClearTextOnFocus = false,
    Callback = function(Value)
        print("Example Input:", Value)
    end,
})

Main:AddInput("ExampleNumericInput", {
    Text = "Example Numeric Input",
    Default = "10",
    Numeric = true,
    Finished = true,
})

Main:AddDropdown("ExampleDropdown", {
    Text = "Example Dropdown",
    Values = { "Example One", "Example Two", "Example Three" },
    Default = 1,
    Multi = false,
    Callback = function(Value)
        print("Example Dropdown:", Value)
    end,
})

Main:AddDropdown("ExampleMultiDropdown", {
    Text = "Example Multi Dropdown",
    Values = { "Example One", "Example Two", "Example Three", "Example Four" },
    Default = { "Example One" },
    Multi = true,
})

Main:AddDropdown("ExampleSearchDropdown", {
    Text = "Example Searchable Dropdown",
    Values = { "Example Alpha", "Example Beta", "Example Gamma", "Example Delta" },
    Default = 1,
    Searchable = true,
})

Main:AddDropdown("ExamplePlayerDropdown", {
    Text = "Example Player Dropdown",
    SpecialType = "Player",
})

local Dependency = Tabs.Example:AddLeftGroupbox("Example Dependency")

Dependency:AddToggle("ExampleDependencyToggle", {
    Text = "Example Show Hidden",
    Default = false,
})

local DependencyBox = Dependency:AddDependencyBox()

DependencyBox:AddLabel("Example Hidden Label")

DependencyBox:AddSlider("ExampleHiddenSlider", {
    Text = "Example Hidden Slider",
    Default = 5,
    Min = 0,
    Max = 10,
    Rounding = 0,
})

DependencyBox:SetupDependencies({
    { Library.Toggles.ExampleDependencyToggle, true },
})

local Media = Tabs.Example:AddRightGroupbox("Example Media")

local ExamplePart = Instance.new("Part")
ExamplePart.Size = Vector3.new(2, 2, 2)
ExamplePart.Color = Color3.fromRGB(255, 80, 120)
ExamplePart.Material = Enum.Material.SmoothPlastic
ExamplePart.Anchored = true

Media:AddViewport("ExampleViewport", {
    Object = ExamplePart,
    Clone = true,
    Interactive = true,
    AutoFocus = true,
    Height = 120,
})

Media:AddImage("ExampleImage", {
    Image = "rbxasset://textures/ui/GuiImagePlaceholder.png",
    Height = 80,
    ScaleType = Enum.ScaleType.Fit,
})

Media:AddVideo("ExampleVideo", {
    Video = "",
    Looped = true,
    Playing = false,
    Volume = 0,
    Height = 80,
})

local ExampleFrame = Instance.new("Frame")
ExampleFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
ExampleFrame.BorderSizePixel = 0

local ExampleFrameLabel = Instance.new("TextLabel")
ExampleFrameLabel.BackgroundTransparency = 1
ExampleFrameLabel.Size = UDim2.fromScale(1, 1)
ExampleFrameLabel.Text = "Example Passthrough"
ExampleFrameLabel.TextColor3 = Color3.new(1, 1, 1)
ExampleFrameLabel.TextSize = 14
ExampleFrameLabel.Font = Enum.Font.Code
ExampleFrameLabel.Parent = ExampleFrame

Media:AddUIPassthrough("ExamplePassthrough", {
    Instance = ExampleFrame,
    Height = 40,
})

local ExampleTabbox = Tabs.Example:AddRightTabbox("Example Tabbox")

local TabboxOne = ExampleTabbox:AddTab("Example One")

TabboxOne:AddToggle("ExampleTabboxToggle", {
    Text = "Example Tabbox Toggle",
    Default = true,
})

TabboxOne:AddButton("Example Tabbox Button", function()
    Library:Notify("Example Tabbox Button clicked", 3)
end)

local TabboxTwo = ExampleTabbox:AddTab("Example Two")

TabboxTwo:AddSlider("ExampleTabboxSlider", {
    Text = "Example Tabbox Slider",
    Default = 25,
    Min = 0,
    Max = 50,
    Rounding = 0,
})

TabboxTwo:AddInput("ExampleTabboxInput", {
    Text = "Example Tabbox Input",
    Default = "Example",
})

local Menu = Tabs.UiSettings:AddRightGroupbox("Menu")

Menu:AddButton("Unload", function()
    Library:Unload()
end)

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})

ThemeManager:SetFolder("Example")
SaveManager:SetFolder("Example/Config")

ThemeManager:ApplyToTab(Tabs.UiSettings)
SaveManager:BuildConfigSection(Tabs.UiSettings)

SaveManager:LoadAutoloadConfig()

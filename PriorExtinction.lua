local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/lukankerhubsources-igrizqhckg/ESP-Library/main/ESPLibrary.lua"))()
local Library = loadstring(game:HttpGet('https://pastebin.com/raw/1H58g3C5'))()

local HttpService = game:GetService('HttpService')
local TS = game:GetService("TweenService")
local Players = game:GetService('Players')
local UIS = game:GetService('UserInputService')

local LocalPlayer = game.Players.LocalPlayer
local GetRootPart = function() return LocalPlayer.Character.Body end

local Fossils = workspace.SpawnedFossils
local Ragdolls = workspace.Ragdolls

local Toggles = {}

ESP.Players = true
ESP.Boxes = false
ESP.Names = true
ESP:Toggle(true)

function GetMag(Part1, Part2) 
	return (Part1.Position - Part2.Position).Magnitude
end

function GetCurrentFossilTypes()
    local FossilTypes = {}
    for i, Fossil in pairs(Fossils:GetChildren()) do
        if not table.find(FossilTypes, Fossil.Name) then
            table.insert(FossilTypes, Fossil.Name)
        end
    end
    
    return FossilTypes
end

function GetCurrentCorpseSpecies()
    local CorpseSpecies = {}
    for i, Corpse in pairs(Ragdolls:GetChildren()) do
        if not table.find(CorpseSpecies, Corpse.Name) then
            table.insert(CorpseSpecies, Corpse.Name)
        end
    end
    
    return CorpseSpecies
end

function RefreshFossilESP(Toggle)
    for i, FossilType in pairs(GetCurrentFossilTypes()) do
        if not ESP[FossilType] then
            ESP:AddObjectListener(Fossils, { -- Object Path, For example: Workspace.ThisFolder
                Name = FossilType, --Object name inside of the path, for example: Workspace.ThisFolder.Item_1
                CustomName = FossilType, -- Name you want to be displayed
                Color = Color3.fromRGB(255, 0, 0), -- Color
                IsEnabled = FossilType -- Any name, has to be the same as the last line: ESP.TheNameYouWant,
            })
        else
            ESP[FossilType] = false
        end
    end
    ESP[Toggle.Dropdowns.Fossil.Value] = Toggle.Value
end

function RefreshCorpseESP(Toggle)
    for i, Species in pairs(GetCurrentCorpseSpecies()) do
        if not ESP[Species] then
            ESP:AddObjectListener(Ragdolls, { -- Object Path, For example: Workspace.ThisFolder
                Name = Species, --Object name inside of the path, for example: Workspace.ThisFolder.Item_1
                CustomName = Species, -- Name you want to be displayed
                Color = Color3.fromRGB(0, 255, 0), -- Color
                IsEnabled = Species -- Any name, has to be the same as the last line: ESP.TheNameYouWant,
            })
        else
            ESP[Species] = false
        end
    end
    ESP[Toggle.Dropdowns.Species.Value] = Toggle.Value
end

function PlayerESP(Toggle)
	ESP.Players = Toggle.Value
end

function SetPlayerESPColor(Color)
	ESP.Color = Color
end

function GetClosestFossil(Name)
	local Closest = nil
	for i, Fossil in pairs(Fossils:GetChildren()) do
		local Primary = Fossil:FindFirstChild('ProximityPrompt', true).Parent
		if Closest then
			if Fossil.Name == Name and GetMag(GetRootPart(), Primary) < GetMag(GetRootPart(), Closest) then
				Closest = Primary
			end
		else
			Closest = Primary
		end
	end

	return Closest
end

function FossilFarm(Toggle)
	if Toggle.Value then
		local Fossil = GetClosestFossil(Toggle.Dropdowns.Fossil.Value)
		local Magnitude = GetMag(GetRootPart(), Fossil)
		local Duration = Magnitude / (Toggle.Sliders.Speed.Value)

		local tweenInfo = TweenInfo.new(
			Duration, -- Duration 
			Enum.EasingStyle.Linear, -- Easing style
			Enum.EasingDirection.Out, -- Easing direction
			-1, -- Number of times to repeat (use -1 for infinite)
			false, 
			0 -- Delay 
		)

		Toggle.Properties.tween = TS:Create(
			GetRootPart(),
			tweenInfo,
			{
				CFrame = Fossil.CFrame
			}
		)
		
		-- Play the tween
		Toggle.Properties.tween:Play()

		wait(Duration)

		Toggle.Properties.tween:Cancel()
		fireproximityprompt(Fossil.ProximityPrompt, 2)
		wait(1)
		FossilFarm(Toggle)
	else
		if Toggle.Properties.tween then
			Toggle.Properties.tween:Cancel()
			Toggle.Properties.tween = nil
		end
	end
end

local Window = Library:CreateWindow({WindowName = 'Prior Extinction', Color = Color3.fromRGB(255, 0, 0),}, game:GetService('CoreGui'))
local Tabs = {
	Main = Window:CreateTab('Main'),
	Settings = Window:CreateTab('Settings'),
	Discord = Window:CreateTab('Discord')
}

local Sections = {
	ESP = Tabs.Main:CreateSection('ESP'),
	Farm = Tabs.Main:CreateSection('Farm')
}

Toggles = {
	PlayerESP = {
		Name = 'Players',
		Value = false,
		Function = PlayerESP,
		Keybind = 'NONE',
		Section = Sections.ESP,
		Colorpicker = {
			Name = 'Pick Color',
			Color = Color3.new(255, 255, 255),
			Function = SetPlayerESPColor
		}
	},
	FossilESP = {
		Name = 'Fossil',
		Value = false,
		Function = RefreshFossilESP,
		Keybind = 'NONE',
		Section = Sections.ESP,
		Dropdowns = {
			Fossil = {
				Name = 'Choose Fossil',
				OptionTable = GetCurrentFossilTypes(),
				Value = 'Small Fossil',
				Function = RefreshFossilESP
			}
		}
	},
	CorpseESP = {
		Name = 'Corpse',
		Value = false,
		Function = RefreshCorpseESP,
		Keybind = 'NONE',
		Section = Sections.ESP,
		Dropdowns = {
			Species = {
				Name = 'Choose Species',
				OptionTable = GetCurrentCorpseSpecies(),
				Value = 'NONE',
				Function = RefreshCorpseESP
			}
		}
	},
	FossilFarm = {
		Name = 'Fossil',
		Value = false,
		Function = FossilFarm,
		Keybind = 'NONE',
		Section = Sections.Farm,
		Properties = {
			tween = nil
		},
		Dropdowns = {
			Fossil = {
				Name = 'Choose Fossil',
				OptionTable = GetCurrentFossilTypes(),
				Value = 'Small Fossil'
			}
		},
		Sliders = {
			Speed = {
				Name = 'Speed',
				Min = 0,
				Max = 1000,
				Value = 0,
				Precise = true
			}
		}
	}
}

UIS.InputBegan:Connect(function(Input, isTyping)
	if isTyping then return end

	if Input.KeyCode == Enum.KeyCode.RightShift then
		Window:Toggle(false)
	end
end)


function GetCurrentConfig()
	local Config = {}
	for ToggleName, Toggle in pairs(Toggles) do
		Config[ToggleName] = {
			Value = Toggle.Value,
			Keybind = Toggle.Keybind,
		}
		if Toggle.Sliders then
			Config[ToggleName].Sliders = {}
			for SliderName, Slider in pairs(Toggle.Sliders) do
				Config[ToggleName].Sliders[SliderName] = Slider.Value
			end
		end
		if Toggle.Dropdowns then
			Config[ToggleName].Dropdowns = {}
			for DropdownName, Dropdown in pairs(Toggle.Dropdowns) do
				Config[ToggleName].Dropdowns[DropdownName] = Dropdown.Value
			end
		end
	end
	return Config
end

function LoadConfig()
	local FileName = 'PriorConfig.json'

	if not isfile(FileName) then
		writefile(FileName, HttpService:JSONEncode(GetCurrentConfig()))
	end

	return HttpService:JSONDecode(readfile(FileName))
end

function SaveConfig()
	local FileName = 'PriorConfig.json'
	writefile(FileName, HttpService:JSONEncode(GetCurrentConfig()))
end

local Config = LoadConfig()

Players.PlayerRemoving:Connect(function(Player)
	if Player == LocalPlayer then
		SaveConfig()
	end
end)

for ToggleName, Toggle in pairs(Toggles) do
	Toggle.Section:CreateToggle(Toggle.Name, Config[ToggleName].Value, function(State)
		Toggle.Value = State
		Toggle.Function(Toggle)
	end):CreateKeybind(Config[ToggleName].Keybind, function(Key)
		Toggle.Keybind = Key 
	end)
	if Toggle.Colorpicker then
		local Colorpicker = Toggle.Colorpicker
		Toggle.Section:CreateColorpicker(Colorpicker.Name, function(Color)
			Colorpicker.Color = Color
			Colorpicker.Function(Color)
		end)
	end
	if Toggle.Dropdowns then
		for DropdownName, Dropdown in pairs(Toggle.Dropdowns) do
			Toggle.Section:CreateDropdown(Dropdown.Name, Dropdown.OptionTable, function(Option) Dropdown.Value = Option
				if Dropdown.Function then
					Dropdown.Function(Toggle)
				end
			end, 
			Config[ToggleName].Dropdowns[DropdownName])
		end
	end
	if Toggle.Sliders then
		for SliderName, Slider in pairs(Toggle.Sliders) do
			Toggle.Section:CreateSlider(Slider.Name, Slider.Min, Slider.Max, Config[ToggleName].Sliders[SliderName], Slider.Precise, function(Value)
				Slider.Value = Value
			end)
		end
	end
end

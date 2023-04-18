local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()
local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/lukankerhubsources-igrizqhckg/ESP-Library/main/ESPLibrary.lua"))()

local Fossils = workspace.SpawnedFossils

ESP.Players = true
ESP.Boxes = false
ESP.Names = true
ESP:Toggle(true)

function GetCurrentFossilTypes()
    local FossilTypes = {}
    for i, Fossil in pairs(Fossils:GetChildren()) do
        if not table.find(FossilTypes, Fossil.Name) then
            table.insert(FossilTypes, Fossil.Name)
        end
    end
    
    return FossilTypes
end

function RefreshFossilESP()
    for i, FossilType in pairs(GetCurrentFossilTypes()) do
        if not ESP[FossilType] then
            ESP:AddObjectListener(Fossils, { -- Object Path, For example: Workspace.ThisFolder
                Name = FossilType, --Object name inside of the path, for example: Workspace.ThisFolder.Item_1
                CustomName = FossilType, -- Name you want to be displayed
                Color = Color3.fromRGB(255, 0, 0), -- Color
                IsEnabled = FossilType -- Any name, has to be the same as the last line: ESP.TheNameYouWant
            })
        else
            ESP[FossilType] = false
        end
    end
end

local Window = OrionLib:MakeWindow({Name = "Prior Extinction", HidePremium = false, SaveConfig = true, ConfigFolder = "PriorExtinction"})
local Tabs = {
    ESP = {
        Tab = {Name = "ESP", Icon = "rbxassetid://4483345998", PremiumOnly = false},
        Sections = {
            Fossil = {
                Section = {Name = "Fossils"},
                Dropdowns = {
                    FossilType = {
                        Name = "Choose Fossil",
                        Default = "Small Fossil",
                        Options = GetCurrentFossilTypes(),
                        Callback = function(Value)
                            RefreshFossilESP()
                            ESP[Value] = true
                        end    
                    }
                }
            }
        }
    }
}

Fossils.ChildAdded:Connect(function()
    Tabs.ESP.Fossil.Dropdowns.FossilType:Refresh(GetCurrentFossilTypes(), true)
end)

function InitializeTabs()
    for TabName, TabSettings in pairs(Tabs) do
        local Tab = Window:MakeTab(TabSettings.Tab)
        for SectionName, SectionSettings in pairs(TabSettings.Sections) do
            local Section = Tab:AddSection(SectionSettings.Section)
            for DropdownName, Dropdown in pairs(SectionSettings.Dropdowns) do
                local Dropdown = Section:AddDropdown(Dropdown)
            end
        end
    end
end

InitializeTabs()

OrionLib:Init()
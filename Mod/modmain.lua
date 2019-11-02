PrefabFiles = {
	"starvew_veggies"
	}

local G = GLOBAL
local require = GLOBAL.require
local STRINGS = GLOBAL.STRINGS

modimport("scripts/starvewstrings.lua")

AddIngredientValues({"blueberries"}, {fruit=.5, sweetener =1}, true)
AddIngredientValues({"broccoli"}, {veggie=1}, true)
AddIngredientValues({"cabbage"}, {veggie=.5}, true)
AddIngredientValues({"cauliflower"}, {veggie=1}, true)
AddIngredientValues({"lettuce"}, {veggie=.5}, true)
AddIngredientValues({"raspberries"}, {fruit=.5, sweetener =1}, true)
AddIngredientValues({"strawberries"}, {fruit=.5, sweetener =1}, true)

if GLOBAL.TheNet:GetIsServer() then	
AddSimPostInit(function(inst)
    for key, val in pairs(GLOBAL.STARVEW_VEGGIES) do
        GLOBAL.VEGGIES[key] = val
    end
end)
end
require "tuning"
local function MakeVegStats(seedweight, hunger, health, perish_time, sanity, cooked_hunger, cooked_health, cooked_perish_time, cooked_sanity)
    return {
        health = health,
        hunger = hunger,
        cooked_health = cooked_health,
        cooked_hunger = cooked_hunger,
        seed_weight = seedweight,
        perishtime = perish_time,
        cooked_perishtime = cooked_perish_time,
        sanity = sanity,
        cooked_sanity = cooked_sanity,
    }
end

local COMMON = 3
local UNCOMMON = 1
local RARE = .5

STARVEW_VEGGIES =
{
    blueberries = MakeVegStats(UNCOMMON,   TUNING.CALORIES_SMALL,  TUNING.HEALING_TINY,    TUNING.PERISH_MED, 0,       
                                    TUNING.CALORIES_SMALL,  TUNING.HEALING_SMALL,   TUNING.PERISH_FAST, 0),
									
    broccoli = MakeVegStats(COMMON,   TUNING.CALORIES_SMALL,  TUNING.HEALING_TINY,    TUNING.PERISH_MED, 0,       
                                    TUNING.CALORIES_SMALL,  TUNING.HEALING_SMALL,   TUNING.PERISH_FAST, 0),
									
    cabbage = MakeVegStats(COMMON,   TUNING.CALORIES_SMALL,  TUNING.HEALING_TINY,    TUNING.PERISH_MED, 0,       
                                    TUNING.CALORIES_SMALL,  TUNING.HEALING_SMALL,   TUNING.PERISH_FAST, 0),
									
    cauliflower = MakeVegStats(COMMON,   TUNING.CALORIES_SMALL,  TUNING.HEALING_TINY,    TUNING.PERISH_MED, 0,       
                                    TUNING.CALORIES_SMALL,  TUNING.HEALING_SMALL,   TUNING.PERISH_FAST, 0),
									
    lettuce = MakeVegStats(COMMON,   TUNING.CALORIES_SMALL,  TUNING.HEALING_TINY,    TUNING.PERISH_MED, 0,       
                                    TUNING.CALORIES_SMALL,  TUNING.HEALING_SMALL,   TUNING.PERISH_FAST, 0),
																	
    raspberries = MakeVegStats(UNCOMMON,   TUNING.CALORIES_SMALL,  TUNING.HEALING_TINY,    TUNING.PERISH_MED, 0,       
                                    TUNING.CALORIES_SMALL,  TUNING.HEALING_SMALL,   TUNING.PERISH_FAST, 0),
									
    strawberries = MakeVegStats(UNCOMMON,   TUNING.CALORIES_SMALL,  TUNING.HEALING_TINY,    TUNING.PERISH_MED, 0,       
                                    TUNING.CALORIES_SMALL,  TUNING.HEALING_SMALL,   TUNING.PERISH_FAST, 0),
}

local assets_seeds =
{
    Asset("ANIM", "anim/seeds.zip"),
}

local function MakeVeggie(name, has_seeds)

    local assets =
    {
        Asset("ANIM", "anim/"..name..".zip"),
		Asset("ATLAS", "images/inventoryimages/"..name..".xml"),
    }

    local assets_cooked =
    {
        Asset("ANIM", "anim/"..name..".zip"),
		Asset("ATLAS", "images/inventoryimages/"..name.."_cooked.xml"),
    }
    
    local prefabs =
    {
        name.."_cooked",
        "spoiled_food",
    }
    
    if has_seeds then
        table.insert(prefabs, name.."_seeds")
        table.insert(prefabs, "seeds_cooked")
        table.insert(assets, Asset("ATLAS", "images/inventoryimages/"..name.."_seeds.xml"))
    end

    local function fn_seeds()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        MakeInventoryPhysics(inst)

        inst.AnimState:SetBank("seeds")
        inst.AnimState:SetBuild("seeds")
        inst.AnimState:SetRayTestOnBB(true)

        --cookable (from cookable component) added to pristine state for optimization
        inst:AddTag("cookable")

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("edible")
        inst.components.edible.foodtype = FOODTYPE.SEEDS

        inst:AddComponent("stackable")
        inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

        inst:AddComponent("tradable")
        inst:AddComponent("inspectable")
		
        inst:AddComponent("inventoryitem")
		inst.components.inventoryitem.atlasname = "images/inventoryimages/"..name.."_seeds.xml"
	
        inst.AnimState:PlayAnimation("idle")

        inst.components.edible.healthvalue = TUNING.HEALING_TINY/2
        inst.components.edible.hungervalue = TUNING.CALORIES_TINY

        inst:AddComponent("perishable")
        inst.components.perishable:SetPerishTime(TUNING.PERISH_SUPERSLOW)
        inst.components.perishable:StartPerishing()
        inst.components.perishable.onperishreplacement = "spoiled_food"

        inst:AddComponent("cookable")
        inst.components.cookable.product = "seeds_cooked"

        inst:AddComponent("bait")
        inst:AddComponent("plantable")
        inst.components.plantable.growtime = TUNING.SEEDS_GROW_TIME
        inst.components.plantable.product = name

        MakeHauntableLaunchAndPerish(inst)

        return inst
    end

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        MakeInventoryPhysics(inst)

        inst.AnimState:SetBank(name)
        inst.AnimState:SetBuild(name)
        inst.AnimState:PlayAnimation("idle")
		--inst.AnimState:SetRayTestOnBB(true)

        --cookable (from cookable component) added to pristine state for optimization
        inst:AddTag("cookable")
        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("edible")
        inst.components.edible.healthvalue = STARVEW_VEGGIES[name].health
        inst.components.edible.hungervalue = STARVEW_VEGGIES[name].hunger
        inst.components.edible.sanityvalue = STARVEW_VEGGIES[name].sanity or 0      
        inst.components.edible.foodtype = FOODTYPE.VEGGIE

        inst:AddComponent("perishable")
        inst.components.perishable:SetPerishTime(STARVEW_VEGGIES[name].perishtime)
        inst.components.perishable:StartPerishing()
        inst.components.perishable.onperishreplacement = "spoiled_food"

        inst:AddComponent("stackable")
            inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

        inst:AddComponent("inspectable")
        inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.atlasname = "images/inventoryimages/"..name..".xml"

        MakeSmallBurnable(inst)
        MakeSmallPropagator(inst)
        ---------------------        

        inst:AddComponent("bait")

        ------------------------------------------------
        inst:AddComponent("tradable")

        ------------------------------------------------  

        inst:AddComponent("cookable")
        inst.components.cookable.product = name.."_cooked"

        MakeHauntableLaunchAndPerish(inst)

        return inst
    end

    local function fn_cooked()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

		MakeSmallPropagator(inst)	
        MakeInventoryPhysics(inst)

        inst.AnimState:SetBank(name)
        inst.AnimState:SetBuild(name)
        inst.AnimState:PlayAnimation("cooked")
		inst.AnimState:SetRayTestOnBB(true)

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("perishable")
        inst.components.perishable:SetPerishTime(STARVEW_VEGGIES[name].cooked_perishtime)
        inst.components.perishable:StartPerishing()
        inst.components.perishable.onperishreplacement = "spoiled_food"

        inst:AddComponent("edible")
        inst.components.edible.healthvalue = STARVEW_VEGGIES[name].cooked_health
        inst.components.edible.hungervalue = STARVEW_VEGGIES[name].cooked_hunger
        inst.components.edible.sanityvalue = STARVEW_VEGGIES[name].cooked_sanity or 0
        inst.components.edible.foodtype = FOODTYPE.VEGGIE

        inst:AddComponent("stackable")
        inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

        inst:AddComponent("inspectable")
        inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.atlasname = "images/inventoryimages/"..name.."_cooked.xml"

        MakeSmallBurnable(inst)
        MakeSmallPropagator(inst)
        ---------------------        

        inst:AddComponent("bait")

        ------------------------------------------------
        inst:AddComponent("tradable")

        MakeHauntableLaunchAndPerish(inst)

        return inst
    end

    local base = Prefab(name, fn, assets, prefabs)
    local cooked = Prefab(name.."_cooked", fn_cooked, assets_cooked)
    local seeds = has_seeds and Prefab(name.."_seeds", fn_seeds, assets_seeds) or nil

    return base, cooked, seeds
end

local prefs = {}
for veggiename,veggiedata in pairs(STARVEW_VEGGIES) do
    local veg, cooked, seeds = MakeVeggie(veggiename, true)
    table.insert(prefs, veg)
    table.insert(prefs, cooked)
    if seeds then
        table.insert(prefs, seeds)
    end
	
end

return unpack(prefs)

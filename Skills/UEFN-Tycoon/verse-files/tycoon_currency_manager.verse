
using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Verse.org/Simulation/Tags }
# See https://dev.epicgames.com/documentation/en-us/uefn/create-your-own-device-in-verse for how to create a verse device.

rebirth_count_tracker := class(tag){}

earning_multiplier_tracker := class(tag){}

stage_saving_tracker := class(tag){}

gold_remover_tag := class(tag){}

creature_spawner_tag := class(tag){}

claim_text_settings := class<concrete>:
    @editable
    TextBeforeGoldPerSecond : string = "$"

    @editable
    TextAfterGoldPerSecond : string = "/s"

    @editable
    TextBeforeStoredGold : string = "\nAvailable: $"

    @editable
    TextAfterStoredGold : string = ""

# A Verse-authored creative device that can be placed in a level
tycoon_currency_manager := class(creative_device):

    @editable
    SimBySeconds : int = 10

    @editable
    RunTestTimeSimulation : logic = false

    @editable
    HoldObjectiveAtGoldClaim : logic = false

    @editable
    LengthOfSecond : float = 1.0

    @editable
    CountBySeconds : int = 1

    var UISystem : UI_Trackers = UI_Trackers{} 


    S2M<localizes>(S:string):message="{S}"

    @editable
    FirstPlateManager : []pressure_plate_with_generator = array{}


    @editable
    ResourceClaimLocationProps : []creative_prop = array{}

    @editable
    ClaimTextSettings : claim_text_settings = claim_text_settings{}

    @editable
    GoldStorageBillboards : []billboard_device = array{}

    @editable
    RebirthButton : button_device = button_device{}


    @editable
    RebirthInfoBillboard : billboard_device = billboard_device{}

    #Threshold to count as close enough to claim stored resources.
    @editable
    ClaimDistance : float = 400.0

    @editable
    GoldGranter : item_granter_device = item_granter_device{}

    @editable
    ConditionalButton : conditional_button_device = conditional_button_device{}

    @editable
    NotEnoughGold : hud_message_device = hud_message_device{}

    @editable
    RebirthCooldownMessage : hud_message_device = hud_message_device{}

    @editable
    PurchaseAccoladeDevices : []accolades_device = array{}

    @editable
    CREATUREaccolades : []accolades_device = array{}

    @editable
    CreatureElimMultiplier : float = 1.0

    @editable
    MultiplierPerGoldPerSecond : float = 0.0001
    
    @editable
    DefaultBillboardText : string = "Unclaimed Plot"

    @editable
    PurchaseSounds : []audio_player_device = array{}

    var OwningPlayers : []player = array{}

    var AllPlateManagers : []pressure_plate_with_generator = array{}

    var GoldPerSecond : int = 0

    var StoredGold : int = 0

    var UsableMultiplier : float = 1.0

    var RebirthMultiplierAsInt : int = 0

    var RebirthCount : int = 0

    #(StageNumber,Count)
    var StageInfo : []tuple(int,int) = array{}

    IntMultiplierDetail : float = 10000.0

    var PotentialMultiplier : float = 1.0

    var GoldRemover : item_remover_device = item_remover_device{}

    var ExtraDelay :float = 0.0 

    var CurrentIndex : int = 0

    var PlayerSaveData : player_save_data = player_save_data{}

    var TempMultiplier : float = 1.0

    var CreatureSpawners : []creature_spawner_device = array{}

    @editable
    MapIndicatorDevice : map_indicator_device = map_indicator_device{}

    @editable
    MapIndicatorDeviceZOffset : float = -25.0

    @editable
    PlayerReference : player_reference_device = player_reference_device{}

    var TimeSincePlayerAdded : float = 0.0 

    var LastRebirthTime : float = -300.0  # Initialize to allow immediate first rebirth

    var RebirthCooldownSeconds : float = 30.0  # 5 minutes = 300 seconds 

    SetTempMultiplier(Multiplier : float):void=
        set TempMultiplier = Multiplier

    ResetTempMultiplier():void=
        set TempMultiplier = 1.0

    # Method to get remaining rebirth cooldown time
    GetRebirthCooldownRemaining():float=
        TimeSinceLastRebirth := TimeSincePlayerAdded - LastRebirthTime
        if (TimeSinceLastRebirth < RebirthCooldownSeconds):
            return RebirthCooldownSeconds - TimeSinceLastRebirth
        return 0.0

    RunTimer()<suspends>:void=
        loop:
            Sleep(LengthOfSecond * CountBySeconds)
            set TimeSincePlayerAdded += LengthOfSecond * CountBySeconds
            if(OwningPlayers.Length < 1):
                set TimeSincePlayerAdded = 0.0
            for(Player : OwningPlayers):
                if(FirstPlateManager[0].Activity = activity_type_classic.purchased):
                    if(PlayerData := PlayerProfileDataMap[Player]):
                        NewPlayerData := PlayerData.AddToSecondsActive(CountBySeconds)
                        if(set PlayerProfileDataMap[Player] = NewPlayerData):
                        else:
                            Print("Failed to save player playtime.")
                        UISystem.UpdatePlaytime(Player, NewPlayerData.SecondsActive)
                        Print("Player has been active for {NewPlayerData.SecondsActive} seconds.")
                    else:
                        Print("Failed to load player data on timer.")


    ChecklistLoop()<suspends>:void=
        loop:
            ChecklistPrint("{AllPlateManagers.Length} Active Plate Managers found.")
            ChecklistPrint("Plot claimed by {OwningPlayers.Length} players.")
            for(Manager : AllPlateManagers):
                ChecklistPrint("Plate Manager {Manager.PlateIndex}: {Manager.SpecialSettings.Name} is still running properly.")
                Sleep(0.1)
            Sleep(40.0)
                

    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        spawn{CalculateMinimumTime()}
        branch:
            sync:
                ChecklistLoop()
                RunTimer()
                MapIndicatorDeviceLoop()
        GoldRemoverGenerator := FindCreativeObjectsWithTag(gold_remover_tag{})
        var count : int = 0
        for(PotentialGoldRemover : GoldRemoverGenerator):
            if(GR := item_remover_device[PotentialGoldRemover]; count < 1):
                TryPrint("UI system found.")
                set GoldRemover = GR
                set count += 1 #There should only be one gold remover, but this will take the first for consistency
        if(count < 1){TryPrint("FAILED TO FIND GOLD REMOVER.")}

        RebirthInfoBillboard.SetText(S2M(DefaultBillboardText))
        RebirthButton.InteractedWithEvent.Subscribe(VerifyRebirth)
        InitDeviceArray()
        spawn{CreatureStuff()}

        #Loop to grant gold everysecond.
        loop:
            Sleep(0.2)
            AddToStoredResources()
            spawn{CheckClaim()} #spawn to ensure earning speed is not impacted by claiming
            Sleep(0.2 + ExtraDelay)
            spawn{CheckClaim()} #I think this runs faster than .2 seconds, so I'm just checking it 5 times per second while only updating gold once
            Sleep(0.2 + ExtraDelay)
            spawn{CheckClaim()}
            Sleep(0.2 + ExtraDelay)
            spawn{CheckClaim()}
            Sleep(0.2 + ExtraDelay)
            spawn{CheckClaim()}
            Sleep(ExtraDelay)

    SetOwningPlayers(Players : []player)<suspends>:void=
        set OwningPlayers = Players
        for(Player : OwningPlayers):
            MigrateLegacyNodeStates(Player)
            if(Data := PlayerProfileDataMap[Player]):
                set RebirthCount = Data.Rebirths
                set UsableMultiplier = Data.Multiplier
                set GoldPerSecond = GetGoldPerSecond(Data)
                set PlayerSaveData = Data
                TryPrint("Successfully loaded data: {RebirthCount} rebirths, {UsableMultiplier} multiplier")
                DisplayRebirthInfo()
                UISystem.UpdateRebirths(Player, RebirthCount)
            else:
                TryPrint("FAILED TO LOAD SAVE DATA ON CURRENCY MANAGER")
        #LoadTrackedInfo()
        if(OwningPlayers.Length > 0):
            #LoadStageSaving()
        if(MainPlayer := OwningPlayers[0]):
            PlayerReference.Register(MainPlayer)

    # Version 0 saves could be changed by the old restore path: it replayed a
    # purchase and marked an already-purchased child as active.  In a normal
    # Tycoon graph, an active node with an already-progressed child must itself
    # be purchased.  Correct only those impossible states, once per player.
    MigrateLegacyNodeStates(Player : player):void=
        if(AllPlateManagers.Length < 1):
            return
        if(Data := PlayerProfileDataMap[Player], Data.NodeSaveSchemaVersion < 1):
            var RepairedActivityMap : [int]int = Data.ActivityMap
            var RepairedNodeCount : int = 0
            for(Manager : AllPlateManagers):
                ManagerKey := Manager.GetPersistenceKey()
                if(CurrentState := Data.ActivityMap[ManagerKey], CurrentState = 2):
                    if(not Manager.SpecialSettings.StartAsActive?):
                        for(NextManager : Manager.GetNextManagers()):
                            NextKey := NextManager.GetPersistenceKey()
                            if(NextState := Data.ActivityMap[NextKey], NextState > 0):
                                if(set RepairedActivityMap[ManagerKey] = 1):
                                    set RepairedNodeCount += 1
            var RepairedData : player_save_data = Data.UpdateActivityMap(RepairedActivityMap)
            set RepairedData = RepairedData.UpdateNodeSaveSchemaVersion(1)
            if(set PlayerProfileDataMap[Player] = RepairedData):
                TryPrint("Repaired {RepairedNodeCount} legacy Tycoon Node save states.",?Duration:=10.0)
            else:
                TryPrint("Failed to repair legacy Tycoon Node save states.",?Duration:=90.0)

    UpdatePotentialMultiplier():void=
        set PotentialMultiplier = UsableMultiplier + (GoldPerSecond*MultiplierPerGoldPerSecond)
        DisplayRebirthInfo()

    GetGoldPerSecond(Data : player_save_data):int=
        var tempGPS : int = 0
        for(Key -> activity : Data.ActivityMap):
            if(activity = 1):
                for(Plate : AllPlateManagers):
                    if(Key = Plate.GetPersistenceKey()):
                        set tempGPS += Plate.CommonlyUsed.GoldPerSecond
        return tempGPS

    DisplayRebirthInfo():void=
        var Info : string = ""
        set Info += "Rebirth Count: {RebirthCount}\n"
        set Info += "Current Multiplier: {UsableMultiplier}\n"
        set Info += "Multiplier After Rebirth: {PotentialMultiplier}"
        RebirthInfoBillboard.SetText(S2M(Info))

    <#
    LoadTrackedInfo():void=
        if(Player := OwningPlayers[0]):
            set RebirthCount = RebirthCountTracker.GetValue(Player)
            TryPrint("Rebirth Count: {RebirthCount}")
            set RebirthMultiplierAsInt = EarningMultiplierTracker.GetValue(Player)
            set UsableMultiplier = 1.0 + (RebirthMultiplierAsInt*1.0 / IntMultiplierDetail)
        else:
            TryPrint("No owning players found. Failed to load trackers") #>

    VerifyRebirth(Agent : agent):void=
        if(Player := player[Agent]):
            # Check cooldown timer
            TimeSinceLastRebirth := TimeSincePlayerAdded - LastRebirthTime
            if (TimeSinceLastRebirth < RebirthCooldownSeconds):
                # Calculate remaining cooldown time
                RemainingCooldown := RebirthCooldownSeconds - TimeSinceLastRebirth
                # Show cooldown timer overlay instead of simple HUD message
                spawn{UISystem.ShowRebirthCooldown(Player, RemainingCooldown)}
                Print("Rebirth on cooldown. {RemainingCooldown} seconds remaining.")
                return
            
            # Cooldown has passed, allow rebirth
            spawn{UISystem.ConfirmRebirth(Self,Player)}

    Rebirth(Player : player)<suspends>:void=
        set ExtraDelay = 5.0
        #RebirthCountTracker.SetValue(Player,RebirthCount + 1)
        var SecondsToUse :int= 0
        if(Data := PlayerProfileDataMap[Player]):
            set SecondsToUse = Data.SecondsActive
        else{Print("Failed to load player data for rebirth.")}
        var DataAfterRebirth :player_save_data = player_save_data{SecondsActive:=SecondsToUse}
        set RebirthCount += 1
        TryPrint("Rebirth Count: {RebirthCount}")
        set DataAfterRebirth=DataAfterRebirth.UpdateRebirths(RebirthCount)
        set DataAfterRebirth=DataAfterRebirth.UpdateMultiplier(PotentialMultiplier)
        set UsableMultiplier = PotentialMultiplier
        if(set PlayerProfileDataMap[Player] = DataAfterRebirth){TryPrint("Saved Rebirth Info")}
        else{TryPrint("Failed to save rebirth info.")}
        Sleep(0.01)
        ClearOldNumbers(Player)
        Sleep(0.5)
        #LoadTrackedInfo()
        BackToStart(Player)
        Sleep(0.1)
        UpdatePotentialMultiplier()
        Sleep(0.1)
        DisplayRebirthInfo()
        set ExtraDelay = 0.0
        UISystem.UpdateRebirths(Player, RebirthCount)
        
        # Reset rebirth cooldown timer
        set LastRebirthTime = TimeSincePlayerAdded
        Print("Rebirth cooldown reset. Next rebirth available in {RebirthCooldownSeconds} seconds.")

    ClearOldNumbers(Player : player)<suspends>:void=
        set GoldPerSecond = 0
        set StoredGold = 0
        Sleep(0.3)
        ClearPlayerGold(Player)

    #I don't think i should use the same conditional button for this
    ClearPlayerGold(Player : player)<suspends>:void=
        #CurrentGold := ConditionalButton.GetItemCount(Player,0)
        #TryPrint("Player has {CurrentGold} gold")
        GoldRemover.Remove(Player)
        <#
        TryPrint("Other value is {ConditionalButton.GetItemCount(Player,1)}")
        Sleep(0.1)
        ConditionalButton.SetItemCountRequired(0,CurrentGold)
        Sleep(0.1)
        ConditionalButton.Activate(Player) #>

    BackToStart(Player : player)<suspends>:void=
        for(PlateManager : FirstPlateManager):
            PlateManager.BackToDefaultAll(Player) 
            #PlateManager.Disable()

    #adds gold and updates billboards to show it
    AddToStoredResources():void=
        if(Rounded := Round[GoldPerSecond*UsableMultiplier*TempMultiplier]):
            var BText : string = ClaimTextSettings.TextBeforeGoldPerSecond + "{Format(Rounded)}" + ClaimTextSettings.TextAfterGoldPerSecond
            set BText += ClaimTextSettings.TextBeforeStoredGold + "{Format(StoredGold)}" + ClaimTextSettings.TextAfterStoredGold
            for(Billboard : GoldStorageBillboards):
                Billboard.SetText(S2M(BText)) #updating before adding gold so maybe it will show 0 when you claim & look more satisfying
            set StoredGold += Rounded
            for(Player:OwningPlayers):
                UISystem.UpdateGoldPerSecond(Player,Rounded)
        else:
            TryPrint("ROUNDING FAILED. NOT GOOD.")

    EffectiveGoldPerSecond()<transacts>:float=
        return GoldPerSecond*UsableMultiplier*TempMultiplier

    InitDeviceArray():void=
        if(FirstManager := FirstPlateManager[0]):
            set AllPlateManagers = FirstManager.GetAllManagers(Self)
            TryPrint("{AllPlateManagers.Length} Plate Managers found.")
        
    GetAndIncrementIndex():int=
        set CurrentIndex += 1
        return CurrentIndex - 1
            
        
    #Check if someone is at a claim location. If so grant stored gold to player.
    CheckClaim()<suspends>:void=
        ClaimAmt := StoredGold #We could adjust this later if you don't want instant claim of everything
        for(Player : OwningPlayers): 
            #This system actually makes more sense for co op because it will only give gold to one person, not doubling the output if there are more people
            if(FortChar := Player.GetFortCharacter[]):
                for(ClaimLoc : ResourceClaimLocationProps): #Loops until a claim loc is found with a player on it. returns early after granting.
                    if(Distance(FortChar.GetTransform().Translation, ClaimLoc.GetTransform().Translation) < ClaimDistance):
                        for(Sound : PurchaseSounds):
                            Sound.Play(Player)
                        GrantGold(Player, ClaimAmt) #Grant gold to player. Can add similar grant functions for other resources
                        return


    #NEXT 2 COMMENTS ARE OUTDATED        
    #Grants gold to every player in the game currently.
    #This can be changed to track a certain player, either with separate devices per player, or using a map to track each player's info
    #ACTUAL NEW DESCRIPTION:
    #Inputs : player to grant to, amount to grant during this execution
    GrantGold(Player : player, AmountToGrant : int)<suspends>:void=
        var GoldToGive : int = AmountToGrant #The gold that still needs to be given this execution.
        set StoredGold -= AmountToGrant #Remove gold from  
        #Loop through various amounts of gold, so any amount can be given. - saves memory over extra granters
        #Sleeps are there because I don't trust instantly calling fortnite devices twice in a row. #NEVERMIND IT SEEMS FINE WITHOUT most of THEM
        #Also it kind of looks cool. If it looked cooler to count the low values firt I could switch it up
        # but right now it gets rid of the highest amount first and then lower values.
        # Using else ifs, so if there is an easy big multiple, the lower one doesn't mess it up
        loop:
            Sleep(0.0) #will allow other stuff to happen first. migh help with lag idk
            if(GoldToGive <= 0): #All gold has been given, this call of grantgold is done.
                break
            else if(GoldToGive >= 1000000000):
                GoldGranter.SetNextItem(9)
                GoldGranter.GrantItem(Player)
                set GoldToGive -= 1000000000
            else if(GoldToGive >= 100000000):
                GoldGranter.SetNextItem(8)
                GoldGranter.GrantItem(Player)
                set GoldToGive -= 100000000
            else if(GoldToGive >= 10000000):
                GoldGranter.SetNextItem(7)
                GoldGranter.GrantItem(Player)
                set GoldToGive -= 10000000
            else if(GoldToGive >= 1000000):
                GoldGranter.SetNextItem(6)
                GoldGranter.GrantItem(Player)
                set GoldToGive -= 1000000
            else if(GoldToGive >= 100000):
                GoldGranter.SetNextItem(5)
                GoldGranter.GrantItem(Player)
                set GoldToGive -= 100000
            else if(GoldToGive >= 10000): #If more than 10000 gold is needed, start in that increment.
                GoldGranter.SetNextItem(4) #4 is the index of the 10000 gold item in the item granter
                #Sleep(0.02)
                GoldGranter.GrantItem(Player) #Grant 10000 gold.
                set GoldToGive -= 10000 #10000 gold has been granted, so subtract it from gold to give. loop will continue until no gold needs to be given.
                #Sleep(0.1)
            else if(GoldToGive >= 1000): #If more than 1000 gold is needed, start in that increment.
                GoldGranter.SetNextItem(3) #3 is the index of the 1000 gold item in the item granter
                #Sleep(0.02)
                GoldGranter.GrantItem(Player) 
                set GoldToGive -= 1000
                #Sleep(0.1)
            else if(GoldToGive >= 100):
                GoldGranter.SetNextItem(2) #2 is the index of the 100 gold item in the item granter
                #Sleep(0.02)
                GoldGranter.GrantItem(Player)
                set GoldToGive -= 100
                #Sleep(0.1)
            else if(GoldToGive >= 10):
                GoldGranter.SetNextItem(1) #1 is the index of the 10 gold item in the item granter
                #Sleep(0.02)
                GoldGranter.GrantItem(Player)
                set GoldToGive -= 10
                #Sleep(0.1)
            else if(GoldToGive >= 1):
                GoldGranter.SetNextItem(0) #0 is the index of the 1 gold item in the item granter
                #Sleep(0.02)
                GoldGranter.GrantItem(Player)
                set GoldToGive -= 1
                #Sleep(0.1)
            else:
                break
            
    #Called from other devices to increase the gold per second.
    AddToGoldPerSecond(Amount : int)<suspends>:void=
        set GoldPerSecond += Amount
        TryPrint("{Amount} added to gold per second. Current total per second: {GoldPerSecond}")
        UpdatePotentialMultiplier()

    #Called from other devices to show hud message. Did this instead of accessing the hud device directly
    ShowNotEnoughGold(Agent : agent):void=
        NotEnoughGold.Show(Agent)

    #Called from other devices to award xp on a normal purchase
    #Other special purchases could be added, so they aren't all super low xp amounts
    AwardNormalPurchase(Agent : agent, Cost : int,AccoladeIndex : int):void=
        if(AccoladeIndex >= 0):
            if(Accolade := PurchaseAccoladeDevices[AccoladeIndex]):
                Accolade.Award(Agent)
            else:
                Print("Accolade {AccoladeIndex} not found. Awarding default index accolade.")
                AwardNormalPurchase(Agent,Cost,-1)
        else if(Cost > 15000; Accolade := PurchaseAccoladeDevices[2]):
            Accolade.Award(Agent)
        else if(Cost > 5000; Accolade := PurchaseAccoladeDevices[1]):
            Accolade.Award(Agent)
        else if(Accolade := PurchaseAccoladeDevices[0]):
            Accolade.Award(Agent)
        else:
            Print("No accolades found for purchase.", ?Duration := 50.0)


    StageStr(StgInfo : []tuple(int,int)):string=
        var Str : string = ""
        for(T : StgInfo):
            set Str += "Stage: {T(0)}  Number Of Pressure Plates:{T(1)}\n"
        return Str
    
    MapIndicatorDeviceLoop()<suspends>:void=
        var Pos : vector3 = vector3{}
        var PlayerPos : vector3 = vector3{}
        var Dist : float = 10000.0
        var AvailableGold : int = 0
        var ActiveCount : int = 0
        var ItemToDo : string = ""
        var CheapestToDo : string = ""
        var Cheapest : int = -1
            #MapIndicatorDevice.DeactivateObjectivePulse


        UISystemGenerator := FindCreativeObjectsWithTag(ui_system_tag{})
        var count : int = 0
        for(PotentialUISystem : UISystemGenerator):
            if(GC := UI_Trackers[PotentialUISystem]; count < 1):
                TryPrint("UI system found.")
                set UISystem = GC
                set count += 1 #There should only be one UI system, but this will take the first for consistency
        if(count < 1){TryPrint("FAILED TO FIND UI SYSTEM.")}
        ##if(GC : UI_Trackers = UI_Trackers[GetCreativeObjectsWithTag(ui_system_tag{})[0]]):
        ##TryPrint("Gold remover found.")
        ##set UISystem = GC
        ##else:
        ##    TryPrint("Failed to find gold counter. Will try one more time.")
        ##    Sleep(10.0)
        ##    if(GC2 : UI_Trackers = UI_Trackers[GetCreativeObjectsWithTag(ui_system_tag{})[0]]):
        ##        TryPrint("Gold remover found.")
        ##        set UISystem = GC2
        loop:
            set ItemToDo = ""
            set CheapestToDo = ""
            set Cheapest = -1
            set ActiveCount = 0
            TryPrint("There are {AllPlateManagers.Length} plate managers.")
            set Dist = 40000.0
            Sleep(0.25)
            if(Player := OwningPlayers[0]):
                set AvailableGold = UISystem.GetGold(Player)
                if(FortChar := Player.GetFortCharacter[]):
                    set PlayerPos = FortChar.GetTransform().Translation
                for(Manager : AllPlateManagers):
                    if(Manager.Activity = activity_type_classic.active):
                        set ActiveCount += 1
                        if(Manager.CommonlyUsed.GoldCost <= AvailableGold):
                            PlatePos := Manager.CommonlyUsed.PressurePlate.GetTransform().Translation
                            NewDist := Distance(PlayerPos,PlatePos)
                            if(NewDist < Dist):
                                set Dist = NewDist
                                set Pos = PlatePos + vector3{Z:=MapIndicatorDeviceZOffset}
                                set ItemToDo = Manager.SpecialSettings.Name
                        else if(ItemToDo = "" and (Manager.CommonlyUsed.GoldCost < Cheapest or Cheapest < 0)):
                            set Cheapest = Manager.CommonlyUsed.GoldCost
                            set CheapestToDo = Manager.SpecialSettings.Name
                    else:
                        #TryPrint("AvailableGold: {AvailableGold} GoldCost: {Manager.CommonlyUsed.GoldCost}")
                TryPrint("Looking for pressure plate. {ActiveCount} pressure plates found that are active. The closest is {Dist} away.")
                if(Dist < 40000.0):
                    if(MapIndicatorDevice.TeleportTo[Pos,rotation{}]):
                        MapIndicatorDevice.ActivateObjectivePulse(Player)
                        #Print("Objective still active with dist {Dist}")
                    else:
                        Print("Failed to teleport objective device.")
                else if(ActiveCount > 0):
                    if(TimeSincePlayerAdded < 60.0 or HoldObjectiveAtGoldClaim?):
                        for(Prop : ResourceClaimLocationProps):
                            if(Distance(PlayerPos,Prop.GetTransform().Translation) < Dist):
                                set Dist = Distance(PlayerPos,Prop.GetTransform().Translation)
                                set Pos = Prop.GetTransform().Translation + vector3{Z:=MapIndicatorDeviceZOffset}
                        if(Dist < 40000.0):
                            if(MapIndicatorDevice.TeleportTo[Pos,rotation{}]):
                                MapIndicatorDevice.ActivateObjectivePulse(Player)
                    else:
                        #Print("Objective should deactivate.")
                        DeactivateObjective(Player)
                else:
                    RebirthObjective(Player)
                    #Print("Objective should deactivate.")
                if(ItemToDo = ""):
                    set ItemToDo = CheapestToDo
                UISystem.UpdateToDo(Player, ItemToDo)
            else:
                TryPrint("No owning players found. Failed to find player position.")


    DeactivateObjective(Player:player):void=
        if(Char:=Player.GetFortCharacter[]):
            #Target := Char.GetTransform()
            var Target : transform = RebirthButton.GetTransform()
            if(MapIndicatorDevice.TeleportTo[Target]){}
            else{TryPrint("Failed to deactivate objective.")}
        MapIndicatorDevice.DeactivateObjectivePulse(Player)

    RebirthObjective(Player:player):void=
        MapIndicatorDevice.ActivateObjectivePulse(Player)
        if(Char:=Player.GetFortCharacter[]):
            #Target := Char.GetTransform()
            Target := RebirthButton.GetTransform()
            if(MapIndicatorDevice.TeleportTo[Target]){}
            else{TryPrint("Failed to deactivate objective.")}
            
    CalculateMinimumTime()<suspends>:void=
        if(not RunTestTimeSimulation?):
            Print("Simulation not active.")
            return
        Sleep(8.0)
        var TimeRequired : float = 0.0
        var RemainingPlates : []pressure_plate_with_generator = AllPlateManagers
        var SimActivityMap : [int]tuple(activity_type_classic,pressure_plate_with_generator) = map{}
        for(Plate : AllPlateManagers):
            set RemainingPlates += array{Plate}
            if(set SimActivityMap[Plate.PlateIndex] = (activity_type_classic.inactive,Plate)){}
        if(FirstPlate := FirstPlateManager[0]):
            if(set SimActivityMap[FirstPlate.PlateIndex] = (activity_type_classic.active,FirstPlate)){}
        else:
            TryPrint("Failed to find first plate manager.")
        var EmergencyBreakCount : int = 50000
        var CurrentMoney : int = 0
        var CurrentPerSec : int = 0
        #FreeCount : int = 0
        loop:
            Print("Simulation active.")
            Sleep(0.0)
            #if(Mod[EmergencyBreakCount,10] = 0):
                #Sleep(0.0)
            if(EmergencyBreakCount <= 0):
                Print("Emergency break reached.")
                break
            else{set EmergencyBreakCount -= 1}
            var AvailablePlatesUseful : []pressure_plate_with_generator = array{}
            var OtherAvailablePlates : []pressure_plate_with_generator = array{}
            Print("Current Money: {CurrentMoney} Current Per Second: {CurrentPerSec} Time Required: {TimeRequired}")
            for(Index -> Info: SimActivityMap):
                if(Info(0) = activity_type_classic.active):
                    if(Info(1).CommonlyUsed.GoldPerSecond > 0):
                        set AvailablePlatesUseful += array{Info(1)}
                    else:
                        set OtherAvailablePlates += array{Info(1)}
            if(var CheapestPlate : pressure_plate_with_generator = AvailablePlatesUseful[0]):
                for(Plate : AvailablePlatesUseful):
                    if(Plate.CommonlyUsed.GoldCost < CheapestPlate.CommonlyUsed.GoldCost):
                        set CheapestPlate = Plate
                if(CurrentMoney >= CheapestPlate.CommonlyUsed.GoldCost):
                    set CurrentMoney -= CheapestPlate.CommonlyUsed.GoldCost
                    set CurrentPerSec += CheapestPlate.CommonlyUsed.GoldPerSecond
                    if(set SimActivityMap[CheapestPlate.PlateIndex] = (activity_type_classic.purchased,CheapestPlate)){}
                    for(Next : CheapestPlate.GetNextManagers()):
                        if(set SimActivityMap[Next.PlateIndex] = (activity_type_classic.active,Next)){}
                else:
                    set TimeRequired += 1.0 * SimBySeconds
                    set CurrentMoney += CurrentPerSec * SimBySeconds
            else if(var CheapestPlate : pressure_plate_with_generator = OtherAvailablePlates[0]):
                for(Plate : OtherAvailablePlates):
                    if(Plate.CommonlyUsed.GoldCost < CheapestPlate.CommonlyUsed.GoldCost):
                        set CheapestPlate = Plate
                if(CurrentMoney >= CheapestPlate.CommonlyUsed.GoldCost):
                    set CurrentMoney -= CheapestPlate.CommonlyUsed.GoldCost
                    set CurrentPerSec += CheapestPlate.CommonlyUsed.GoldPerSecond
                    if(set SimActivityMap[CheapestPlate.PlateIndex] = (activity_type_classic.purchased,CheapestPlate)){}
                    for(Next : CheapestPlate.GetNextManagers()):
                        if(set SimActivityMap[Next.PlateIndex] = (activity_type_classic.active,Next)){}
                else:
                    set TimeRequired += 1.0 * SimBySeconds
                    set CurrentMoney += CurrentPerSec * SimBySeconds
            else:
                Print("Current Money: {CurrentMoney} Current Per Second: {CurrentPerSec} Time Required: {TimeRequired}")
                if(Rounded := Round[TimeRequired]):
                    Print("Simulation Complete. This tycoon would probably take minimum {FormatTime(Rounded)} to complete without rebirthing.")
                    return
                else:
                    Print("Simulation Complete. This tycoon will probably take {TimeRequired} to complete.")
                return




    CreatureStuff()<suspends>:void=
        Spawners:= FindCreativeObjectsWithTag(creature_spawner_tag{})
        for(Spawner : Spawners):
            if(ConfirmedSpawner := creature_spawner_device[Spawner]):
                set CreatureSpawners += array{ConfirmedSpawner}
            else:
                Print("Failed to confirm creature spawner. Object may be tagged wrong")
        for(ThisSpawner : CreatureSpawners):
            ThisSpawner.EliminatedEvent.Subscribe(CreatureEliminated)

    CreatureEliminated(AI_Result : device_ai_interaction_result):void=
        MaybeSource := AI_Result.Source
        MaybeTarget := AI_Result.Target
        if(Source : agent = MaybeSource?):
            if(Player := player[Source]):
                for(OwningPlayer : OwningPlayers):
                    if(Player = OwningPlayer):
                        if(Rounded := Round[GoldPerSecond*UsableMultiplier*TempMultiplier*CreatureElimMultiplier]):
                            spawn{GrantGold(Player, Rounded)}
                            for(Accolade : CREATUREaccolades):
                                Accolade.Award(Player)
                            return
                        else{Print("ROUNDING FAILED on creature elim. NOT GOOD.")}
            else{Print("Creature elimination not by player.")}
        else{Print("Creature elimination not by any agent.")}


        
                    
                    
                

        

            
        




                    
        

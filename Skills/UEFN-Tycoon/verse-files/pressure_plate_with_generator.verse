
using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Verse.org/Simulation }
using { /Verse.org/Simulation/Tags }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Devices/CreativeAnimation }



var PlayerProfileDataMap:weak_map(player, player_save_data) = map{}

player_save_data := class<persistable><final>:
    Rebirths:int=0
    Multiplier:float=1.0
    ActivityMap:[int]int=map{} #[Index](0:inactive, 1:purchased, 2:active)
    SecondsActive:int=0
    # Version 1 repairs activity values written by the pre-startup-safe restore flow.
    NodeSaveSchemaVersion:int=0

    UpdateRebirths(NewVal : int)<transacts>:player_save_data=
        return player_save_data{Rebirths:=NewVal, Multiplier:=Multiplier, ActivityMap:=ActivityMap, SecondsActive:=SecondsActive, NodeSaveSchemaVersion:=NodeSaveSchemaVersion}

    UpdateMultiplier(NewVal : float)<transacts>:player_save_data=
        return player_save_data{Rebirths:=Rebirths, Multiplier:=NewVal, ActivityMap:=ActivityMap, SecondsActive:=SecondsActive, NodeSaveSchemaVersion:=NodeSaveSchemaVersion}

    UpdateActivityMap(NewMap : [int]int)<transacts>:player_save_data=
        return player_save_data{Rebirths:=Rebirths, Multiplier:=Multiplier, ActivityMap:=NewMap, SecondsActive:=SecondsActive, NodeSaveSchemaVersion:=NodeSaveSchemaVersion}

    AddToSecondsActive(SecondsToAdd : int)<transacts>:player_save_data=
        return player_save_data{Rebirths:=Rebirths, Multiplier:=Multiplier, ActivityMap:=ActivityMap, SecondsActive:=SecondsActive+SecondsToAdd, NodeSaveSchemaVersion:=NodeSaveSchemaVersion}

    UpdateNodeSaveSchemaVersion(NewVersion : int)<transacts>:player_save_data=
        return player_save_data{Rebirths:=Rebirths, Multiplier:=Multiplier, ActivityMap:=ActivityMap, SecondsActive:=SecondsActive, NodeSaveSchemaVersion:=NewVersion}

extra_cinematic_settings := class<concrete>:
    @editable
    CinematicToAdjust : cinematic_sequence_device = cinematic_sequence_device{}

    @editable
    NewPlaybackRate : float := 1.0

billboard_text_settings := class<concrete>:
    @editable
    TextBeforeGoldAmount : string = "$"

    @editable
    TextAfterGoldAmount : string = ""

    @editable
    TextOnZeroCost : string = "FREE"

    @editable
    ShowGoldPerSecond : logic = true
    
    @editable
    ShowGoldPerSecondIfZero : logic = false

    @editable
    TextBeforeGoldPerSecond : string = "\n+$"

    @editable
    TextAfterGoldPerSecond : string = "/s"

# See https://dev.epicgames.com/documentation/en-us/uefn/create-your-own-device-in-verse for how to create a verse device.
special_settings_classic := class<concrete>:

    @editable
    Name : string = "Unnamed Pressure Plate"

    # Leave at -1 to preserve the legacy, graph-assigned PlateIndex save key.
    # Assign a unique positive value to new Tycoon Nodes so their saved state
    # remains stable when the graph changes or new nodes are inserted.
    @editable
    StableNodeId : int = -1

    @editable
    AccoladeIndexOverride : int = -1

    @editable
    CutsceneToPlay : []cinematic_sequence_device = array{}

    @editable
    CinematicsToPlay : []cinematic_sequence_device = array{}

    @editable
    CinematicsToStop : []cinematic_sequence_device = array{}



    @editable
    ExtraCinematicChanges : []extra_cinematic_settings = array{}

    #@editable
    #SpecialAnimationIndex : int = -1

    #Will Activity be set to active on start
    @editable
    StartAsActive : logic = false

    @editable
    DistanceToPress : float = 160.0 #Default distance. Can be changed so we could have a bigger plate or something for certain things.

    @editable
    BillboardTextSettings : billboard_text_settings = billboard_text_settings{}

    TimeToWaitAfterFailedPurchaseAttempt : float = 3.0



gold_currency_manager := class(tag){}

purchase_audio := class(tag){}

# Mark a pressure_plate_with_generator with this tag to opt it into automatic
# Tycoon Node chaining. Duplicating a tagged node preserves the markup, so MCP
# can create later nodes without assigning a NextManagers device reference.
tycoon_node := class(tag){}

activity_type_classic := enum{purchased, active, inactive}

current_move_direction := enum{up, down, none}

commonly_used_settings := class<concrete>:
    @editable
    PressurePlate : creative_prop = creative_prop{}

    @editable
    PriceBillboards : []billboard_device = array{}

    @editable 
    GoldCost : int = 0

    @editable
    GoldPerSecond : int = 0

    @editable
    PropsToShow : []creative_prop = array{}

    @editable
    PropsToHide : []creative_prop = array{}

    @editable
    NextManagers : []pressure_plate_with_generator = array{}

assets_and_animation_settings := class<concrete>:
    @editable
    HideZLevel : float = -750.0

    @editable
    PlateShowAnimationTime : float = 1.0

    @editable
    ShowAnimationTime : float = 2.5

    @editable
    HideAnimationTime : float = 2.0

    @editable
    AnimationsToPlay : []generic_animation_device = array{}

    @editable
    AnimationsToStop : []generic_animation_device = array{}

sound_settings := class<concrete>:
    @editable
    AdditionalPurchaseSounds : []audio_player_device = array{}

    @editable
    SlamSound : audio_player_device = audio_player_device{}

animation_curves_settings := class<concrete>:
    @editable
    var PlateShowAnimationCurve : animation_curve = animation_curve{}

    @editable
    var PlateHideAnimationCurve : animation_curve = animation_curve{}

    @editable
    var ShowAnimationCurve : animation_curve = animation_curve{X0:=0.1,Y0:=0.225,BounceTime:=0.7,BounceScale:=1.25}

    @editable
    var HideAnimationCurve : animation_curve = animation_curve{}

    @editable
    AnimationDelay : float = 0.0


# A Verse-authored creative device that can be placed in a level
pressure_plate_with_generator := class(creative_device):

    @editable
    CommonlyUsed : commonly_used_settings = commonly_used_settings{}

    @editable
    AssetsAndAnimation : assets_and_animation_settings = assets_and_animation_settings{}

    @editable
    Sound : sound_settings = sound_settings{}

    @editable
    AnimationCurves : animation_curves_settings = animation_curves_settings{}

    var PurchaseAudio : audio_player_device = audio_player_device{}

    var AllowPurchaseSound : logic = true

    var EverySingleProp : []creative_prop = array{}

    var PropPosMap : [int]vector3 = map{}

    var MoveDirectionMap : [int]current_move_direction = map{}

    var PlateIndex : int = -1

    #@editable
    #OtherBillboards : []billboard_device = array{}
    
    var Billboards : []billboard_device = array{}

    var PreviousManagers : []pressure_plate_with_generator = array{}

    @editable
    SpecialSettings : special_settings_classic = special_settings_classic{}

    #Just for ease of use. I get the location at the start once and store it.
    var PressurePlateLoc : vector3 = vector3{}

    var MainTycoonManager : tycoon_currency_manager = tycoon_currency_manager{}

    var ConditionalButton : conditional_button_device = conditional_button_device{}

    var GoldGranter : item_granter_device = item_granter_device{}

    var HasEnoughMoney : logic = false

    #This will get updated by the one in special settings.
    var DistanceToPress : float = 200.0

    #Tells whether walking over the plate does anything. Not directly linked to the pressure plate's visibility, but they should be the same.
    var Activity : activity_type_classic = activity_type_classic.inactive #switched to defaulting to inactive for safety
    #switched from logic to enum so we can distinguish purchased from not yet active for future saving purposes.

    var OwningPlayers : []player = array{}

    var MaxPlayersPerPlot : int = 1

    var ExtraDelay : float = 0.0

    var TempClock : float = 0.0

    # Saved visibility can be requested as soon as a plot is claimed.  Keep it
    # separate from device startup so animations never run before PropPosMap is ready.
    var StartupVisibilityReady : logic = false

    var PressurePlateIndex : int = 2000

    var HideStartIndex : int = 500

    var ShowStartIndex : int = 0

    DelayToStartAutoAnimationsAfterRebirth : float = 10.0


    BackToDefaultAll(Player : player)<suspends>:void=
        set ExtraDelay = 5.0
        #ClearCheckpointTracker()
        for(Manager : GetNextManagers()):
            Manager.BackToDefaultAll(Player)
        StartingVisibilityAndActivitySettings()
        CheckSaveData(Player)
        set ExtraDelay = 0.0

    DoubleCheckOwningPlayers()<suspends>:void=
        Sleep(5.0)
        MainTycoonManager.SetOwningPlayers(OwningPlayers)

    AddPlayerToPlot(Player : player)<suspends>:void=
        if(OwningPlayers.Length >= MaxPlayersPerPlot):
            return
        else:
            set OwningPlayers += array{Player}
            CheckSaveData(Player)
            for(Manager : GetNextManagers()):
                Manager.AddPlayerToPlot(Player)
            MainTycoonManager.SetOwningPlayers(OwningPlayers)
            spawn{DoubleCheckOwningPlayers()}
            #AttemptLoadSaved(Player)

    #AddPlayerToPlotRebirth(Player : player)<suspends>:void=
    #    if(OwningPlayers.Length >= MaxPlayersPerPlot):
    #        return
    #    else:
    #        set OwningPlayers += array{Player}
    #        CheckSaveData(Player)
    #        for(Manager : CommonlyUsed.NextManagers):
    #            Manager.BackToDefault(Player)
    
    CheckSaveData(Player : player):void=
        PersistenceKey := GetPersistenceKey()
        if:
            not PlayerProfileDataMap[Player]
            set PlayerProfileDataMap[Player] = player_save_data{}
        else if(Data := PlayerProfileDataMap[Player]):
            if(not Data.ActivityMap[PersistenceKey]):
                OldData := Data
                var NewData :player_save_data= Data.UpdateActivityMap(Data.ActivityMap.AddToMap(PersistenceKey,0))
                if(SpecialSettings.StartAsActive?):
                    set NewData = NewData.UpdateActivityMap(NewData.ActivityMap.AddToMap(PersistenceKey,2))
                if(set PlayerProfileDataMap[Player] = NewData):
                    TryPrint("SUCCESSFULLY SAVED DATA",?Duration:=1.0)
                else{TryPrint("ERROR WITH SAVE DATA - 2",?Duration:=90.0)}
            else if(FoundActivity := Data.ActivityMap[PersistenceKey]):
                if(FoundActivity = 0):
                    set Activity = activity_type_classic.inactive
                else if(FoundActivity = 1):
                    set Activity = activity_type_classic.purchased
                else if(FoundActivity = 2):
                    set Activity = activity_type_classic.active
        else{TryPrint("ERROR WITH SAVE DATA",?Duration:=90.0)}
        spawn{RecoverVisibilitySettings()}

    RecoverVisibilitySettings()<suspends>:void=
        # A player can claim their plot before this device has recorded its prop
        # positions.  Wait for the initial default-visibility pass to finish, then
        # re-read the persisted state because startup temporarily sets its defaults.
        loop:
            if(StartupVisibilityReady?):
                break
            Sleep(0.05)
        if(Player := OwningPlayers[0]):
            MainTycoonManager.MigrateLegacyNodeStates(Player)
        RestoreSavedActivity()
        if(PlateIndex >= 0):
            Sleep(0.05 * PlateIndex)
        if(Activity = activity_type_classic.purchased):
            CommonlyUsed.PressurePlate.Animatedown(PressurePlateIndex)
            ShowAndHide()
        else if(Activity = activity_type_classic.inactive):
            CommonlyUsed.PressurePlate.Animatedown(PressurePlateIndex)
            DefaultHidden()
            DefaultShown()
        else:
            CommonlyUsed.PressurePlate.AnimateUp(PressurePlateIndex)

    RestoreSavedActivity():void=
        if(Player := OwningPlayers[0]):
            if(Data := PlayerProfileDataMap[Player]):
                PersistenceKey := GetPersistenceKey()
                if(FoundActivity := Data.ActivityMap[PersistenceKey]):
                    if(FoundActivity = 0):
                        set Activity = activity_type_classic.inactive
                    else if(FoundActivity = 1):
                        set Activity = activity_type_classic.purchased
                    else if(FoundActivity = 2):
                        set Activity = activity_type_classic.active
        

    SavePurchase():void=
        PersistenceKey := GetPersistenceKey()
        for(Player : OwningPlayers):
            if(Data := PlayerProfileDataMap[Player]):
                OldData := Data
                NewData := Data.UpdateActivityMap(Data.ActivityMap.AddToMap(PersistenceKey,1))
                if(set PlayerProfileDataMap[Player] = NewData):
                    TryPrint("SUCCESSFULLY SAVED DATA",?Duration:=1.0)
                else{TryPrint("ERROR WITH SAVE DATA - 2",?Duration:=90.0)}
            else{TryPrint("ERROR WITH SAVE DATA",?Duration:=90.0)}

    SaveActive():void=
        PersistenceKey := GetPersistenceKey()
        for(Player : OwningPlayers):
            if(Data := PlayerProfileDataMap[Player]):
                OldData := Data
                NewData := Data.UpdateActivityMap(Data.ActivityMap.AddToMap(PersistenceKey,2))
                if(set PlayerProfileDataMap[Player] = NewData):
                    TryPrint("SUCCESSFULLY SAVED DATA",?Duration:=1.0)
                else{TryPrint("ERROR WITH SAVE DATA - 2",?Duration:=90.0)}
            else{TryPrint("ERROR WITH SAVE DATA",?Duration:=90.0)}


    (Map:[int]int).AddToMap(Index : int, Value : int)<transacts>:[int]int=
        var Copy : [int]int = Map
        if(set Copy[Index] = Value):
            return Copy
        return Map

        

    <#
    AttemptLoadSaved(Player : player):void=
        if(Tracker := SpecialSettings.CheckpointTrackerDevice[0]):
            Tracker.Load(Player)
            if(Tracker.GetValue(Player) = 1):
    
    SaveToTracker(Player : player):void=
        if(Tracker := SpecialSettings.CheckpointTrackerDevice[0]):
            Tracker.SetValue(Player,1)
    #>

    S2M<localizes>(S:string):message="{S}"

    ResetPlayers()<suspends>:void=
        set OwningPlayers = array{}
        for(Manager : GetNextManagers()):
            Manager.ResetPlayers()
        MainTycoonManager.SetOwningPlayers(OwningPlayers)
    
    SetBillboardText():void=
        var BillboardString : string = ""
        if(CommonlyUsed.GoldCost = 0):
            set BillboardString += SpecialSettings.BillboardTextSettings.TextOnZeroCost
        else:
            set BillboardString += SpecialSettings.BillboardTextSettings.TextBeforeGoldAmount+"{Format(CommonlyUsed.GoldCost)}"+SpecialSettings.BillboardTextSettings.TextAfterGoldAmount
        if(SpecialSettings.BillboardTextSettings.ShowGoldPerSecond?):
            if(CommonlyUsed.GoldPerSecond > 0):
                set BillboardString += SpecialSettings.BillboardTextSettings.TextBeforeGoldPerSecond+"{Format(CommonlyUsed.GoldPerSecond)}"+SpecialSettings.BillboardTextSettings.TextAfterGoldPerSecond
            else if(SpecialSettings.BillboardTextSettings.ShowGoldPerSecondIfZero?):
                set BillboardString += SpecialSettings.BillboardTextSettings.TextBeforeGoldPerSecond+"0"+SpecialSettings.BillboardTextSettings.TextAfterGoldPerSecond
        for(Billboard : CommonlyUsed.PriceBillboards):
            Billboard.SetText(S2M(BillboardString))

    InitBillboards():void=
        #for(Billboard : OtherBillboards):
        #    set Billboards += array{Billboard}
        for(Billboard : CommonlyUsed.PriceBillboards):
            set Billboards += array{Billboard}

    BillboardBackup()<suspends>:void=
        TryPrint("Billboard backup started")
        if(PlateIndex >= 0):
            Sleep(0.1 * PlateIndex)
        if(PlateIndex = 5):
            TryPrint("Special test. Plate 5", ?Duration:=10.0)
        loop:
            Sleep(5.0)
            if(Activity = activity_type_classic.active):
                TryPrint("Plate {PlateIndex} active")
                TryPrint("Showing billboards")
                #for(Billboard : Billboards):
                #    Billboard.ShowText()
            else if(Activity = activity_type_classic.inactive):
                TryPrint("Plate {PlateIndex} inactive")
                TryPrint("Hiding billboards")
                #for(Billboard : Billboards):
                #    Billboard.HideText()
            else if(Activity = activity_type_classic.purchased):
                TryPrint("Plate {PlateIndex} purchased")
                TryPrint("Hiding billboards")
                #for(Billboard : Billboards):
                #    Billboard.HideText()
            else:
                TryPrint("Plate {PlateIndex} broken")
                TryPrint("Hiding billboards")
                #for(Billboard : Billboards):
                #    Billboard.HideText()

    RunTempClock()<suspends>:void=
        loop:
            Sleep(1.0)
            set TempClock += 1.0

    InitPropPosMap()<suspends>:void=
        set PressurePlateLoc = CommonlyUsed.PressurePlate.GetTransform().Translation #Store location of pressure plate for ease of use.
        set ShowStartIndex = 0

        set HideStartIndex = CommonlyUsed.PropsToShow.Length

        for(Index -> Prop : CommonlyUsed.PropsToShow):
            Sleep(0.05)
            Loc := Prop.GetTransform().Translation
            if(set PropPosMap[Index] = Loc){}
            else{TryPrint("Failed to set prop starting position",?Duration:=90.0)}
            if(set MoveDirectionMap[Index] = current_move_direction.none){}
            else{TryPrint("Failed to set prop starting direction",?Duration:=90.0)}
        TryPrint("Plate {PlateIndex} Done setting starting positions for props to show",?Duration:=10.0)
        for(Index -> Prop : CommonlyUsed.PropsToHide):
            Sleep(0.05)
            Loc2 := Prop.GetTransform().Translation
            if(set PropPosMap[Index + HideStartIndex] = Loc2){}
            else{TryPrint("Failed to get set starting position",?Duration:=90.0)}
            if(set MoveDirectionMap[Index + HideStartIndex] = current_move_direction.none){}
            else{TryPrint("Failed to set prop starting direction",?Duration:=90.0)}
        TryPrint("Plate {PlateIndex} Done setting starting positions for props to hide",?Duration:=10.0)
        PPLoc := CommonlyUsed.PressurePlate.GetTransform().Translation
        if(set PropPosMap[PressurePlateIndex] = PPLoc){}
        else{TryPrint("Failed to get set starting position",?Duration:=90.0)}
        if(set MoveDirectionMap[PressurePlateIndex] = current_move_direction.none){}
        else{TryPrint("Failed to set prop starting direction",?Duration:=90.0)}
        TryPrint("Plate {PlateIndex} Done setting starting positions for pressure plate",?Duration:=10.0)

    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        spawn{Activate()}
        spawn{FacePlayer()}

    Activate()<suspends>:void=
        #spawn{RunTempClock()}
        Sleep(3.0)
        Sleep(0.05 * PlateIndex)
        InitPropPosMap()
        Sleep(1.0)
        InitBillboards()
        SetBillboardText()
        #TryPrint("Should start billboard backup")
        #spawn{BillboardBackup()}
        Prep()
        Sleep(0.5)
        Setup()
        Sleep(0.2)
        TryPrint("Starting pressure plate with generator {PlateIndex}",?Duration:=20.0)
        StartingVisibilityAndActivitySettings()
        set StartupVisibilityReady = true
        TryPrint("Starting pressure plate with generator {PlateIndex} complete",?Duration:=20.0)

        #CONTINUOUS
        loop: #loop constantly to check if owning player is standing on a pressure plate.
            Sleep(0.1 + ExtraDelay)
            for(Player : OwningPlayers):
                CheckLocation(Player)
            #if(OwningPlayers.Length < 1):
            #    TryPrint("No owning players on plate {PlateIndex}",?Duration:=20.0)

    ResetEverythingForAll()<suspends>:void=
        ResetEverything()
        for(Manager : GetNextManagers()):
            Manager.ResetEverything()
        ResetEverything()
        
    #mainly for players leaving i think. idk nothing is maintained right anymore
    ResetEverything()<suspends>:void=
        set ExtraDelay = 5.0
        Sleep(0.4)
        ResetPlayers()
        StartingVisibilityAndActivitySettings()
        set ExtraDelay = 0.0

    Prep()<suspends>:void=
        if(SpecialSettings.StartAsActive?):
            SendPreviousMangers()

    StartingVisibilityAndActivitySettings():void=
        if(SpecialSettings.StartAsActive?): #If the device is set as active, the pressure plate shows on start, and Activity set to active
            set Activity = activity_type_classic.active
            TryPrint("Plate {PlateIndex} is active",?Duration:=70.0)
            CommonlyUsed.PressurePlate.AnimateUp(PressurePlateIndex)
            #for(Billboard : Billboards):
            #    Billboard.ShowText()
        else:
            set Activity = activity_type_classic.inactive 
            CommonlyUsed.PressurePlate.Animatedown(PressurePlateIndex) #If it's not active, the pressure plate is hidden on start.
            TryPrint("Plate {PlateIndex} is inactive",?Duration:=20.0)
            #for(Billboard : Billboards):
            #    Billboard.HideText()
            #    TryPrint("Hiding billboards for start")
        #Hide every prop, so they can show when the pressure plate is pressed.
        DefaultHidden()
        DefaultShown()
        ResetAnimations()


    Setup():void=
        #SETUP
    
        set DistanceToPress = SpecialSettings.DistanceToPress #Also just for ease of use but really completely unnecessary because I'm only using it once.
        StartingVisibilityAndActivitySettings()
        
        #This looks messy, but it keeps the settings much simpler.
        #I created a verse tag that I attached to the tycoon currency manager in the editor. 
        #Then the tycoon currency manager is directly connected with @editables to the other things that are used often, such as the granter and the conditional button.
        #Also, since all the resource stuff routes through that, it should be easy enough to add changes like a place to collect like you mentioned.
        var FirstPlate : pressure_plate_with_generator = Self
        if(ActualFirst := PreviousManagers[0]):
            set FirstPlate = ActualFirst
        AudioGenerator := FindCreativeObjectsWithTag(purchase_audio{})
        var count : int = 0
        for(PotentialAudio : AudioGenerator):
            if(Audio := audio_player_device[PotentialAudio]; count < 1):
                TryPrint("UI system found.")
                set PurchaseAudio = Audio
                set count += 1 #There should only be one purchase audio, but this will take the first for consistency
        if(count < 1){TryPrint("Failed to device for purchase audio. Check that the audio player has the verse tag", ?Duration:=200.0)}

        var Dist : float = -1.0
        ManagerGenerator := FindCreativeObjectsWithTag(gold_currency_manager{})
        for(PotentialManager : ManagerGenerator):
            if(ActualManager := tycoon_currency_manager[PotentialManager]):
                NewDist := Distance(ActualManager.GetTransform().Translation,FirstPlate.GetTransform().Translation)
                if((NewDist < Dist) or (Dist < 0.0)):
                    set MainTycoonManager = ActualManager
                    set Dist = NewDist
        if(Dist >= 0.0):
            #Storing references to these, so they can be accessed easily without worrying about the tag.
            set ConditionalButton = MainTycoonManager.ConditionalButton
            set GoldGranter = MainTycoonManager.GoldGranter
            #ConditionalButton.ActivatedEvent.Subscribe(OnPurchaseSuccessful)  #Triggers the function on purchase successful when the conditional button is activated AND the player has enough money.
            #ConditionalButton.NotEnoughItemsEvent.Subscribe(OnPurchaseFailed) #Triggers on failed if the conditional button attempted activation, but gold was not enough.
        else{TryPrint("Failed to find currency manager")}  #If the tag doesn't show up, this will show in testing. It shouldn't happen tho if we don't do anything to the tag.
        
        

        
    #Probably safe to delete now
    #OnPurchaseFailed(Agent : agent):void=
    #    TryPrint("Not enough money")
    #    set HasEnoughMoney = false
    #    MainTycoonManager.ShowNotEnoughGold(Agent)
    #
    #OnPurchaseSuccessful(Agent : agent):void=
    #    TryPrint("Money spent")
    #    set HasEnoughMoney = true


    #Check if player is on the pressure plate   #IMPORTANT NOTE: We should try to switch to having a central pivot on the pressure plate so that the location that this uses is not off center.
    CheckLocation(Player : player)<suspends>:void=
        if(FortChar := Player.GetFortCharacter[]): #You have to get the player's character to get any location info
            if(Distance(FortChar.GetTransform().Translation, PressurePlateLoc) < DistanceToPress): #Check that distance to the plate is below the threshold
                if(Activity = activity_type_classic.active): #Confirm that the pressure plate is active. If it is hidden, or already has been pressed, this should be false.
                    #Really it might have been better to do this check first idk.
                    OnPlatePressed(Player)
            if(Activity = activity_type_classic.active):
                #TryPrint("Player is {Distance(FortChar.GetTransform().Translation, PressurePlateLoc)} away from plate {PlateIndex}",?Duration:=100.1)
        else:
            #TryPrint("Failed to get player character",?Duration:=90.0)

    OnPlatePressed(Player : player)<suspends>:void=
        TryPrint("Plate pressed, Attempting to purchase",?Duration:=50.0)
        if(CommonlyUsed.GoldCost > 0):
            #This doesn't look great, but I think it's the most reliable way to do this easily
            sync:
                race:
                    loop:      
                        ConditionalButton.NotEnoughItemsEvent.Await()
                        MainTycoonManager.ShowNotEnoughGold(Player)
                        Sleep(SpecialSettings.TimeToWaitAfterFailedPurchaseAttempt)
                        return #leave function; player doesn't have enough gold
                    loop:
                        ConditionalButton.ActivatedEvent.Await()
                        break #Continue 
                loop:
                    ConditionalButton.SetItemCountRequired(0,CommonlyUsed.GoldCost) #Set the cost of the item to the gold cost. 0 for gold. We could do other resources on the same button probably.
                    ConditionalButton.Activate(Player) #Activate the conditional button, which will trigger the OnPurchaseSuccessf
                    Sleep(0.1)
                    break
        MainTycoonManager.AwardNormalPurchase(Player,CommonlyUsed.GoldCost,SpecialSettings.AccoladeIndexOverride) #XP Award for buying
        #MainTycoonManager.IncStageTracker(Player)
        spawn{AttemptPurchaseAudio()}
        SuccessfulPurchase(Player) #If the gold cost is 0, or the player had enough gold, award the purchase.
        #SaveToTracker(Player)

    SuccessfulPurchase(Player : player)<suspends>:void=
        TryPrint("Successful purchase",?Duration:=100.0)
        ToggleCinematics()
        AdjustCinematics()
        #If player has enough gold, or it was free.
        set Activity = activity_type_classic.purchased #This device was purchased. Deactivate button, otherwise it will keep purchasing.
        SavePurchase()
        if(CommonlyUsed.GoldPerSecond > 0): #If device pays out gold, the value to pay is added to the tycoon currency manager.
            MainTycoonManager.AddToGoldPerSecond(CommonlyUsed.GoldPerSecond)
        CommonlyUsed.PressurePlate.Animatedown(PressurePlateIndex) #Pressure plate is inactive, so hide it. #idk why I chose to put this here and not with the isactive update
        spawn{ShowAndHide()} 
        #for(Billboard : Billboards):
        #    Billboard.HideText()
        for(Manager : GetNextManagers()): #Tell the next verse manager to activate.
            if(Manager.Activity = activity_type_classic.inactive):
                Manager.SetActive()
            else:
                TryPrint("Next manager already active or purchased")

    ToggleCinematics():void=
        for(Player : OwningPlayers):
            for(Cutscene : SpecialSettings.CutsceneToPlay):
                Cutscene.Play()
        for(Cinematic : SpecialSettings.CinematicsToPlay):
            Cinematic.Play()
        for(Cinematic : SpecialSettings.CinematicsToStop):
            Cinematic.GoToEndAndStop()
        for(ThisAnimation : AssetsAndAnimation.AnimationsToStop):
            ThisAnimation.StopAnimating()
        for(ThisAnimation : AssetsAndAnimation.AnimationsToPlay):
            ThisAnimation.StartAnimating(InfoString())
        
    InfoString():string=
        return "Plate {PlateIndex}, {SpecialSettings.Name}"

    ResetAnimations():void=
        AllAnimations : []generic_animation_device = AssetsAndAnimation.AnimationsToStop + AssetsAndAnimation.AnimationsToPlay
        for(ThisAnimation : AllAnimations):
            ThisAnimation.StopAnimating()
        spawn{ActivateAutomaticAnimations(AllAnimations)}

    ActivateAutomaticAnimations(Animations : []generic_animation_device)<suspends>:void=
        Sleep(DelayToStartAutoAnimationsAfterRebirth)
        for(ThisAnimation : Animations):
            if(ThisAnimation.StartByDefault?):
                ThisAnimation.StartAnimating(InfoString())
        

    AdjustCinematics():void=
        for(Setting : SpecialSettings.ExtraCinematicChanges):
            Setting.CinematicToAdjust.SetPlayRate(Setting.NewPlaybackRate)

    SetActive():void=
        SaveActive()
        set Activity = activity_type_classic.active
        CommonlyUsed.PressurePlate.AnimateUp(PressurePlateIndex)
        #for(Billboard : Billboards):
        #    Billboard.ShowText()

    # Old nodes intentionally keep their existing dynamic PlateIndex keys.
    # New nodes can opt into a stable ID without changing any graph traversal,
    # device connection, or legacy player save entry.
    GetPersistenceKey()<transacts>:int=
        if(SpecialSettings.StableNodeId >= 0):
            return SpecialSettings.StableNodeId
        return PlateIndex

    #theoretically this will get this and all subsequent managers in an array
    #SHOULD WORK WITH PATHS THAT REJOIN NOW - i think
    GetAllManagers(Base : tycoon_currency_manager):[]pressure_plate_with_generator=
        set PlateIndex = Base.GetAndIncrementIndex()
        var Managers : []pressure_plate_with_generator = array{}
        var ToCheckNext : []pressure_plate_with_generator = array{Self}
        loop:
            var TempNext : []pressure_plate_with_generator = array{}
            if(ToCheckNext.Length < 1):
                break
            else:
                for(Manager : ToCheckNext):
                    set Manager.PlateIndex = Base.GetAndIncrementIndex()
                    set Managers += array{Manager}
                    for(Next : Manager.GetNextManagers()):
                        if(Next.PlateIndex < 0):
                            set TempNext += array{Next}
                set ToCheckNext = TempNext
        return Managers



    <#
    ClearCheckpointTracker():void=
        for(Tracker : SpecialSettings.CheckpointTrackerDevice):
            for(Player : OwningPlayers):
                Tracker.Reset(Player) #>

    SendPreviousMangers():void=
        for(Manager : GetNextManagers()):
            set Manager.PreviousManagers = PreviousManagers + array{Self}
            Manager.SendPreviousMangers()

    # Existing maps can keep explicit NextManagers references for branches or
    # exceptional layouts. A node with no explicit successor instead finds the
    # closest tagged Tycoon Node in front of it on the map's +Y progression lane.
    # This is intentionally spatial: MCP only needs to duplicate a tagged node
    # and place the duplicate farther along +Y; no Verse-device reference needs
    # to be assigned in the UEFN Details panel.
    GetAutomaticNextManagers()<transacts>:[]pressure_plate_with_generator=
        var NextManagers : []pressure_plate_with_generator = array{}
        var ClosestDistance : float = -1.0
        CurrentLocation := GetTransform().Translation
        TaggedNodeGenerator := FindCreativeObjectsWithTag(tycoon_node{})
        for(PotentialNode : TaggedNodeGenerator):
            if(Manager := pressure_plate_with_generator[PotentialNode]):
                ManagerLocation := Manager.GetTransform().Translation
                ForwardDistance := ManagerLocation.Y - CurrentLocation.Y
                if(ForwardDistance > 1.0):
                    CandidateDistance := Distance(CurrentLocation,ManagerLocation)
                    if((ClosestDistance < 0.0) or (CandidateDistance < ClosestDistance)):
                        set ClosestDistance = CandidateDistance
                        set NextManagers = array{Manager}
        return NextManagers

    GetNextManagers()<transacts>:[]pressure_plate_with_generator=
        if(CommonlyUsed.NextManagers.Length > 0):
            return CommonlyUsed.NextManagers
        return GetAutomaticNextManagers()

    ShowAndHide()<suspends>:void=
        HideStuff()
        ShowStuff()

    HideStuff():void=
        TryPrint("Hiding old")
        for(Index -> Prop : CommonlyUsed.PropsToHide):
            Prop.Animatedown(Index + HideStartIndex)
        #for(Manipulator : PropManipulatorsToHideOnPress):
        #    Manipulator.HideProps()

    ShowStuff()<suspends>:void=
        TryPrint("Showing new")
        for(Index -> Prop : CommonlyUsed.PropsToShow):
            Prop.AnimateUp(Index + ShowStartIndex)
            Sleep(AnimationCurves.AnimationDelay)
        #for(Manipulator : PropManipulatorsToShowOnPress):
        #    Manipulator.ShowProps()
        
    DefaultHidden():void=
        TryPrint("Hiding default hidden")
        for(Index -> Prop : CommonlyUsed.PropsToShow):
            Prop.Animatedown(Index + ShowStartIndex)
        #for(Manipulator : PropManipulatorsToShowOnPress):
        #    Manipulator.HideProps()

    DefaultShown():void=
        TryPrint("Showing default shown")
        for(Index -> Prop : CommonlyUsed.PropsToHide):
            Prop.AnimateUp(Index + HideStartIndex)
        #for(Manipulator : PropManipulatorsToHideOnPress):
        #    Manipulator.ShowProps()

    (Prop : creative_prop).AnimateUpProp(Index : int)<suspends>:void=
        if(T := Mod[PlateIndex,10]):
            Sleep(0.02 * T)
        else{Sleep(0.09)}
        TryPrint("Animating prop {Index} of plate {PlateIndex} up",?Duration:=10.0)
        Cur := Prop.GetTransform().Translation
        #ZCord := Prop.GetTransform().Translation.Z
        var Curve : cubic_bezier_parameters = AnimationCurves.ShowAnimationCurve.Curve()
        var AnimationTime : float = AssetsAndAnimation.ShowAnimationTime
        if(Index = PressurePlateIndex):
            set Curve = AnimationCurves.PlateShowAnimationCurve.Curve()
            set AnimationTime = AssetsAndAnimation.PlateShowAnimationTime
        if(Controller := Prop.GetAnimationController[]):
            if(BasePos := PropPosMap[Index]):
                Time := AssetsAndAnimation.HideAnimationTime
                #Prop.MoveTo(vector3{X:=Cur.X,Y:=Cur.Y,Z:=HideZLevel},Prop.GetTransform().Rotation,Time)
                if(MoveDirectionMap[Index] = current_move_direction.up){return}
                else:
                    if(set MoveDirectionMap[Index] = current_move_direction.up){}
                    else{Print("Failed to set prop starting direction",?Duration:=90.0)}
                    TargetLoc := BasePos
                    DeltLoc := TargetLoc - Cur
                    Frame := keyframe_delta{DeltaLocation:=DeltLoc,DeltaRotation:=rotation{},Time:=AnimationTime,Interpolation:=Curve}
                    Controller.SetAnimation(Frames:=array{Frame}, ?Mode:=animation_mode.OneShot)
                    Controller.Play()
                    Controller.MovementCompleteEvent.Await()
                    if(MoveDirectionMap[Index] = current_move_direction.up):
                        if(set MoveDirectionMap[Index] = current_move_direction.none){}
                        else{Print("Failed to set direction back to none",?Duration:=90.0)}
                    for(Player : OwningPlayers):
                        Sound.SlamSound.Play(Player)
            else{TryPrint("Failed to get prop position index {Index}",?Duration:=90.0)}
        else:
            TryPrint("FAILED TO Get Animation controller",?Duration:=30.0)

    (Prop : creative_prop).AnimateDownProp(Index : int)<suspends>:void=
        if(T := Mod[PlateIndex,10]):
            Sleep(0.02 * T)
        else{Sleep(0.09)}
        TryPrint("Animating prop {Index} of plate {PlateIndex} down",?Duration:=10.0)
        Cur := Prop.GetTransform().Translation
        #ZCord := Prop.GetTransform().Translation.Z
        var Curve : cubic_bezier_parameters = AnimationCurves.HideAnimationCurve.Curve()
        var AnimationTime : float = AssetsAndAnimation.HideAnimationTime
        if(Index = PressurePlateIndex):
            set Curve = AnimationCurves.PlateHideAnimationCurve.Curve()
        if(Controller := Prop.GetAnimationController[]):
            if(BasePos := PropPosMap[Index]):
                Time := AssetsAndAnimation.HideAnimationTime
                #Prop.MoveTo(vector3{X:=Cur.X,Y:=Cur.Y,Z:=HideZLevel},Prop.GetTransform().Rotation,Time)
                if(MoveDirectionMap[Index] = current_move_direction.down){return}
                else:
                    if(set MoveDirectionMap[Index] = current_move_direction.down){}
                    else{Print("Failed to set prop starting direction",?Duration:=90.0)}
                    TargetLoc := vector3{X:=BasePos.X,Y:=BasePos.Y,Z:=AssetsAndAnimation.HideZLevel}
                    DeltLoc := TargetLoc - Cur
                    Frame := keyframe_delta{DeltaLocation:=DeltLoc,DeltaRotation:=rotation{},Time:=AnimationTime,Interpolation:=Curve}
                    Controller.SetAnimation(Frames:=array{Frame}, ?Mode:=animation_mode.OneShot)
                    Controller.Play()
                    Controller.MovementCompleteEvent.Await()
                    if(MoveDirectionMap[Index] = current_move_direction.down):
                        if(set MoveDirectionMap[Index] = current_move_direction.none){}
                        else{Print("Failed to set direction back to none",?Duration:=90.0)}
            else{TryPrint("Failed to get prop position index {Index}",?Duration:=90.0)}
        else:
            TryPrint("FAILED TO Get Animation controller",?Duration:=30.0)

    (Prop : creative_prop).Animatedown(Index : int):void=
        spawn{Prop.AnimateDownProp(Index)}

    (Prop : creative_prop).AnimateUp(Index : int):void=
        spawn{Prop.AnimateUpProp(Index)}

    AttemptPurchaseAudio()<suspends>:void=
        if(AllowPurchaseSound?):
            TryPrint("Attempting to play purchase sound",?Duration:=10.0)
            set AllowPurchaseSound = false
            for(Player : OwningPlayers):
                PurchaseAudio.Play(Player)
                for(SoundToPlay : Sound.AdditionalPurchaseSounds):
                    SoundToPlay.Play(Player)
            Sleep(5.0)
            set AllowPurchaseSound = true
        else{TryPrint("Purchase sound already should be playing",?Duration:=10.0)}

    FacePlayer()<suspends>:void=
        Sleep(5.0)
        Axis := vector3{Z:=1.0}
        loop:
            Sleep(0.0)
            if(Activity = activity_type_classic.active):
                for(Player : OwningPlayers):
                    if(FortChar := Player.GetFortCharacter[]):
                        for(Bill : CommonlyUsed.PriceBillboards):
                            if(Controller := CommonlyUsed.PressurePlate.GetAnimationController[]):
                                if(MoveDirectionMap[PressurePlateIndex] = current_move_direction.none):
                                    if(Distance(FortChar.GetTransform().Translation, PressurePlateLoc) > DistanceToPress):
                                        PlateLoc := CommonlyUsed.PressurePlate.GetTransform().Translation
                                        PlayerLoc := FortChar.GetTransform().Translation
                                        PlateForward := Bill.GetTransform().Rotation.GetLocalRight()
                                        VectorToPlayer := PlayerLoc - PlateLoc
                                        var DeltaRot : rotation = MakeShortestRotationBetween(PlateForward,VectorToPlayer)
                                        Deg := DeltaRot.GetYawPitchRollDegrees()
                                        var Time : float = 1.0
                                        if(Yaw := Deg[0]):
                                            set DeltaRot = MakeRotationFromYawPitchRollDegrees(Yaw,0.0,0.0)
                                            set Time = 5.0/(Yaw)
                                            if(Time < 0.0):
                                                set Time = -Time
                                        Controller.SetAnimation(array{keyframe_delta{DeltaLocation:=vector3{},DeltaRotation:=DeltaRot,Time:=Time,Interpolation:=InterpolationTypes.Linear}},?Mode:=animation_mode.OneShot)
                                        Controller.Play()
                                            
                                else:
                                    Print("Not rotating because prop is already in motion.")
                                    Sleep(0.5)
                            else{Print("failed to get animation controller to rotate billboard on {InfoString()}");Sleep(1.0)}
                    else{Sleep(1.0)}
            else:
                Sleep(1.5)

                            




    
        
    

    

            

        
        

    
        
        
                


        

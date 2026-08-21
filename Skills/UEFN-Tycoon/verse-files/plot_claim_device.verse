
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/Devices/CreativeAnimation }
# See https://dev.epicgames.com/documentation/en-us/uefn/create-your-own-device-in-verse for how to create a verse device.

var AllowPrint : weak_map(session,logic) = map{}

var AllowChecklist : weak_map(session,logic) = map{}

TryPrint(String : string, ?Duration : float = 4.0):void=
    if(AllowPrint[GetSession()]?):
        Print(String,?Duration:=Duration)

ChecklistPrint(String : string, ?Duration : float = 4.0):void=
    if(AllowChecklist[GetSession()]?):
        Print(String,?Duration:=Duration)

first_pressure_plate_assignment := class<concrete>:
    var Value : int = -1

    @editable
    ClaimProp : creative_prop = creative_prop{}

    @editable
    HideProp : creative_prop = creative_prop{}

    @editable
    ShowProp : creative_prop = creative_prop{}

    @editable
    TimeToSwap : float = 1.0

    @editable
    FirstPressurePlateDeviceOnly : []pressure_plate_with_generator = array{}

    @editable
    OptionalTeleportLocationOverride : []transform = array{}

    SwapOnClaim():void=
        Loc1 := ShowProp.GetTransform()
        Loc2 := HideProp.GetTransform()
        spawn{ShowProp.MoveTo(Loc2,TimeToSwap)}
        spawn{HideProp.MoveTo(Loc1,TimeToSwap)}

    SwapOnUnclaim():void=
        Loc1 := HideProp.GetTransform()
        Loc2 := ShowProp.GetTransform()
        spawn{HideProp.MoveTo(Loc2,TimeToSwap)}
        spawn{ShowProp.MoveTo(Loc1,TimeToSwap)}

    Unclaim()<suspends>:void=
        TryPrint("Actually unclaiming", ?Duration:=50.0)
        for(Plate : FirstPressurePlateDeviceOnly):
            Plate.ResetEverythingForAll()
        SwapOnUnclaim()
        

unclaim_helper := class:
    PCD : plot_claim_device
    PlotInfo : first_pressure_plate_assignment
    Play : player

    OnRemoved(Player : player):void=
        if(Player = Play):
            TryPrint("unclaim should trigger", ?Duration:=50.0)
            spawn{DoubleCheckRemoval(Player)}
        else:
            TryPrint("Players dont match to unclaim", ?Duration:=50.0)

    DoubleCheckRemoval(Player : player)<suspends>:void=
        Sleep(15.0)
        for(ActivePlayer : PCD.GetPlayspace().GetPlayers()):
            if(ActivePlayer = Player):
                TryPrint("Player still in game", ?Duration:=50.0)
                return
        TryPrint("Player actually removed from game", ?Duration:=50.0)
        PCD.UnclaimPlot(PlotInfo)


    

# A Verse-authored creative device that can be placed in a level
plot_claim_device := class(creative_device):

    @editable
    ClaimToPlotAssignments : []first_pressure_plate_assignment = array{}

    @editable
    DistToClaim : float = 200.0

    @editable
    PlotGroundHeight : float = 0.0

    @editable
    OptionalPortalMutatorZone : []mutator_zone_device = array{}

    @editable
    SpawnReturnLocation : vector3 = vector3{X:=0.0,Y:=0.0,Z:=0.0}

    @editable
    SpawnReturnRotation : rotation = rotation{}

    @editable
    TogglePrintingButton : button_device = button_device{}

    @editable
    ToggleCheckListButton : button_device = button_device{}

    var UnclaimedPlots : []first_pressure_plate_assignment = array{}

    var ClaimedPlots : []first_pressure_plate_assignment = array{}

    var UnassignedPlayers : []player = array{}

    var AssignedPlayers : []player = array{}

    ReturnPlayerToPlot(Agent : agent):void=
        for(Plot : ClaimedPlots):
            for(Plate : Plot.FirstPressurePlateDeviceOnly):
                for(Player : Plate.OwningPlayers):
                    if(Player = player[Agent]):
                        TeleportToPlot(Player,Plate,Plot)
                        return
        if(Char := Agent.GetFortCharacter[]):
            if(Char.TeleportTo[SpawnReturnLocation,SpawnReturnRotation]){}
        

    TogglePrinting(Agent : agent):void=
        if(Allowed := AllowPrint[GetSession()]):
            if(Allowed?):
                if(set AllowPrint[GetSession()] = false):
                    Print("Prints disabled")
            else:
                if(set AllowPrint[GetSession()] = true):
                    Print("Prints enabled")

    ToggleChecklist(Agent : agent):void=
        if(Allowed := AllowChecklist[GetSession()]):
            if(Allowed?):
                if(set AllowChecklist[GetSession()] = false):
                    Print("Checklist disabled")
            else:
                if(set AllowChecklist[GetSession()] = true):
                    Print("Checklist enabled")
    
    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        if(set AllowPrint[GetSession()] = false):
            Print("Most Printing Disabled")
        else:
            Print("Failed to disable printing")
        if(set AllowChecklist[GetSession()] = true):
            Print("Checklist Enabled")
        else:
            Print("Failed to disable checklist")
        #GetPlayspace().PlayerRemovedEvent().Subscribe(OnPlayerRemoved)
        GetPlayspace().PlayerAddedEvent().Subscribe(AddPlayer)
        for(Player : GetPlayspace().GetPlayers()):
            AddPlayer(Player)
        for(Zone : OptionalPortalMutatorZone):
            Zone.AgentEntersEvent.Subscribe(ReturnPlayerToPlot)
        TogglePrintingButton.InteractedWithEvent.Subscribe(TogglePrinting)
        ToggleCheckListButton.InteractedWithEvent.Subscribe(ToggleChecklist)
        for(Plate : ClaimToPlotAssignments):
            set UnclaimedPlots += array{Plate}
        var Num : int = 0
        for(Plate : UnclaimedPlots):
            set Num += 1
            set Plate.Value = Num
        spawn{CheckPlotClaim()}

    AddPlayer(Player:player):void=
        for(AssignedPlayer : AssignedPlayers):
            if(Player = AssignedPlayer):
                return
        for(UnassignedPlayer : UnassignedPlayers):
            if(Player = UnassignedPlayer):
                return
        set UnassignedPlayers += array{Player}
        TryPrint("Player added to game. There are {UnassignedPlayers.Length} players that have not claimed a plot.")

    CheckPlotClaim()<suspends>:void=
        loop:
            Sleep(0.2)
            for(PlayerIndex -> Player : UnassignedPlayers):
                if(Char := Player.GetFortCharacter[]):
                    for(PlateIndex -> PlateInfo : UnclaimedPlots):
                        if(Distance(Char.GetTransform().Translation,PlateInfo.ClaimProp.GetTransform().Translation) < DistToClaim):
                            if(FirstPlate := PlateInfo.FirstPressurePlateDeviceOnly[0]):
                                set ClaimedPlots += array{PlateInfo}
                                #PlateInfo.ClaimProp.Hide()
                                if(RemovedPlate := UnclaimedPlots.RemoveElement[PlateIndex]):
                                    set UnclaimedPlots = RemovedPlate
                                set AssignedPlayers += array{Player}
                                if(RemovedPlayer := UnassignedPlayers.RemoveElement[PlayerIndex]):
                                    set UnassignedPlayers = RemovedPlayer
                                OnClaim(Player,FirstPlate,PlateInfo)
                                Helper := unclaim_helper{PCD := Self, PlotInfo := PlateInfo, Play := Player}
                                GetPlayspace().PlayerRemovedEvent().Subscribe(Helper.OnRemoved)
                                CheckPlotClaim()

    <# this might also work
    OnPlayerRemoved(RemovedPlayer : player):void=
        TryPrint("Player removed from game.")
        for(Plot : ClaimedPlots):
            for(PlateManager : Plot.FirstPressurePlateDeviceOnly):
                for(OwningPlayer : PlateManager.OwningPlayers):
                    if(OwningPlayer = RemovedPlayer):
                        UnclaimPlot(Plot)
                    else:
                        TryPrint("Player does not own this plot", ?Duration:=50.0)  #>

    UnclaimPlot(PlotInfo : first_pressure_plate_assignment):void=
        TryPrint("Unclaiming plot triggered", ?Duration:=50.0)
        spawn{PlotInfo.Unclaim()}
        var TempClaimed : []first_pressure_plate_assignment = array{}
        for(Plot : ClaimedPlots):
            if(not Plot.Value = PlotInfo.Value):
                set TempClaimed += array{Plot}
        set ClaimedPlots = TempClaimed
        set UnclaimedPlots += array{PlotInfo}


                            

        

    OnClaim(Agent:agent, Plate : pressure_plate_with_generator, PlateInfo : first_pressure_plate_assignment)<suspends>:void=
        if(Player := player[Agent]):
            Plate.AddPlayerToPlot(Player)
            Sleep(0.15)
            TeleportToPlot(Player,Plate,PlateInfo)
            PlateInfo.SwapOnClaim()

    TeleportToPlot(Player:player, Plate : pressure_plate_with_generator, PlateInfo : first_pressure_plate_assignment):void=
        var TeleportLoc : transform = transform{}
        if(Loc := PlateInfo.OptionalTeleportLocationOverride[0]):
            set TeleportLoc = Loc
        else:
            set TeleportLoc = Plate.CommonlyUsed.PressurePlate.GetTransform()
            set TeleportLoc.Translation.Z += 100.0
            if(TeleportLoc.Translation.Z < PlotGroundHeight):
                set TeleportLoc.Translation.Z = PlotGroundHeight
        if(FortChar := Player.GetFortCharacter[]):
            if(FortChar.TeleportTo[TeleportLoc.Translation,TeleportLoc.Rotation]):
                TryPrint("Teleporting player to plot.")
            else:
                TryPrint("TELEPORT FAILED")

    



    
    
        
            
            



        

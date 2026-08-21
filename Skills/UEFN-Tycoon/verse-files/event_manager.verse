
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/Characters }
using { /Verse.org/Random }
using { /Verse.org/Verse }

# See https://dev.epicgames.com/documentation/en-us/uefn/create-your-own-device-in-verse for how to create a verse device.

player_info := class:
    Player : player
    CurrencyManager : tycoon_currency_manager
    ReturnLocation : vector3
    ReturnRotation : rotation

game := class(creative_device):

    @editable
    EventName : string = "Base Event. This should not be used directly."

    var OnlyEventManager : []event_manager = array{}

    @editable
    var GameTeleportLocation : vector3 = vector3{X:=0.0,Y:=0.0,Z:=80000.0}

    @editable
    var GameTeleportRotation : rotation = rotation{}

    var Participants : []player = array{}

    var RemainingPlayers : []player = array{}

    TeleportSpot()<transacts>:tuple(vector3,rotation)=
        return (GameTeleportLocation, GameTeleportRotation)

    StartGame()<suspends>:void=
        Print("Failed to start event!")

    EndGame()<suspends>:void=
        for(Manager : OnlyEventManager):
            Manager.AwardParticipation(Participants)
        set RemainingPlayers = array{}
        set Participants = array{}
        Print("Event successfully ended.")
        if(Manager := OnlyEventManager[0]):
            Manager.AllowNextGame()
        else:
            Print("Failed to find event manager. Something is broken.")

    EndGameWin(Player : player)<suspends>:void=
        if(OnlyEventManager.Length > 0):
            Print("There is more than one event manager. something is broken.")
        for(Manager : OnlyEventManager):
            Manager.AwardWin(Player,Participants)
        set RemainingPlayers = array{}
        set Participants = array{}
        if(Manager := OnlyEventManager[0]):
            Manager.AllowNextGame()
        else:
            Print("Failed to find event manager. Something is broken.")

    AddPlayerToGame(Player : player):void=
        for(Participant : Participants):
            if(Participant = Player):
                return
        set Participants += array{Player}
        Print("Player added to game.")
        AdditionalAddBehavior(Player)
        #set RemainingPlayers += array{Player}

    AdditionalAddBehavior(Player : player):void=
        Print("No additional behavior for adding player to {EventName}.")

    GetPlayerManager(Player : player)<decides><transacts>:tycoon_currency_manager=
        Print("Attempting to get player manager.")
        EventManager := OnlyEventManager[0]
        Print("Got player manager")
        PlayerInfo := EventManager.PlayerInfoMap[Player]
        Print("Got player info.")
        return PlayerInfo.CurrencyManager

    #GetPlayerManager(Agent : agent)<decides>:tycoon_currency_manager=
    #    Player := player[Agent]
    #    return GetPlayerManager(Player)
        
    

# A Verse-authored creative device that can be placed in a level
event_manager := class(creative_device):

    var PlayerInfoMap : [player]player_info = map{}

    @editable
    OnlyPlotClaimDevice : []plot_claim_device = array{}

    @editable
    PortalMutatorZones : []mutator_zone_device = array{}

    @editable
    HudMessager : hud_message_device = hud_message_device{}

    #@editable
    #ColorSwitch : color_switch = color_switch{}

    @editable
    AllEvents : []game = array{}

    @editable
    AwardMultiple : float = 4.0

    @editable
    ParticipationAward : float = 60.0

    @editable
    WinnerMessage : string = "You Won!"

    @editable
    WinMessageDisplayTime : float = 5.0

    @editable
    ParticipationMessage : string = "Thanks for Playing!"

    @editable
    ParticipationMessageDisplayTime : float = 7.5

    @editable
    TimeBeforeFirstEvent : int = 60

    @editable
    TimeBetweenEvents : int = 60 * 8

    @editable
    TimeToShowStartingMessage : int = 30

    @editable
    HudMessageDevice : hud_message_device = hud_message_device{}

    @editable
    AboutToStartMessage : string = "is about to start!\n\nGet to the Portal!"

    @editable
    MaxEventTimeBeforeForceEnd : int = 60 * 10

    #@editable
    #KingOfTheHill : king_of_the_hill = king_of_the_hill{}

    var CurrentEvent : game = game{}

    var EventsThisSession : int = 0

    var TimeBeforeEvent : int = 0

    S2M<localizes>(S:string):message="{S}"

    GameEndedEvent : event() = event(){}

    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        for(Zone : PortalMutatorZones):
            Zone.AgentEntersEvent.Subscribe(OnEnteredPortal)
        for(Game : AllEvents):
            set Game.OnlyEventManager = array{Self}
        spawn{ActivateEvents()}

    ActivateEvents()<suspends>:void=
        Sleep(10.0)
        StartGameLoop()

    AllowNextGame()<suspends>:void=
        Print("Next Game Should Start.")
        GameEndedEvent.Signal()
    
    StartGameLoop()<suspends>:void=
        loop:
            set PlayerInfoMap = map{}
            Print("Player info map reset.")
            Print("Next event starting!")
            Sleep(1.0)
            race:
                loop:
                    RandomIndex := GetRandomInt(0,AllEvents.Length-1)
                    ###First event only###
                    if(ThisGame := AllEvents[RandomIndex];EventsThisSession < 1):
                        set TimeBeforeEvent = TimeBeforeFirstEvent
                        for(x := 1..(TimeBeforeFirstEvent-TimeToShowStartingMessage)):
                            Print("Time before first event: {TimeBeforeEvent}")
                            Sleep(1.0)
                            set TimeBeforeEvent -= 1
                        set CurrentEvent = ThisGame
                        for(x := 1..TimeToShowStartingMessage):
                            Print("Time before first event: {TimeBeforeEvent}")
                            set TimeBeforeEvent -= 1
                            for(Player : GetPlayspace().GetPlayers()):
                                HudMessageDevice.Show(Player,S2M("{ThisGame.EventName} {AboutToStartMessage}\n{TimeToShowStartingMessage - x}"))
                                Sleep(1.0)
                        for(Player : GetPlayspace().GetPlayers()):
                            HudMessageDevice.Show(Player,S2M("{ThisGame.EventName} Starting!"))
                        Sleep(4.0)
                        HudMessageDevice.Hide()
                        Print("Starting {ThisGame.EventName}!")
                        ##spawn{CurrentEvent.StartGame()}
                        CurrentEvent.StartGame()
                        ##Print("Begin await")
                        ##GameEndedEvent.Await()
                        ##Print("End await")
                        set CurrentEvent = game{}
                        set EventsThisSession += 1
                        Print("Event should have just ended.")

                    ###All other events###
                    else if(ThisGame := AllEvents[RandomIndex]):
                        set TimeBeforeEvent = TimeBetweenEvents
                        for(x := 1..TimeBetweenEvents-TimeToShowStartingMessage):
                            Print("Time before event: {TimeBeforeEvent}")
                            Sleep(1.0)
                            set TimeBeforeEvent -= 1
                        set CurrentEvent = ThisGame
                        for(x := 1..TimeToShowStartingMessage):
                            Print("Time before event: {TimeBeforeEvent}")
                            set TimeBeforeEvent -= 1
                            for(Player : GetPlayspace().GetPlayers()):
                                HudMessageDevice.Show(Player,S2M("{ThisGame.EventName} {AboutToStartMessage}\n{TimeToShowStartingMessage - x}"))
                                Sleep(1.0)
                        for(Player : GetPlayspace().GetPlayers()):
                            HudMessageDevice.Show(Player,S2M("{ThisGame.EventName} Starting!"))
                        Sleep(4.0)
                        HudMessageDevice.Hide()
                        Print("Starting {ThisGame.EventName}!")
                        ##spawn{CurrentEvent.StartGame()}
                        CurrentEvent.StartGame()
                        ##Print("Begin await")
                        ##GameEndedEvent.Await()
                        ##Print("End await")
                        set CurrentEvent = game{}
                        set EventsThisSession += 1
                        Print("Event should have just ended.")
                    else:
                        Sleep(5.0)
                        Print("There are no games. Idk why.")
                    break
                loop:
                    Sleep(MaxEventTimeBeforeForceEnd * 1.0)
                    CurrentEvent.EndGame()
                    Print("Event ended by force.")
                    break

    #PrintIgnoreRollback(S:string)<computes>:void=
    #    Print(S)


    OnEnteredPortal(Agent : agent):void=
        #var CurrMan : tycoon_currency_manager = tycoon_currency_manager{}
        if(Player := player[Agent]):
            for(PlotClaimDevice : OnlyPlotClaimDevice):
                for(PlotInfo : PlotClaimDevice.ClaimedPlots):
                    for(Plate : PlotInfo.FirstPressurePlateDeviceOnly):
                        for(OwningPlayer : Plate.OwningPlayers):
                            if(OwningPlayer = Player):
                                if(Char := Player.GetFortCharacter[]):
                                    PlayerTransform := Char.GetTransform()
                                    ReturnRot := PlayerTransform.Rotation.ApplyYaw(180.0)
                                    Man := Plate.MainTycoonManager
                                    PlayerInfo := player_info{Player := Player, CurrencyManager := Man, ReturnLocation := PlayerTransform.Translation, ReturnRotation := ReturnRot}
                                    if(CurrentEvent.TeleportSpot()(0).Z > 50000.0 or TimeBeforeEvent > TimeToShowStartingMessage):
                                        Print("There is not an event happening now.")
                                        if(Char.TeleportTo[PlotClaimDevice.SpawnReturnLocation,PlotClaimDevice.SpawnReturnRotation]):
                                            Print("Teleported player to spawn return location.")
                                            return
                                        else:
                                            Print("Failed to teleport player to spawn return location.")
                                        return
                                    else if:
                                        not PlayerInfoMap[Player]
                                        set PlayerInfoMap[Player] = PlayerInfo
                                    then:
                                        if(Char.TeleportTo[CurrentEvent.TeleportSpot()]):
                                            CurrentEvent.AddPlayerToGame(Player)
                                            Print("Teleported player to event!")
                                            return
                                        else:
                                            Print("Failed to teleport player to event!")
                                    else:
                                        Print("PLAYER ALREADY HAD DATA BEFORE ENTERING PORTAL!",?Duration := 30.0)

    AwardWin(Winner : player,Players : []player)<suspends>:void=
        if(PlayerInfo := PlayerInfoMap[Winner]):
            if(AwardAmount := Round[PlayerInfo.CurrencyManager.GoldPerSecond * ParticipationAward * AwardMultiple]):
                spawn{PlayerInfo.CurrencyManager.GrantGold(Winner,AwardAmount)}
        HudMessager.Show(Winner,S2M("You Won!"),?DisplayTime := WinMessageDisplayTime)
        AwardParticipation(Players)

    AwardParticipation(Players : []player)<suspends>:void=
        Print("Awarding {Players.Length} participants!")
        for(Player : Players):
            if(PlayerInfo := PlayerInfoMap[Player]):
                if(AwardAmount := Round[PlayerInfo.CurrencyManager.GoldPerSecond * ParticipationAward]):
                    spawn{PlayerInfo.CurrencyManager.GrantGold(Player,AwardAmount)}
                if(Char := Player.GetFortCharacter[];Char.TeleportTo[PlayerInfo.ReturnLocation,PlayerInfo.ReturnRotation]):
                    TryPrint("Teleported player back to plot!")
                else:
                    Print("Failed to teleport player back to plot!")
            else:
                Print("Failed to find player info!")
            HudMessager.Show(Player,S2M("Thanks for Playing!"), ?DisplayTime := ParticipationMessageDisplayTime)
        set PlayerInfoMap = map{}
        Print("Player info map reset.")









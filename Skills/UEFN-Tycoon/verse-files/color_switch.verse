
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Verse.org/Random }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/Characters }

# See https://dev.epicgames.com/documentation/en-us/uefn/create-your-own-device-in-verse for how to create a verse device.

color_info := class<concrete>:
    @editable
    ColorName : string = "Green"

    @editable
    AllTilesOfThisColor : []creative_prop = array{}

    @editable
    RepresentativeImages : []creative_prop = array{}

# A Verse-authored creative device that can be placed in a level
color_switch := class(game):

    @editable
    EventName<override> : string = "Color Switch"

    @editable
    var GameTeleportLocation<override> : vector3 = vector3{}

    @editable
    EndGameWhenThisManyPlayersRemain : int = 1

    @editable
    PlayAreaMutatorZone : mutator_zone_device = mutator_zone_device{}

    @editable
    GameStartingMessage : string = "Game Starting in"

    @editable
    MessageDuringRound : string = "Find a matching tile"

    @editable
    ColorBillboardPregameText : string = "Get Ready"

    @editable
    ColorBillboards : []billboard_device = array{}

    @editable
    MessageBillboards : []billboard_device = array{}

    @editable
    TimeBillboards : []billboard_device = array{}

    @editable
    CountdownToStartGame : float = 30.0

    @editable
    StartingPrepTime : float = 15.0

    @editable
    TimeDecreasePerRound : float = 1.0

    @editable
    TimeBetweenRounds : float = 5.0

    @editable
    StartingRandomizeTime : float = 1.0

    @editable
    RandomizeTimeIncreasePerRound : float = 0.2

    @editable
    RandomizeRate : int = 2

    @editable
    AllColors : []color_info = array{}

    @editable
    TriggerDevices : []trigger_device = array{}


    var StartingCountdownActvated : logic = false

    var GameActive : logic = false

    S2M<localizes>(S:string):message="{S}"

    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        #for(Trigger : TriggerDevices):
        #    Trigger.TriggeredEvent.Subscribe(OnTriggered)
        PlayAreaMutatorZone.AgentEntersEvent.Subscribe(RemovePlayer)

    RemovePlayer(Agent : agent):void=
        var Temp : []player = array{}
        var PlayerWasAParticipant : int = 0
        if(Player := player[Agent]):
            for(Remaining : RemainingPlayers):
                if(not Remaining = Player):
                    set Temp += array{Remaining}
                else:
                    set PlayerWasAParticipant += 1
        if(PlayerWasAParticipant = 0):
            Print("Player not found in event. Game likely has not started yet.")
            if(FortChar := Agent.GetFortCharacter[]):
                if(FortChar.TeleportTo[GameTeleportLocation,GameTeleportRotation]):
                else:
                    Print("Player failed to teleport to game start location")
            else:
                Print("Player did not have a FortCharacter")
        else:
            set RemainingPlayers = Temp
            Print("Player removed from game")

    Format(Num : float):message=
        if(Num < 0.09):
            return S2M("0.0")
        if(Num > 10.0):
            if(Rounded := Round[Num]):
                return S2M("{Rounded}")
            else{return S2M("{Num}")}
        else:
            Adjusted := Num * 10.0
            if(Rounded := Round[Adjusted]):
                if(Tens : int = Floor(Rounded / 10);Ones := Mod[Rounded,10]):
                    if(Tens < 0):
                        return S2M("0.0")
                    return S2M("{Tens}.{Ones}")
        return S2M("{Num}")

    StartGame<override>()<suspends>:void=
        if(GameActive?):
            Print("Game already active")
            return
        Print("{EventName} Successfully Started")
        set StartingCountdownActvated = true
        var PrepTime : float = StartingPrepTime
        var RandomizeTime : float = StartingRandomizeTime
        set GameActive = true
        var CountDown : float = CountdownToStartGame
        for(MsgBillboard : MessageBillboards):
            MsgBillboard.SetText(S2M(GameStartingMessage))
        for(Billboard : ColorBillboards):
            Billboard.SetText(S2M(ColorBillboardPregameText))
        loop:
            if(CountDown > 0.0):
                for(TimeBoard : TimeBillboards):
                    TimeBoard.SetText(Format(CountDown))
                Sleep(0.1)
                set CountDown -= 0.1
            else:
                break
        for(Player : Participants):
            set RemainingPlayers += array{Player}
        loop:
            var Index : int = 0
            ShuffledColors := Shuffle(AllColors)
            set CountDown = PrepTime
            for(MsgBillboard : MessageBillboards):
                MsgBillboard.SetText(S2M(MessageDuringRound))
            for(TimeBoard : TimeBillboards):
                TimeBoard.SetText(Format(CountDown))
            var SelectedColor : color_info = RandomColor()
            if(Color := AllColors[Index]):
                set SelectedColor = SetColor(Color)
                set Index += 1
            loop:
                if(PrepTime - CountDown < RandomizeTime):
                    if(Mod[Round[CountDown * 10],RandomizeRate] = 0):
                        if(Color := AllColors[Index]):
                            set SelectedColor = SetColor(Color)
                            set Index += 1
                        else:
                            set Index = 0
                            if(Color := AllColors[Index]):
                                set SelectedColor = SetColor(Color)
                                set Index += 1
                Sleep(0.1)
                set CountDown -= 0.1
                for(TimeBoard : TimeBillboards):
                    TimeBoard.SetText(Format(CountDown))
    
                if(CountDown <= 0.0):
                    break
                if(RemainingPlayers.Length <= EndGameWhenThisManyPlayersRemain):
                    Print("Only {RemainingPlayers.Length} players left. Ending game")
                    ResetTiles()
                    if(Player := RemainingPlayers[0]):
                        EndGameWin(Player)
                        return
                    else:
                        EndGame()
                        return
            for(Color : AllColors):
                if(not Color.ColorName = SelectedColor.ColorName):
                    for(Tile : Color.AllTilesOfThisColor):
                        Tile.Hide()
            Sleep(TimeBetweenRounds)
            for(Color : AllColors):
                if(not Color.ColorName = SelectedColor.ColorName):
                    for(Tile : Color.AllTilesOfThisColor):
                        Tile.Show()
            set PrepTime -= TimeDecreasePerRound
            set RandomizeTime += RandomizeTimeIncreasePerRound
            if(GameActive = false):
                Print("Game no longer active.")
                return

    ResetTiles():void=
        for(Color : AllColors):
            for(Tile : Color.AllTilesOfThisColor):
                Tile.Show()
        RandomColor()

    EndGame<override>()<suspends>:void=
        set GameActive = false
        set StartingCountdownActvated = false
        (super:)EndGame()
        Print("Game Over")

    EndGameWin<override>(Player : player)<suspends>:void=
        Print("Winner")
        set GameActive = false
        set StartingCountdownActvated = false
        (super:)EndGameWin(Player)
        Print("Game Over")
            


    RandomColor():color_info=
        RandomIndex := GetRandomInt(0,AllColors.Length-1)
            if(Color := AllColors[RandomIndex]):
                for(Image : Color.RepresentativeImages):
                    Image.Show()
                for(OtherColor : AllColors):
                    if(not OtherColor.ColorName = Color.ColorName):
                        for(Image : OtherColor.RepresentativeImages):
                            Image.Hide()
                for(Billboard : ColorBillboards):
                    Billboard.SetText(S2M(Color.ColorName))
                return Color
        Print("No color found")
        return color_info{}

    SetColor(Color : color_info):color_info=
        for(Billboard : ColorBillboards):
            Billboard.SetText(S2M(Color.ColorName))
        for(OtherColor : AllColors):
            if(not OtherColor.ColorName = Color.ColorName):
                for(Image : OtherColor.RepresentativeImages):
                    Image.Hide()
            else:
                for(Image : Color.RepresentativeImages):
                    Image.Show()
        return Color

    #StartGameOnce():void=
    #    if(not StartingCountdownActvated?):
    #        set StartingCountdownActvated = true
    #        spawn{StartGame()}

    #OnTriggered(MaybeAgent : ?agent):void=
    #    if(Agent := agent[MaybeAgent?]):
    #        if(Player := player[Agent]):
    #            for(Participant : Participants):
    #                if(Participant = Player):
    #                    return
    #            set Participants += array{Player}
    #            StartGameOnce()
    #    else:
    #        Print("Trigger did not have an agent")

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/Characters }
using { /Fortnite.com/FortPlayerUtilities }
using { /Fortnite.com/Game }
# See https://dev.epicgames.com/documentation/en-us/uefn/create-your-own-device-in-verse for how to create a verse device.

# A Verse-authored creative device that can be placed in a level
king_of_the_hill := class(game):

    @editable
    EventName<override> : string = "King of the Hill"
    
    @editable
    CaptureArea : capture_area_device = capture_area_device{}

    @editable
    EventTimeMins : float = 2.0

    @editable
    EarningsAmountDuringGame : float = 1.0

    @editable
    SpawnLocationProps : []creative_prop = array{}

    @editable
    RespawnHeightAddition : float = 250.0

    var Index : int = 0

    var LastToCapture : []player = array{}

    var ThingsToCancel : []cancelable = array{}

    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        Print("KOTH device active")
        CaptureArea.AreaIsScoredEvent.Subscribe(GrantDuringGame)
        if(Prop := SpawnLocationProps[Index]):
            set GameTeleportLocation = Prop.GetTransform().Translation + vector3{Z:=RespawnHeightAddition}
            set GameTeleportRotation = Prop.GetTransform().Rotation
            set Index += 1
        set ThingsToCancel += array{GetPlayspace().PlayerAddedEvent().Subscribe(CheckPlayerSpawn)}

    AdditionalAddBehavior<override>(Player : player):void=
        if(Char := Player.GetFortCharacter[]):
            set ThingsToCancel += array{Char.EliminatedEvent().Subscribe(RespawnPlayerSoon)}

    CheckPlayerSpawn(Player : player):void=
        for(ParticipatingPlayer : Participants):
            if(Player = ParticipatingPlayer):
                if(Char := Player.GetFortCharacter[]):
                    if(Prop := SpawnLocationProps[Index]):
                        if(Char.TeleportTo[Prop.GetTransform().Translation + vector3{Z:=RespawnHeightAddition},Prop.GetTransform().Rotation]):
                            set Index += 1
                            set GameTeleportLocation = Prop.GetTransform().Translation + vector3{Z:=RespawnHeightAddition}
                            set GameTeleportRotation = Prop.GetTransform().Rotation
                        else:
                            set Index = 0
                            spawn{TryAgainCheckPlayerSpawn(Player)}

    TryAgainCheckPlayerSpawn(Player : player)<suspends>:void=
        Sleep(4.0)
        for(ParticipatingPlayer : Participants):
            if(Player = ParticipatingPlayer):
                if(Char := Player.GetFortCharacter[]):
                    if(Prop := SpawnLocationProps[Index]):
                        if(Char.TeleportTo[Prop.GetTransform().Translation + vector3{Z:=RespawnHeightAddition},Prop.GetTransform().Rotation]):
                            set Index += 1
                            set GameTeleportLocation = Prop.GetTransform().Translation + vector3{Z:=RespawnHeightAddition}
                            set GameTeleportRotation = Prop.GetTransform().Rotation
                        else:
            

    RespawnPlayerSoon(Result : elimination_result):void=
        spawn{RespawnPlayer(Result)}

    RespawnPlayer(Result : elimination_result)<suspends>:void=
        Sleep(1.0)
        Char := Result.EliminatedCharacter
        if(Prop := SpawnLocationProps[Index]):
            if(Ag := Char.GetAgent[]):
                Print("Attempting Respawn.")
                Ag.Respawn(Prop.GetTransform().Translation + vector3{Z:=RespawnHeightAddition},Prop.GetTransform().Rotation)
                set Index += 1
                set GameTeleportLocation = Prop.GetTransform().Translation + vector3{Z:=RespawnHeightAddition}
                set GameTeleportRotation = Prop.GetTransform().Rotation
        else:
            set Index = 0
            RespawnPlayer(Result)

    StartGame<override>()<suspends>:void=
        CaptureArea.AllowCapture()
        EventTimer()
        Print("KOTH game started")

    EndGame<override>()<suspends>:void=
        Print("KOTH game ended")
        CaptureArea.Neutralize()
        CaptureArea.DisallowCapture()
        for(Thing : ThingsToCancel):
            Thing.Cancel()
        if(LastPlayer := LastToCapture[0]):
            EndGameWin(LastPlayer)
        else:
            (super:)EndGame()

    EventTimer()<suspends>:void=
        Sleep(EventTimeMins * 60)
        EndGame()

    GrantDuringGame(Agent : agent):void=
        Print("Attempting to grant gold for koth")
        if(Player:=player[Agent]):
            if(Manager := GetPlayerManager[Player]):
                if(AmountToGrant := Round[Manager.EffectiveGoldPerSecond() * EarningsAmountDuringGame]):
                    Print("Granting {AmountToGrant} gold for koth")
                    spawn{Manager.GrantGold(Player,AmountToGrant)}
                else:
                    Print("Failed to round gold for koth")
            else:
                Print("Failed to get player currency manager for koth")
        else:
            Print("Failed to cast player for agent")
        
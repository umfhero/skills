
using { /Verse.org/Simulation }
using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Devices/CreativeAnimation }
using { /Fortnite.com/Devices/CreativeAnimation/InterpolationTypes }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }

agent_data := class:
    var OwnedPets : []tuple(creative_prop, int) = array{}
    var ActivePetIndex : int = -1
    var bPetPlayingAnim : logic = false
    var bPetContinuousHover : logic = false

pet_purchase_data := class<concrete>:
    @editable
    ButtonForPurchase : button_device = button_device{}

    @editable
    RequiredRebirthLevel : int = 1

    @editable
    PetProps : []creative_prop = array{}
    

    var Index : int = -1
    var MaybeMainDevice : ?pets_device = false
    var AvailablePetProps : []logic = array{}

    OnPurchase(Agent : agent):void=
        if (MainDevice := MaybeMainDevice?):
            MainDevice.OnPetPurchase(Agent, Self)

pets_device := class(creative_device):

    @editable
    TycoonCurrencyManager : tycoon_currency_manager = tycoon_currency_manager{}

    @editable
    NotEnoughRebirthsHudMessage : hud_message_device = hud_message_device{}

    @editable
    PetPurchaseConfirmedHudMessage : hud_message_device = hud_message_device{}

    @editable
    PlayerSpawners : []player_spawner_device = array{}

    @editable
    PetPurchasesData : []pet_purchase_data = array{}

    var AgentMap : [agent]agent_data = map{}
    var IdleAnimationKeyFrames : []keyframe_delta = array{}
    var ContinuousHoverKeyFrames : []keyframe_delta = array{}

    # Method to get player's current rebirth level from PlayerProfileDataMap
    GetPlayerRebirthLevel(Agent : agent) : int =
        if (Player := player[Agent]):
            if (Data := PlayerProfileDataMap[Player]):
                return Data.Rebirths
        return 0

    OnBegin<override>()<suspends>:void=

        Print("OnBegin")

        for (PlayerSpawner : PlayerSpawners):
            PlayerSpawner.SpawnedEvent.Subscribe(OnPlayerSpawned)

        for (I := 0 .. PetPurchasesData.Length-1, PetPurchaseData := PetPurchasesData[I]):
            for (J := 0 .. PetPurchaseData.PetProps.Length-1, PetProp := PetPurchaseData.PetProps[J]):
                PetProp.Hide()
                set PetPurchaseData.AvailablePetProps += array{ true }

            set PetPurchaseData.MaybeMainDevice = option{ Self }
            set PetPurchaseData.Index = I

            PetPurchaseData.ButtonForPurchase.InteractedWithEvent.Subscribe(PetPurchaseData.OnPurchase)

        UpMovementKeyFrame : keyframe_delta = keyframe_delta
        {
            DeltaLocation := vector3{ X := 0.0, Y := 0.0, Z := 30.0 }
            DeltaRotation := IdentityRotation()
            DeltaScale := vector3{ X := 1.0, Y := 1.0, Z := 1.0 }
            Time := 0.85
            Interpolation := Ease
        }
        DownMovementKeyFrame : keyframe_delta = keyframe_delta
        {
            DeltaLocation := vector3{ X := 0.0, Y := 0.0, Z := -30.0 }
            DeltaRotation := IdentityRotation()
            DeltaScale := vector3{ X := 1.0, Y := 1.0, Z := 1.0 }
            Time := 0.85
            Interpolation := Ease
        }

        set IdleAnimationKeyFrames = array
        {
            UpMovementKeyFrame, DownMovementKeyFrame
        }

        # Create continuous hover animation for when following
        ContinuousUpKeyFrame : keyframe_delta = keyframe_delta
        {
            DeltaLocation := vector3{ X := 0.0, Y := 0.0, Z := 20.0 }
            DeltaRotation := IdentityRotation()
            DeltaScale := vector3{ X := 1.0, Y := 1.0, Z := 1.0 }
            Time := 1.5
            Interpolation := EaseInOut
        }
        ContinuousDownKeyFrame : keyframe_delta = keyframe_delta
        {
            DeltaLocation := vector3{ X := 0.0, Y := 0.0, Z := -20.0 }
            DeltaRotation := IdentityRotation()
            DeltaScale := vector3{ X := 1.0, Y := 1.0, Z := 1.0 }
            Time := 1.5
            Interpolation := EaseInOut
        }

        set ContinuousHoverKeyFrames = array
        {
            ContinuousUpKeyFrame, ContinuousDownKeyFrame
        }

        GetPlayspace().PlayerRemovedEvent().Subscribe(OnPlayerLeft)

        spawn{AsyncPetFollow()}

    OnPlayerSpawned(Agent : agent):void=
        if:
            not AgentMap[Agent]
            set AgentMap[Agent] = agent_data{}

    OnPlayerLeft(Player : player):void=
        if (AgentData := AgentMap[Player]):
            # Stop continuous hovering
            set AgentData.bPetContinuousHover = false
            
            for (OwnedPetTuple : AgentData.OwnedPets):
                PetProp : creative_prop = OwnedPetTuple(0)
                PetPurchaseDataIndex : int = OwnedPetTuple(1)

                PetProp.Hide()
                if (PetPurchaseData := PetPurchasesData[PetPurchaseDataIndex]):
                    var I : int = 0
                    loop:
                        if (Availability : logic = PetPurchaseData.AvailablePetProps[I]):
                            if (Availability = false):
                                if (set PetPurchaseData.AvailablePetProps[I] = true){}
                                break
                        else:
                            break

                        set I += 1

    OnPetPurchase(Agent : agent, PetPurchaseData : pet_purchase_data):void=

        var FoundPetIndex : int = -1
        if (AgentData := AgentMap[Agent]):

            for (I := 0 .. AgentData.OwnedPets.Length-1, OwnedPetTuple := AgentData.OwnedPets[I]):
                PetPurchaseIndex : int = OwnedPetTuple(1)
                if (PetPurchaseIndex = PetPurchaseData.Index):
                    set FoundPetIndex = I

        if (FoundPetIndex = -1):
            var AvailablePetPropIndex : int = -1
            for (I := 0 .. PetPurchaseData.AvailablePetProps.Length-1, AvailablePetProp := PetPurchaseData.AvailablePetProps[I]):
                if (AvailablePetProp = true):
                    Print("test1")
                    set AvailablePetPropIndex = I


            if (AvailablePetPropIndex = -1):
                Print("All Pets are Purchased!")
                return

            PlayerRebirthLevel : int = GetPlayerRebirthLevel(Agent)
            if (PlayerRebirthLevel < PetPurchaseData.RequiredRebirthLevel):
                NotEnoughRebirthsHudMessage.Show(Agent)
                Print("Not enough rebirth level! Player has {PlayerRebirthLevel}, requires {PetPurchaseData.RequiredRebirthLevel}")
                return

            # No currency deduction needed - rebirths are permanent levels, not consumable
            if (set PetPurchaseData.AvailablePetProps[AvailablePetPropIndex] = false){}

            if (PetProp : creative_prop = PetPurchaseData.PetProps[AvailablePetPropIndex],
            AgentData := AgentMap[Agent]):
                PetTuple : tuple(creative_prop, int) = (PetProp, PetPurchaseData.Index)
                set AgentData.OwnedPets += array{PetTuple}
                set FoundPetIndex = AgentData.OwnedPets.Length-1


  


        if (AgentData := AgentMap[Agent]):
            if (PetPropTuple := AgentData.OwnedPets[AgentData.ActivePetIndex]):
                PetProp := PetPropTuple(0)
                PetProp.Hide()

            set AgentData.ActivePetIndex = FoundPetIndex
            if (PetPropTuple := AgentData.OwnedPets[AgentData.ActivePetIndex]):
                PetProp := PetPropTuple(0)
                PetProp.Show()

                if (FortCharacter := Agent.GetFortCharacter[]):
                    var TeleportLoc : vector3 = FortCharacter.GetTransform().Translation
                    set TeleportLoc.X += 50.0

                    if (PetProp.TeleportTo[TeleportLoc, IdentityRotation()]){}
                    
            set AgentData.bPetPlayingAnim = false
            set AgentData.bPetContinuousHover = false
            
            # Start continuous hovering for the new pet
            spawn{StartContinuousHover(Agent)}
            
            # Show purchase confirmation message
            PetPurchaseConfirmedHudMessage.Show(Agent)

    AsyncPetFollow()<suspends>:void=
        FollowDistance : float = 200.0
        WaitDistance : float = 150.0
        SleepTime : float = 0.2

        loop:
            Sleep(SleepTime)
            for (Player : GetPlayspace().GetPlayers(), AgentData := AgentMap[Player],
            PetPropTuple := AgentData.OwnedPets[AgentData.ActivePetIndex], FortCharacter := Player.GetFortCharacter[]):
                PetProp : creative_prop = PetPropTuple(0)

                PetLoc : vector3 = PetProp.GetTransform().Translation
                PlayerLoc : vector3 = FortCharacter.GetTransform().Translation
                DistanceToPlayer : float = Distance(PetLoc, PlayerLoc)


                if (DistanceToPlayer >= FollowDistance):
                    if (Direction := (PlayerLoc - PetLoc).MakeUnitVector[]):
                        DistanceToTravel : float = DistanceToPlayer - WaitDistance
                        var LocationToTravel : vector3 = PetLoc + (Direction * DistanceToTravel)

                        # Stop continuous hover and idle animation during movement
                        set AgentData.bPetPlayingAnim = false
                        set AgentData.bPetContinuousHover = false

                        if (PropAnimController := PetProp.GetAnimationController[]):
                            PropAnimController.Stop()

                        PlayerRotation := FortCharacter.GetTransform().Rotation
                        spawn{ MovePetAndRestartHover(PetProp, LocationToTravel, PlayerRotation, SleepTime, Player) }
                else:
                    # When close to player, ensure continuous hover is active
                    if (AgentData.bPetContinuousHover = false):
                        set AgentData.bPetContinuousHover = true
                    
                    # Keep the original idle animation when very close
                    if (AgentData.bPetPlayingAnim = false):
                        set AgentData.bPetPlayingAnim = true
                        if (PropAnimController := PetProp.GetAnimationController[]):
                            PropAnimController.SetAnimation(IdleAnimationKeyFrames, ?Mode := animation_mode.Loop)
                            PropAnimController.Play()

    StartContinuousHover(Agent : agent)<suspends>:void=
        if (AgentData := AgentMap[Agent]):
            set AgentData.bPetContinuousHover = true
            loop:
                if (AgentData.bPetContinuousHover = false):
                    break
                    
                if (PetPropTuple := AgentData.OwnedPets[AgentData.ActivePetIndex]):
                    PetProp : creative_prop = PetPropTuple(0)
                    
                    # Only animate if pet is not currently moving to follow player
                    if (AgentData.bPetPlayingAnim = false):
                        if (PropAnimController := PetProp.GetAnimationController[]):
                            # Check if animation is not already playing or if it's the wrong animation
                            AnimState := PropAnimController.GetState()
                            if (AnimState = animation_controller_state.Stopped or AnimState = animation_controller_state.AnimationNotSet):
                                PropAnimController.SetAnimation(ContinuousHoverKeyFrames, ?Mode := animation_mode.Loop)
                                PropAnimController.Play()
                
                Sleep(0.5) # Check every half second

    MovePetAndRestartHover(PetProp : creative_prop, LocationToTravel : vector3, PlayerRotation : rotation, SleepTime : float, Player : player)<suspends>:void=
        PetProp.MoveTo(LocationToTravel, PlayerRotation, SleepTime)
        # Restart continuous hover after movement
        Sleep(SleepTime + 0.1)
        if (TempAgentData := AgentMap[Player]):
            set TempAgentData.bPetContinuousHover = true

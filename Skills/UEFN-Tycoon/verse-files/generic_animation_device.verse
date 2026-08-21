
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Devices/CreativeAnimation }
using { /Fortnite.com/Devices/CreativeAnimation/InterpolationTypes }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Random }
# See https://dev.epicgames.com/documentation/en-us/uefn/create-your-own-device-in-verse for how to create a verse device.

animation_curve := class<concrete>:
    @editable
    X0 : float = 0.1

    @editable
    Y0 : float = 0.05

    @editable
    BounceTime : float = 0.85

    @editable
    BounceScale : float = 0.9

    Curve():cubic_bezier_parameters=
        return cubic_bezier_parameters{X0:=Clamp(X0,0.0,1.0), Y0:=Y0, X1:=Clamp(BounceTime,0.0,1.0), Y1:=BounceScale}


keyframe_info := class<concrete>:
    @editable
    Prop : creative_prop = creative_prop{}

    @editable
    Time : float = 2.0

    @editable
    MovementType : movement_type = movement_type.Ease_Movement

    @editable
    CustomCurve : animation_curve = animation_curve{}

    MoveType():cubic_bezier_parameters=
        case(MovementType):
            movement_type.Linear_Movement =>
                return InterpolationTypes.Linear
            movement_type.Ease_Movement =>
                return InterpolationTypes.Ease
            movement_type.EaseIn_Movement =>
                return InterpolationTypes.EaseIn
            movement_type.EaseOut_Movement =>
                return InterpolationTypes.EaseOut
            movement_type.EaseInOut_Movement =>
                return InterpolationTypes.EaseInOut
            movement_type.UseCustomCurve =>
                return CustomCurve.Curve()


#movement_type := enum{Linear, Ease, EaseIn, EaseOut, EaseInOut}
movement_type := enum{Linear_Movement, Ease_Movement, EaseIn_Movement, EaseOut_Movement, EaseInOut_Movement, UseCustomCurve}

manual_animation_settings := class<concrete>:
    @editable
    DeltaRotation : rotation = rotation{}

    @editable
    DeltaLocation : vector3 = vector3{}

    @editable
    DeltaScale : vector3 = vector3{X:=1.0, Y:=1.0, Z:=1.0}

    @editable
    var MoveTime : float = 1.0

    @editable
    MovementType : movement_type = movement_type.Ease_Movement

    @editable
    CustomCurve : animation_curve = animation_curve{}

    MoveType():cubic_bezier_parameters=
        case(MovementType):
            movement_type.Linear_Movement =>
                return InterpolationTypes.Linear
            movement_type.Ease_Movement =>
                return InterpolationTypes.Ease
            movement_type.EaseIn_Movement =>
                return InterpolationTypes.EaseIn
            movement_type.EaseOut_Movement =>
                return InterpolationTypes.EaseOut
            movement_type.EaseInOut_Movement =>
                return InterpolationTypes.EaseInOut
            movement_type.UseCustomCurve =>
                return CustomCurve.Curve()

    #@editable
    #MoveMode : animation_mode = animation_mode.PingPong

var SessionSpeedMultipleMap : weak_map(session,[int]float) = map{}

# A Verse-authored creative device that can be placed in a level
generic_animation_device := class(creative_device):

    @editable 
    AnimationName : string = "Unnamed Animation"

    var AnimationNumber : int = 0

    @editable
    StartByDefault : logic = true

    @editable
    UseManualMovement : logic = false

    @editable
    ManualMoveSettings : manual_animation_settings = manual_animation_settings{}

    #@editable
    #ToggleAnimationTrigger : trigger_device = trigger_device{}
    

    var StartedByTrigger : logic = false

    @editable
    PropsToMove : []creative_prop = array{}

    @editable
    KeyLocationInfo : []keyframe_info = array{}

    @editable
    DelayBetweenStarts : float = 2.0

    @editable
    TimeBeforeFirstStart : float = 10.0

    @editable
    TimeOnManualActivation : float = 1.0

    @editable
    HideHeightChange : float = -1000.0

    var StartingPosMap : [int]transform = map{}

    var KeepAnimating : logic = true

    var SpeedChanged : logic = false

    var TimeToHideBackup : float = 10.0

    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        if(MainMap := SessionSpeedMultipleMap[GetSession()]):
        else:
            if(set SessionSpeedMultipleMap[GetSession()] = map{}){}
            else{Print("Failed to set session speed multiple map.")}
        for(Index -> PropToMove : PropsToMove):
            if(set StartingPosMap[Index] = PropToMove.GetTransform()){}
            else{Print("Failed to get starting position for prop {Index} in animation {AnimationName}.")}
        #Sleep(5.0) bad to sleep entire device
        if(StartByDefault?):
            spawn{ActivationSequence(TimeBeforeFirstStart,"Default")}
        else:
            Print("Animation ready to be started by another device.")

    ToggleAnimation(MaybeAgent : ?agent, TriggeringDeviceInfo : string):void=
        if(KeepAnimating?):
            set KeepAnimating = false
            Print("Stopping Animation", ?Duration:= 5.0)
        else:
            set KeepAnimating = true
            spawn{ActivationSequence(TimeOnManualActivation, TriggeringDeviceInfo + "toggle")}
            Print("Starting Animation", ?Duration:= 5.0)

    StartAnimating(TriggeringDeviceInfo : string):void=
        spawn{ReallyStartAnimating(TriggeringDeviceInfo)}

    ReallyStartAnimating(TriggeringDeviceInfo : string)<suspends>:void=
        Sleep(GetRandomFloat(0.0, 0.5))
        if(var MainMap : [int]float = SessionSpeedMultipleMap[GetSession()]):
            loop:
                Sleep(0.1)
                if:
                    not MainMap[AnimationNumber]
                    set MainMap[AnimationNumber] = 1.0
                    set SessionSpeedMultipleMap[GetSession()] = MainMap
                then:
                    break
                else:
                    set AnimationNumber += 1
        else:
            Print("failed to get session speed stuff", ?Duration:= 5.0)
        Print("Animation Started.")
        set KeepAnimating = true
        spawn{ActivationSequence(TimeOnManualActivation, TriggeringDeviceInfo)}

    StopAnimating():void=
        Print("Animation Stopped.")
        set KeepAnimating = false
        for(Index -> Prop : PropsToMove):
            #if(Controller := Prop.GetAnimationController[]):
            #    Controller.Pause()
            if(ReturnSpot := StartingPosMap[Index]):
                Destination := transform{Translation := ReturnSpot.Translation +  vector3{Z:=HideHeightChange}}
                spawn{CarefullyHide(Prop,Destination)}
            else:
                Print("Failed to return prop {Index} to starting position.")
            
    CarefullyHide(Prop : creative_prop, Destination : transform)<suspends>:void=
        if(Controller := Prop.GetAnimationController[]):
            race:
                loop:
                    Sleep(0.0)
                    Controller.MovementCompleteEvent.Await()
                    race:
                        loop:
                            Sleep(0.0)
                            Controller.MovementCompleteEvent.Await()
                            break
                        loop:
                            Sleep(2.5)
                            break
                    break
                loop:
                    Sleep(TimeToHideBackup)
                    break
            ActualHide(Prop,Destination)

    ActualHide(Prop : creative_prop, Destination : transform)<suspends>:void=
        Prop.MoveTo(Destination, 1.0)
        Sleep(4.5)
        spawn{Prop.MoveTo(Destination, 1.0)}
        

        
    ActivationSequence(Delay : float, TriggeringDeviceInfo : string)<suspends>:void=
        Sleep(Delay)
        for(Index -> PropToMove : PropsToMove):
            spawn{StartAnimation(Index, PropToMove, TriggeringDeviceInfo)}
            Sleep(DelayBetweenStarts)
        
    StartAnimation(PropIndex : int, PropToMove : creative_prop, TriggeringDeviceInfo : string)<suspends>:void=
        if(Pos := StartingPosMap[PropIndex]):
            PropToMove.MoveTo(Pos, 1.0)
        if(UseManualMovement?):
            spawn{ManualAnimation(PropIndex, PropToMove, TriggeringDeviceInfo)}
            return
        #Print("Starting Animation", ?Duration:= 40.0)
        var CurrentSpeedMultiple : float = 0.01
        if(var MainMap : [int]float = SessionSpeedMultipleMap[GetSession()]):
            if(Mult := MainMap[AnimationNumber]):
                set CurrentSpeedMultiple = Mult
            else:
                Print("Failed to get speed multiple from map for prop {PropIndex} in animation {AnimationName}.")
        else:
            Print("Failed to get speed multiple from session for prop {PropIndex} in animation {AnimationName}.")
        Sleep(0.0)
        if(Controller := PropToMove.GetAnimationController[]):
            var FirstTransform : transform = PropToMove.GetTransform()
            var SecondTransform : transform = PropToMove.GetTransform()
            var Prop1 : creative_prop = PropToMove
            var Prop2 : creative_prop = PropToMove
            var Frames : []keyframe_delta = array{}
            #var DeltaLoc : vector3 = vector3{}
            #var DeltaRot : rotation = rotation{}
            #keyframe_delta{DeltaLocation:=vector3{},DeltaRotation:=rotation{},Time:=0.0}
            for (Index -> Info : KeyLocationInfo):
                if(PrevInfo := KeyLocationInfo[Index-1]):
                    set Prop1 = PrevInfo.Prop
                if(NewInfo := KeyLocationInfo[Index]):
                    set Prop2 = NewInfo.Prop
                set FirstTransform = Prop1.GetTransform()
                #Print("First Transform location is X:{FirstTransform.Translation.X}, Y:{FirstTransform.Translation.Y}, Z:{FirstTransform.Translation.Z}", ?Duration:= 40.0)
                set SecondTransform = Prop2.GetTransform()
                #Print("Second Transform location is X:{SecondTransform.Translation.X}, Y:{SecondTransform.Translation.Y}, Z:{SecondTransform.Translation.Z}", ?Duration:= 40.0)
                DeltaLoc := SecondTransform.Translation - FirstTransform.Translation
                DeltaRot := MakeShortestRotationBetween(SecondTransform.Rotation,FirstTransform.Rotation)
                DeltaSca := SecondTransform.Scale/FirstTransform.Scale
                #Print("Adding frame: DeltaLoc: {DeltaLoc}, DeltaRot: {DeltaRot}, DeltaScale: {DeltaSca}, Time: {Info.Time}", ?Duration:= 40.0)
                set Frames += array{keyframe_delta{DeltaLocation:=DeltaLoc,DeltaRotation:=DeltaRot,Time:=Info.Time * CurrentSpeedMultiple, DeltaScale := DeltaSca, Interpolation:=Info.MoveType()}}
            #Print("There are {Frames.Length} frames. Playing animation", ?Duration:= 40.0)
            Controller.SetAnimation(Frames, ?Mode := animation_mode.OneShot)
            Controller.Play()
            Controller.MovementCompleteEvent.Await()
            if(KeepAnimating?):
                spawn{StartAnimation(PropIndex, PropToMove, TriggeringDeviceInfo)}
            else:
                #Print("Stopped animating", ?Duration:= 40.0)
        else:
            Print("No Animation Controller found on {AnimationName}. Device was triggered by {TriggeringDeviceInfo}", ?Duration:= 40.0)


    ManualAnimation(PropIndex : int, PropToMove : creative_prop, TriggeringDeviceInfo : string)<suspends>:void=
        var CurrentSpeedMultiple : float = 0.01
        if(var MainMap : [int]float = SessionSpeedMultipleMap[GetSession()]):
            if(Mult := MainMap[AnimationNumber]):
                set CurrentSpeedMultiple = Mult
            else:
                Print("Failed to get speed multiple from map for prop {PropIndex} in animation {AnimationName}.")
        else:
            Print("Failed to get speed multiple from session for prop {PropIndex} in animation {AnimationName}.")
        Sleep(0.05)
        Print("CurrentSpeedMultiple is {CurrentSpeedMultiple}.", ?Duration:= 5.0)
        if(ThisController := PropToMove.GetAnimationController[]):
            var Frames : []keyframe_delta = array{keyframe_delta{DeltaLocation:=ManualMoveSettings.DeltaLocation,DeltaRotation:=ManualMoveSettings.DeltaRotation,Time:=ManualMoveSettings.MoveTime * CurrentSpeedMultiple, DeltaScale := ManualMoveSettings.DeltaScale, Interpolation:=ManualMoveSettings.MoveType()}}
            ThisController.SetAnimation(Frames, ?Mode := animation_mode.OneShot)
            ThisController.Play()
            ThisController.MovementCompleteEvent.Await()
            spawn{ReverseManualAnimation(PropIndex, PropToMove, TriggeringDeviceInfo)}
        else:
            Print("No Animation Controller found on {AnimationName}.", ?Duration:= 40.0)

    ReverseManualAnimation(PropIndex : int, PropToMove : creative_prop, TriggeringDeviceInfo : string)<suspends>:void=
        var CurrentSpeedMultiple : float = 0.01
        if(var MainMap : [int]float = SessionSpeedMultipleMap[GetSession()]):
            if(Mult := MainMap[AnimationNumber]):
                set CurrentSpeedMultiple = Mult
            else:
                Print("Failed to get speed multiple map for prop {PropIndex} in animation {AnimationName}.")
        else:
            Print("Failed to get speed multiple from session for prop {PropIndex} in animation {AnimationName}.")
        Sleep(0.05)
        Print("CurrentSpeedMultiple is {CurrentSpeedMultiple}.", ?Duration:= 5.0)
        if(ThisController := PropToMove.GetAnimationController[]):
            var Frames : []keyframe_delta = array{keyframe_delta{DeltaLocation:=ManualMoveSettings.DeltaLocation * -1.0,DeltaRotation:=rotation{}.UnrotateBy(ManualMoveSettings.DeltaRotation),Time:=ManualMoveSettings.MoveTime * CurrentSpeedMultiple, DeltaScale := vector3{X:=1.0/ManualMoveSettings.DeltaScale.X,Y:=1.0/ManualMoveSettings.DeltaScale.Y,Z:=1.0/ManualMoveSettings.DeltaScale.Z}, Interpolation:=ManualMoveSettings.MoveType()}}
            ThisController.SetAnimation(Frames, ?Mode := animation_mode.OneShot)
            ThisController.Play()
            ThisController.MovementCompleteEvent.Await()
            if(KeepAnimating?):
                spawn{ManualAnimation(PropIndex, PropToMove, TriggeringDeviceInfo)}
        Print("No Animation Controller found on {AnimationName}.", ?Duration:= 40.0)
            
        
    UpdateSpeed(Speed : float)<suspends>:void=
        if(var MainMap : [int]float = SessionSpeedMultipleMap[GetSession()]):
            if:
                set MainMap[AnimationNumber] = Speed
                set SessionSpeedMultipleMap[GetSession()] = MainMap
            then:
        else{Print("Failed to set speed multiple for animation {AnimationName}.")}

                    

    
            
        

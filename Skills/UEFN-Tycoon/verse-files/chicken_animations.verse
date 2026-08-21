
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Devices/CreativeAnimation }
using { /Verse.org/Random }
using { /UnrealEngine.com/Temporary/SpatialMath }

# See https://dev.epicgames.com/documentation/en-us/uefn/create-your-own-device-in-verse for how to create a verse device.

# A Verse-authored creative device that can be placed in a level
chicken_animations := class(creative_device):

    @editable
    Chickens : []creative_prop = array{}

    @editable
    CornerProps : []creative_prop = array{}

    @editable
    MaxTime : float = 3.0

    @editable
    MinTime : float = 1.5

    @editable
    PotentialRotateTime : float = 0.1

    @editable
    MaxRotDegreesWhileMoving : float = 5.0

    # New timing controls to reduce spinning and prevent very fast snaps
    @editable
    UseSpeedBasedMoveTime : logic = true

    # Units per second for forward movement when UseSpeedBasedMoveTime is true
    @editable
    WalkSpeed : float = 220.0

    # How fast rotations should occur (degrees per second)
    @editable
    RotateSpeedDegPerSec : float = 220.0

    # Ensure movement lasts at least this many times longer than rotation
    @editable
    MoveToRotateTimeRatio : float = 8.0

    # Fraction of the total rotation performed before moving (when large turn)
    @editable
    PreRotateFraction : float = 0.8

    @editable
    MinDistanceBetweenChickens : float = 150.0

    @editable
    OptionalSleepTimeToKeepTheServerAlive : float = 0.1

    @editable
    ReverseDivisionAmount : float = 20.0

    @editable
    ReverseTime : float = 1.0

    @editable
    MaxReverseRot : float = 1.0

    @editable
    MoveDivisionAmountWhileRotating : float = 300.0

    @editable
    MoveChance : int = 60

    @editable
    TimeBetweenChances : float = 3.0

    # Uniform heading mode: align all chickens to a single yaw and move forward
    @editable
    ForceUniformHeading : logic = false

    @editable
    UniformYawDegrees : float = 0.0

    # Keep movement inside corner bounds while using uniform heading
    @editable
    RespectBounds : logic = true

    @editable
    BoundsMargin : float = 10.0

    var XMax : float = 0.0
    var XMin : float = 0.0
    var YMax : float = 0.0
    var YMin : float = 0.0

    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        Activate()


    Activate()<suspends>:void=
        if(FirstCorner := CornerProps[0]):
            FPos := FirstCorner.GetTransform().Translation
            set XMax = FPos.X
            set XMin = FPos.X
            set YMax = FPos.Y
            set YMin = FPos.Y
            for(Prop: CornerProps):
                Pos := Prop.GetTransform().Translation
                if(Pos.X > XMax){set XMax = Pos.X}
                if(Pos.X < XMin){set XMin = Pos.X}
                if(Pos.Y > YMax){set YMax = Pos.Y}
                if(Pos.Y < YMin){set YMin = Pos.Y}
        for(Index -> Chicken : Chickens):
            spawn{MoveAround(Index,Chicken)}
            Sleep(GetRandomFloat(0.0,2.0))

    MoveAround(Index : int,Chicken : creative_prop)<suspends>:void=
        Axis := vector3{Z:=1.0}
        if(Controller := Chicken.GetAnimationController[]):
            loop:
                Num := GetRandomInt(0,100)
                if(Num > MoveChance):
                    Controller.Pause()
                    Sleep(TimeBetweenChances)
                else:
                    Sleep(OptionalSleepTimeToKeepTheServerAlive)
                    Pos := Chicken.GetTransform().Translation
                    Rot := Chicken.GetTransform().Rotation
                    Target := vector3{X:=GetRandomFloat(XMin, XMax),Y:=GetRandomFloat(YMin, YMax),Z:=Pos.Z}
                    DeltaPos := Target-Pos
                    Forward := Rot.GetLocalForward()
                    var DeltRot : rotation = MakeShortestRotationBetween(Forward,DeltaPos)
                    # Compute timing values so that movement is much longer than rotation
                    var Time : float = 0.0
                    var Info : float = RadiansToDegrees(DeltRot.GetAngle())
                    if(Info > 180.0):
                        set Info = Info-360.0
                        set DeltRot = MakeRotation(Axis,DegreesToRadians(Info))
                    if(Info < -180.0):
                        set Info = Info+360.0
                        set DeltRot = MakeRotation(Axis,DegreesToRadians(Info))
                    # Prepare adjusted rotation degrees in [-180, 180]
                    var Frames : []keyframe_delta = array{}

                    if(ForceUniformHeading = true):
                        # Rotate to uniform yaw, then move forward along that yaw
                        DesiredRot := MakeRotation(Axis,DegreesToRadians(UniformYawDegrees))
                        DesiredForward := DesiredRot.GetLocalForward()

                        AlignRot := MakeShortestRotationBetween(Forward, DesiredForward)
                        AlignDeg := RadiansToDegrees(AlignRot.GetAngle())
                        var AbsAlignDeg : float = AlignDeg
                        if(AbsAlignDeg < 0.0){ set AbsAlignDeg = -AbsAlignDeg }
                        AlignTimeBase := AbsAlignDeg / RotateSpeedDegPerSec
                        var AlignTime : float = AlignTimeBase
                        if(AlignTime < PotentialRotateTime){ set AlignTime = PotentialRotateTime }

                        var MoveTime : float = GetRandomFloat(MinTime, MaxTime)
                        if(MoveTime < AlignTime * MoveToRotateTimeRatio){ set MoveTime = AlignTime * MoveToRotateTimeRatio }
                        if(MoveTime < MinTime){ set MoveTime = MinTime }

                        StepDist := WalkSpeed * MoveTime
                        StepDir := DesiredForward
                        var AllowedDist : float = StepDist
                        if(RespectBounds = true):
                            var MaxAlongX : float = 1.0e12
                            var MaxAlongY : float = 1.0e12
                            if(StepDir.X > 0.0){ set MaxAlongX = (XMax - BoundsMargin - Pos.X) / StepDir.X }
                            if(StepDir.X < 0.0){ set MaxAlongX = (XMin + BoundsMargin - Pos.X) / StepDir.X }
                            if(StepDir.Y > 0.0){ set MaxAlongY = (YMax - BoundsMargin - Pos.Y) / StepDir.Y }
                            if(StepDir.Y < 0.0){ set MaxAlongY = (YMin + BoundsMargin - Pos.Y) / StepDir.Y }
                            var MaxStep : float = StepDist
                            if(MaxAlongX > 0.0 and MaxAlongX < MaxStep){ set MaxStep = MaxAlongX }
                            if(MaxAlongY > 0.0 and MaxAlongY < MaxStep){ set MaxStep = MaxAlongY }
                            if(MaxStep < AllowedDist){ set AllowedDist = MaxStep }
                            if(AllowedDist < 0.0){ set AllowedDist = 0.0 }
                        DesiredDelta := StepDir * AllowedDist

                        set Frames = array{keyframe_delta{DeltaLocation:=vector3{},Time:=AlignTime,DeltaRotation:=AlignRot}}
                        set Frames += array{keyframe_delta{DeltaLocation:=DesiredDelta,Time:=MoveTime,DeltaRotation:=MakeRotation(Axis,0.0)}}
                    else:
                        # Determine base move time (distance / speed) or legacy random time
                        DistToTarget := Distance(Pos, Target)
                        var BaseMoveTime : float = 0.0
                        if(UseSpeedBasedMoveTime = true):
                            if(WalkSpeed <= 0.0){ set BaseMoveTime = MaxTime } else { set BaseMoveTime = DistToTarget / WalkSpeed }
                        else:
                            set BaseMoveTime = GetRandomFloat(MinTime, MaxTime)

                        # Rotation time derived from degrees per second, with a min PotentialRotateTime
                        var AbsInfo : float = Info
                        if(AbsInfo < 0.0){ set AbsInfo = -AbsInfo }
                        RotTimeBase := AbsInfo / RotateSpeedDegPerSec
                        var RotTime : float = RotTimeBase
                        if(RotTime < PotentialRotateTime){ set RotTime = PotentialRotateTime }

                        # Enforce movement to be at least N times rotation and >= MinTime
                        var MoveTime : float = BaseMoveTime
                        if(MoveTime < RotTime * MoveToRotateTimeRatio){ set MoveTime = RotTime * MoveToRotateTimeRatio }
                        if(MoveTime < MinTime){ set MoveTime = MinTime }

                        if(Info > MaxRotDegreesWhileMoving or Info < -MaxRotDegreesWhileMoving):
                            Angle := DeltRot.GetAngle()
                            MostOfRot := MakeRotation(Axis,Angle*PreRotateFraction)
                            TheRest := MakeRotation(Axis,Angle*(1.0-PreRotateFraction))
                            PreRotTime := RotTime * PreRotateFraction
                            set Frames = array{keyframe_delta{DeltaLocation:=DeltaPos/MoveDivisionAmountWhileRotating,Time:=PreRotTime,DeltaRotation:=MostOfRot}}
                            set Frames += array{keyframe_delta{DeltaLocation:=(MoveDivisionAmountWhileRotating-1.0)*(DeltaPos/MoveDivisionAmountWhileRotating),Time:=MoveTime,DeltaRotation:=TheRest}}
                        else:
                            set Frames = array{keyframe_delta{DeltaLocation:=DeltaPos,Time:=MoveTime,DeltaRotation:=DeltRot}}
                    Controller.SetAnimation(Frames, ?Mode := animation_mode.OneShot)
                    Controller.Play()
                    race:
                        Controller.KeyframeReachedEvent.Await()
                        loop:
                            NewPos := Chicken.GetTransform().Translation
                            for(OtherIndex -> OtherChicken : Chickens):
                                Sleep(OptionalSleepTimeToKeepTheServerAlive)
                                if(not OtherIndex = Index):
                                    Dist := Distance(NewPos,OtherChicken.GetTransform().Translation)
                                    #Print("Distance between chickens: {Dist}")
                                    if(Dist < MinDistanceBetweenChickens):
                                        Controller.Pause()
                                        if(Index > OtherIndex):
                                            Controller.SetAnimation(array{keyframe_delta{DeltaLocation:=-DeltaPos/ReverseDivisionAmount;Time:=ReverseTime;DeltaRotation:=MakeRotation(Axis,DegreesToRadians(GetRandomFloat(-MaxReverseRot,MaxReverseRot)))}}, ?Mode := animation_mode.OneShot)
                                            Controller.Play()
                                            Controller.KeyframeReachedEvent.Await()
                                            break
                                        else:
                                            break
                            Sleep(OptionalSleepTimeToKeepTheServerAlive)
        else:   
            Sleep(1.0)
            Print("Failed to get chicken animation controller")
            MoveAround(Index,Chicken)
                        


        
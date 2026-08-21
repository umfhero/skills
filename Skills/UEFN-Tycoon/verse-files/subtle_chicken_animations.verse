
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Devices/CreativeAnimation }
using { /Verse.org/Random }
using { /UnrealEngine.com/Temporary/SpatialMath }

# See https://dev.epicgames.com/documentation/en-us/uefn/create-your-own-device-in-verse for how to create a verse device.

# A Verse-authored creative device that can be placed in a level
subtle_chicken_animations := class(creative_device):
    @editable
    Name : string = "Not set"

    @editable
    Chickens : []creative_prop = array{}

    @editable
    MaxTime : float = 1.0

    @editable
    MinTime : float = 0.5

    @editable
    MaxRotDegrees : float = 20.0

    @editable
    OptionalSleepTimeToKeepTheServerAlive : float = 0.0

    @editable
    TimeBetweenMoveChances : float = 1.0

    @editable
    RotChance : int = 40

    @editable
    JumpChance : int = 5

    @editable
    JumpHeight : float = 20.0

    @editable
    MinJumpTime : float = 0.2

    @editable
    MaxJumpTime : float = 0.5

    @editable
    MaxHeight : float = 100.0

    @editable
    HeightToReturnTo : float = 0.0


    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        Activate()


    Activate()<suspends>:void=
        for(Index -> Chicken : Chickens):
            spawn{MoveAround(Index,Chicken)}
            Sleep(GetRandomFloat(0.0,2.0))

    MoveAround(Index : int,Chicken : creative_prop)<suspends>:void=
        Axis := vector3{Z:=1.0}
        loop:
            Sleep(0.1)
            if(Controller := Chicken.GetAnimationController[]):
                Rand := GetRandomInt(0,100)
                if(Rand < RotChance):
                    Time := GetRandomFloat(MinTime,MaxTime)
                    var DeltaLoc : vector3 = vector3{}
                    var DeltaRot : rotation = MakeRotation(Axis,DegreesToRadians(GetRandomFloat(-MaxRotDegrees,MaxRotDegrees)))
                    Frames := array{keyframe_delta{DeltaLocation:=DeltaLoc,DeltaRotation:=DeltaRot,Time:=Time}}
                    Controller.SetAnimation(Frames, ?Mode := animation_mode.PingPong)
                    Controller.Play()
                    Controller.KeyframeReachedEvent.Await()
                    Controller.KeyframeReachedEvent.Await()
                else if(Rand > 100-JumpChance):
                    Time := GetRandomFloat(MinJumpTime,MaxJumpTime)
                    var DeltaLoc : vector3 = vector3{Z:=JumpHeight}
                    #var DeltaRot : rotation = MakeRotation(Axis,GetRandomFloat(-MaxRotDegrees/,MaxRotDegrees))
                    Frames := array{keyframe_delta{DeltaLocation:=DeltaLoc,DeltaRotation:=rotation{},Time:=Time}}
                    Controller.SetAnimation(Frames, ?Mode := animation_mode.PingPong)
                    Controller.Play()
                    Controller.KeyframeReachedEvent.Await()
                    Controller.KeyframeReachedEvent.Await()
                else:
                    Controller.Stop()
                    Sleep(TimeBetweenMoveChances)
            else:
                    Print("Failed to get chicken animation controller. Animation name: {Name}. \nMake sure that there are not any chicken prop slots set to None.")
                    Sleep(10.0)
                    MoveAround(Index,Chicken)
            if(Chicken.GetTransform().Translation.Z > MaxHeight):
                if(Controller := Chicken.GetAnimationController[]):
                    frame := keyframe_delta{DeltaLocation:=vector3{Z:=HeightToReturnTo - Chicken.GetTransform().Translation.Z},DeltaRotation:=rotation{},Time:=0.5}
                    Controller.SetAnimation(array{frame}, ?Mode := animation_mode.OneShot)
                    Controller.Play()
                    Sleep(4.0)

                        


        
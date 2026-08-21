
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters }
using { /UnrealEngine.com/Temporary/SpatialMath }
# See https://dev.epicgames.com/documentation/en-us/uefn/create-your-own-device-in-verse for how to create a verse device.

# A Verse-authored creative device that can be placed in a level
BehaviorHelper := class(creative_device):

  

    FindNearestTarget(FC : fort_character)<decides><transacts> : fort_character =
        var MaybeTarget : ?fort_character = false
        var CheckRange : float = 1000.0
        for(Player : GetPlayspace().GetPlayers(), PlayerFC := Player.GetFortCharacter[]):
            if:
                DistanceDiffernce := Distance(PlayerFC.GetTransform().Translation, FC.GetTransform().Translation) < CheckRange
                not PlayerFC = FC
            then:
                set MaybeTarget = option{PlayerFC}
                set CheckRange = DistanceDiffernce

        return MaybeTarget?
            



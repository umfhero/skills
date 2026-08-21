using { /Fortnite.com/AI }
using { /Verse.org/Simulation }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Animation/PlayAnimation }
using { /Verse.org/Assets }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/Game }

Skeletons<public> := class(npc_behavior):
    BehaviorHelp : BehaviorHelper = BehaviorHelper{}
    var Attack1 : animation_sequence = MobZombie.Demon_Anim_EnemyArmature_EnemyArmature_EnemyArmature_Attack

    # This function runs when the NPC is spawned in the world and ready to follow a behavior.
    OnBegin<override>()<suspends>:void=
        if:
            NPCAgent := GetAgent[]
            NPCChar := NPCAgent.GetFortCharacter[]

            NPCNav := NPCChar.GetNavigatable[]
            NPCFocus := NPCChar.GetFocusInterface[]
            NPCAnim := NPCChar.GetPlayAnimationController[]
        then:
            NPCSpawnPoint := NPCChar.GetTransform().Translation

            # Lower overall tankiness compared to the Giant
            OldMax := NPCChar.GetMaxHealth()
            NPCChar.SetMaxHealth(OldMax * 2.5)
            NPCChar.SetHealth(NPCChar.GetMaxHealth())

            # Give a smaller shield pool than the Giant
            NPCChar.SetMaxShield(5.0)
            NPCChar.SetShield(5.0)

            # No damage-reduction hook for Skeletons to keep them lighter than Giants

            loop:
                Sleep(0.1)
                if(not NPCChar.IsActive[]):
                    break
                if(NewTarget := BehaviorHelp.FindNearestTarget[NPCChar],NewAgent := NewTarget.GetAgent[]):
                    spawn{NPCFocus.MaintainFocus(NewAgent)}
                    NavTarget := MakeNavigationTarget(NewAgent)
                    NPCNav.NavigateTo(NavTarget , ?MovementType := movement_types.Running, ?ReachRadius := 150.0)
                    NPCAnim.Play(Attack1)
                    Sleep(0.46)
                    if(Distance(NPCChar.GetTransform().Translation, NewTarget.GetTransform().Translation) < 200.0):
                        NewTarget.Damage(15.0)

    # This function runs when the NPC is despawned or eliminated from the world.


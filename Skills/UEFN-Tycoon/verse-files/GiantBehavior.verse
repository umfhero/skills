using { /Fortnite.com/AI }
using { /Verse.org/Simulation }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Animation/PlayAnimation }
using { /Verse.org/Assets }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/Game }

GiantBehavior<public> := class(npc_behavior):
    BehaviorHelp : BehaviorHelper = BehaviorHelper{}
    var Attack1 : animation_sequence = MobZombie.Demon_Anim_EnemyArmature_EnemyArmature_EnemyArmature_Attack

    @editable
    HealthMultiplier : float = 5.0

    @editable
    MaxShieldAmount : float = 100.0

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

            # Set the NPC's max health and shield based on tunables for target TTK
            # Giants are 2x beefier than skeletons (who use 5.0 and 50.0)
            OldMax := NPCChar.GetMaxHealth()
            NPCChar.SetMaxHealth(OldMax * HealthMultiplier)
            NPCChar.SetHealth(NPCChar.GetMaxHealth())

            NPCChar.SetMaxShield(MaxShieldAmount)
            NPCChar.SetShield(MaxShieldAmount)

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
    OnEnd<override>():void=
        Print("Goodbye, Giant!")

using { /Fortnite.com/Devices }
using { /Fortnite.com/Marketplace }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Verse.org/Assets }
using { /Verse.org/Simulation }

# Gun store: V-Bucks unlocks for Machine Gun + Rocket Launcher,
# Coin (Gold) purchases for Pistol / Assault Rifle / SCAR via conditional buttons.

# ---- Localized text for V-Bucks guns --------------------------------------------
GunInfo<public> := module:
    MachineGun<public> := module:
        Name<public><localizes>:message = "Machine Gun"
        Description<public><localizes>:message = "Permanently unlocks the Machine Gun. Pick one up any time from the granter."
        ShortDescription<public><localizes>:message = "Permanent Machine Gun unlock."

    RocketLauncher<public> := module:
        Name<public><localizes>:message = "Rocket Launcher"
        Description<public><localizes>:message = "Permanently unlocks the Rocket Launcher. Pick one up any time from the granter."
        ShortDescription<public><localizes>:message = "Permanent Rocket Launcher unlock."

# ---- Entitlements (V-Bucks guns) ------------------------------------------------
GunEntitlements<public> := module:
    using {GunInfo}

    # Base type for all gun entitlements in this experience.
    gun_entitlement<public> := class<abstract><castable>(entitlement){}

    machine_gun_access<public> := class<concrete>(gun_entitlement):
        var Name<override>:message = MachineGun.Name
        var Description<override>:message = MachineGun.Description
        var ShortDescription<override>:message = MachineGun.ShortDescription
        # TODO: swap moonpass for a real machine gun screenshot texture
        var Icon<override>:texture = A_MCSkyblock.market.moonpass
        PaidRandomItem<override>:logic = false
        PaidArea<override>:logic = false
        ConsequentialToGameplay<override>:logic = true

    rocket_launcher_access<public> := class<concrete>(gun_entitlement):
        var Name<override>:message = RocketLauncher.Name
        var Description<override>:message = RocketLauncher.Description
        var ShortDescription<override>:message = RocketLauncher.ShortDescription
        # TODO: swap moonpass for a real rocket launcher screenshot texture
        var Icon<override>:texture = A_MCSkyblock.market.moonpass
        PaidRandomItem<override>:logic = false
        PaidArea<override>:logic = false
        ConsequentialToGameplay<override>:logic = true

# ---- Offers (V-Bucks guns) ------------------------------------------------------
GunOffers<public> := module:
    using {GunInfo}

    machine_gun_access<public> := class(entitlement_offer):
        var Name<override>:message             = GunInfo.MachineGun.Name
        var Description<override>:message      = GunInfo.MachineGun.Description
        var ShortDescription<override>:message = GunInfo.MachineGun.ShortDescription
        var Icon<override>:texture             = A_MCSkyblock.market.moonpass
        EntitlementType<override>:concrete_subtype(entitlement) = GunEntitlements.machine_gun_access
        # 50 V-Bucks minimum; adjust upward in 50-Vbuck increments.
        Price<override>:price_dimension = MakePriceVBucks(50.0)

    rocket_launcher_access<public> := class(entitlement_offer):
        var Name<override>:message             = GunInfo.RocketLauncher.Name
        var Description<override>:message      = GunInfo.RocketLauncher.Description
        var ShortDescription<override>:message = GunInfo.RocketLauncher.ShortDescription
        var Icon<override>:texture             = A_MCSkyblock.market.moonpass
        EntitlementType<override>:concrete_subtype(entitlement) = GunEntitlements.rocket_launcher_access
        Price<override>:price_dimension = MakePriceVBucks(100.0)

# ---- Device ---------------------------------------------------------------------
gun_store := class(creative_device):

    # ---- V-Bucks side ----
    @editable
    VBucksStoreButton:button_device = button_device{}     # press to open the V-Bucks offers dialog

    @editable
    MachineGunGranter:item_granter_device = item_granter_device{}     # configure with Machine Gun item

    @editable
    RocketLauncherGranter:item_granter_device = item_granter_device{} # configure with Rocket Launcher item

    # ---- Coin (Gold) side ----
    # In UEFN, set each conditional_button_device's required item to your Gold currency
    # with counts: Pistol = 500, Assault Rifle = 1500, SCAR = 3000.
    @editable
    PistolButton:conditional_button_device = conditional_button_device{}
    @editable
    PistolGranter:item_granter_device = item_granter_device{}

    @editable
    AssaultRifleButton:conditional_button_device = conditional_button_device{}
    @editable
    AssaultRifleGranter:item_granter_device = item_granter_device{}

    @editable
    ScarButton:conditional_button_device = conditional_button_device{}
    @editable
    ScarGranter:item_granter_device = item_granter_device{}

    # ---- Entitlement subscription bookkeeping ----
    var EntitlementChangeSubscription:[player]?cancelable = map{}
    var PlayerJoinSubscription:?cancelable = false
    var PlayerLeftSubscription:?cancelable = false

    OnBegin<override>()<suspends>:void =
        SubJoin := GetPlayspace().PlayerAddedEvent().Subscribe(OnPlayerJoin)
        set PlayerJoinSubscription = option{ SubJoin }

        SubLeft := GetPlayspace().PlayerRemovedEvent().Subscribe(OnPlayerLeft)
        set PlayerLeftSubscription = option{ SubLeft }

        # V-Bucks store entry point
        VBucksStoreButton.InteractedWithEvent.Subscribe(OnVBucksStoreButtonPressed)

        # Coin store buttons — conditional_button_device auto-deducts the required gold count
        # when activated, we just grant the matching weapon.
        PistolButton.ActivatedEvent.Subscribe(OnPistolPurchased)
        AssaultRifleButton.ActivatedEvent.Subscribe(OnAssaultRiflePurchased)
        ScarButton.ActivatedEvent.Subscribe(OnScarPurchased)

        # Catch players who joined before this device's OnBegin (same fix as SpaceStage)
        for (ExistingPlayer : GetPlayspace().GetPlayers()):
            Print("GunStore: catching up existing player")
            OnPlayerJoin(ExistingPlayer)

    OnEnd<override>() : void =
        if (Sub := PlayerJoinSubscription?):
            Sub.Cancel()
        if (Sub := PlayerLeftSubscription?):
            Sub.Cancel()

    OnPlayerJoin(InPlayer:player):void =
        Subscription := GetEntitlementsChangedEvent(InPlayer, GunEntitlements.gun_entitlement).Subscribe(OnPurchasesChanged)
        if (set EntitlementChangeSubscription[InPlayer] = option{Subscription}):
            Print("GunStore: subscribed to entitlement changes for player")
        spawn{ GrantOwnedGunsOnJoin(InPlayer) }

    OnPlayerLeft(Player:player):void =
        if (Sub := EntitlementChangeSubscription[Player]?):
            Sub.Cancel()

        var TempMap:[player]?cancelable = map{}
        for (Key -> Value : EntitlementChangeSubscription, Key <> Player):
            set TempMap = ConcatenateMaps(TempMap, map{Key => Value})
        set EntitlementChangeSubscription = TempMap

    # ---- V-Bucks flow ----------------------------------------------------------
    OnVBucksStoreButtonPressed(Agent:agent):void =
        if (Player := player[Agent]):
            spawn{ ShowGunStoreDialog(Player) }

    ShowGunStoreDialog(Player:player)<suspends>:void =
        ShowOffersDialog(Player, array{ GunOffers.machine_gun_access{}, GunOffers.rocket_launcher_access{} })

    # Fires when a player's gun entitlements change (purchase or refund)
    OnPurchasesChanged(Player:player, EntitlementChanges:[]entitlement_change(entitlement)):void =
        Print("GunStore: OnPurchasesChanged fired with {EntitlementChanges.Length} changes")
        spawn{ GrantOwnedGunsOnJoin(Player) }

    # Walk what the player owns and grant the corresponding guns once.
    GrantOwnedGunsOnJoin(Player:player)<suspends>:void =
        Purchases := GetPurchasedEntitlements(Player, GunEntitlements.gun_entitlement)
        Print("GunStore: player owns {Purchases.Length} gun entitlements")
        for (PurchaseTuple : Purchases):
            Ent := PurchaseTuple(0)
            if (MG := GunEntitlements.machine_gun_access[Ent]):
                Print("GunStore: granting Machine Gun")
                MachineGunGranter.GrantItem(Player)
            if (RL := GunEntitlements.rocket_launcher_access[Ent]):
                Print("GunStore: granting Rocket Launcher")
                RocketLauncherGranter.GrantItem(Player)

    # ---- Coin flow -------------------------------------------------------------
    # conditional_button_device handles the cost deduction automatically;
    # ActivatedEvent only fires when the player had enough gold to pay.
    OnPistolPurchased(Agent:agent):void =
        Print("GunStore: pistol purchased")
        PistolGranter.GrantItem(Agent)

    OnAssaultRiflePurchased(Agent:agent):void =
        Print("GunStore: assault rifle purchased")
        AssaultRifleGranter.GrantItem(Agent)

    OnScarPurchased(Agent:agent):void =
        Print("GunStore: SCAR purchased")
        ScarGranter.GrantItem(Agent)

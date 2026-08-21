using { /Fortnite.com/Devices }
using { /Fortnite.com/Marketplace }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Verse.org/Assets }
using { /Verse.org/Simulation }

# Promote the asset-digest modules to <public> so this file (and any other) can read
# textures from /A_MCSkyblock/market. On the next Verse build, the auto-generated
# Assets.digest.verse will be regenerated with these <public> specifiers.
A_MCSkyblock<public> := module:
    market<public> := module{}

# Documentation for In-Island Transactions: https://fn.gg/z38

# ---- Localized text & constants -------------------------------------------------
EntitlementInfo<public> := module:
    SpaceArea<public> := module:
        Name<public><localizes>:message = "Moon Pass"
        Description<public><localizes>:message = "Permanently unlocks access to the moon area."
        ShortDescription<public><localizes>:message = "Unlock the moon area!"

# ---- Entitlements ---------------------------------------------------------------
Entitlements<public> := module:
    using {EntitlementInfo}

    # Base type for all entitlements in this experience. <castable> lets us downcast
    # generic `entitlement` references back to specific subclasses.
    feature_example_entitlement<public> := class<abstract><castable>(entitlement){}

    # Permanent unlock for the moon area. NOT consumable — a paid area.
    space_area_access<public> := class<concrete>(feature_example_entitlement):
        var Name<override>:message = SpaceArea.Name
        var Description<override>:message = SpaceArea.Description
        var ShortDescription<override>:message = SpaceArea.ShortDescription
        var Icon<override>:texture = A_MCSkyblock.market.moonpass
        PaidRandomItem<override>:logic = false
        PaidArea<override>:logic = true
        ConsequentialToGameplay<override>:logic = false

# ---- Offers ---------------------------------------------------------------------
ExampleOffers<public> := module:
    using {EntitlementInfo}

    space_area_access<public> := class(entitlement_offer):
        var Name<override>:message             = EntitlementInfo.SpaceArea.Name
        var Description<override>:message      = EntitlementInfo.SpaceArea.Description
        var ShortDescription<override>:message = EntitlementInfo.SpaceArea.ShortDescription
        var Icon<override>:texture             = A_MCSkyblock.market.moonpass

        EntitlementType<override>:concrete_subtype(entitlement) = Entitlements.space_area_access
        Price<override>:price_dimension = MakePriceVBucks(500.0)  # 50–5000 in 50-Vbuck increments

# ---- Device ---------------------------------------------------------------------
SpaceStage := class(creative_device):

    @editable
    PurchaseButton:button_device = button_device{}

    @editable
    MoonAreaBarrier:barrier_device = barrier_device{}

    var EntitlementChangeSubscription:[player]?cancelable = map{}
    var PlayerJoinSubscription:?cancelable = false
    var PlayerLeftSubscription:?cancelable = false

    OnBegin<override>()<suspends>:void =
        SubJoin := GetPlayspace().PlayerAddedEvent().Subscribe(OnPlayerJoin)
        set PlayerJoinSubscription = option{ SubJoin }

        SubLeft := GetPlayspace().PlayerRemovedEvent().Subscribe(OnPlayerLeft)
        set PlayerLeftSubscription = option{ SubLeft }

        PurchaseButton.InteractedWithEvent.Subscribe(OnPurchaseButtonPressed)

        # Barrier starts blocking; ValidatePreviousPurchases / OnPurchasesChanged remove it.
        MoonAreaBarrier.Enable()

        # Players who were already in the playspace before this device's OnBegin ran
        # won't get a PlayerAddedEvent — handle them retroactively.
        for (ExistingPlayer : GetPlayspace().GetPlayers()):
            Print("Catching up player who joined before OnBegin")
            OnPlayerJoin(ExistingPlayer)

    OnEnd<override>() : void =
        if (Sub := PlayerJoinSubscription?):
            Sub.Cancel()
        if (Sub := PlayerLeftSubscription?):
            Sub.Cancel()

    OnPlayerJoin(InPlayer:player):void =
        Subscription := GetEntitlementsChangedEvent(InPlayer, Entitlements.feature_example_entitlement).Subscribe(OnPurchasesChanged)
        if (set EntitlementChangeSubscription[InPlayer] = option{Subscription}):
            Print("Subscribed to entitlement changes for player")
        spawn{ ValidatePreviousPurchases(InPlayer) }

    OnPlayerLeft(Player:player):void =
        if (Sub := EntitlementChangeSubscription[Player]?):
            Sub.Cancel()

        var TempMap:[player]?cancelable = map{}
        for (Key -> Value : EntitlementChangeSubscription, Key <> Player):
            set TempMap = ConcatenateMaps(TempMap, map{Key => Value})
        set EntitlementChangeSubscription = TempMap

    OnPurchaseButtonPressed(Agent:agent):void =
        if (Player := player[Agent]):
            # If they already own it (e.g. from a previous session), just unlock — don't try to re-buy.
            spawn{ HandlePurchaseButton(Player) }

    HandlePurchaseButton(Player:player)<suspends>:void =
        Purchases := GetPurchasedEntitlements(Player, Entitlements.feature_example_entitlement)
        for (PurchaseTuple : Purchases):
            Ent := PurchaseTuple(0)
            if (MoonPass := Entitlements.space_area_access[Ent]):
                Print("Player already owns Moon Pass — unlocking without re-buying")
                UnlockMoonArea()
                return
        TryBuyOffer(Player, ExampleOffers.space_area_access{})

    OnPurchasesChanged(Player:player, EntitlementChanges:[]entitlement_change(entitlement)):void =
        Print("OnPurchasesChanged fired with {EntitlementChanges.Length} changes")
        # Don't trust the change payload shape — just re-check what the player owns now.
        spawn{ CheckAndUnlockIfOwned(Player) }

    # If the player already owned the Moon Pass when they joined, drop the barrier.
    ValidatePreviousPurchases(Player:player)<suspends>:void =
        CheckAndUnlockIfOwned(Player)

    # Single source of truth: ask Marketplace what the player owns, unlock if Moon Pass is in the list.
    CheckAndUnlockIfOwned(Player:player)<suspends>:void =
        Purchases := GetPurchasedEntitlements(Player, Entitlements.feature_example_entitlement)
        Print("Player owns {Purchases.Length} feature entitlements")
        for (PurchaseTuple : Purchases):
            Ent := PurchaseTuple(0)
            if (MoonPass := Entitlements.space_area_access[Ent]):
                Print("Moon Pass found in owned entitlements — unlocking")
                UnlockMoonArea()

    # barrier_device.Disable() is global — one purchase unlocks for everyone.
    # For per-player gating, swap for mutator_zone_device or class_selector_device.
    UnlockMoonArea():void =
        MoonAreaBarrier.Disable()
        Print("Moon area barrier disabled")

    TryBuyOffer(Player:player, Offer:entitlement_offer)<suspends>:void =
        Result := BuyOffer(Player, Offer)
        if (Result?):
            Print("BuyOffer succeeded; OnPurchasesChanged will handle the unlock")
        else:
            Print("Failed to buy the offer")

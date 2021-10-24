# Field Survival Kits for XCOM 2

Grant your troops an additional single use each of a medkit, a flashbang and a smoke grenade during tactical battles, in addition to equipped items.

Also grants survival training, granting additional aim as well as a damage boost which increases per rank. This is only necessary for heavily modded late games, and can be disabled through the XComFieldSurvivalKits.ini config file.

Designed for XCOM 2: War of the Chosen and compatible with LWOTC.

## Rationale

Soldiers have very limited inventory space, especially before researching advanced armours. Deciding between flashbangs and frag/plasma grenades, special ammunition, extra body armour, skulljacks, mimic beacons, mindshields and other utility items is an interesting trade off.

Smoke grenades rarely make this list for consideration: they were bugged for much of XCOM 2's early play time, and later when fixed there are "more interesting" uses of an inventory slot. In Long War 2 they make a bit of a reappearance due to enemy accuracy and Not Created Equally, especially in the early game, but still they are competing with much more useful items in the majority of situations.

Medkits are a little unusual; many players rarely carry them at all. I find if I take the trouble to bring them I rarely use them and begrudge the inventory space, whereas if I don't bring them and do need them I regret it too late.

This mod obviates that choice by issuing every soldier with a free single use medkit and smoke grenade in addition to carried items. These free items only exist during missions, and are presumed to be drawn from XCOM's stores.

## Game Logic

More advanced smoke grenades (Long War 2) and nanomedkits (LW2 and vanilla) will automatically be carried instead where tech permits.

If you also bring a smoke grenade or medkit, the soldier will have two (or more) items: whatever they brought, plus their free allowance from this mod.

This mod works both with new games and existing saves (though won't take immediate effect on mid-mission saves; it'll work next mission). As with any mod, don't load and continue a game with this mod unless you intend to keep it! Especially Ironman, unless you have save backups. I'd recommend trying the mod out on a test game (or keeping your previous save) to see if you like it.

## Mod Design

This mod borrows and adapts X2Effect_TemporaryItem and XComGameState_Effect_TemporaryItem from Long War 2 / Long War Perk Pack for XCOM 2. Thanks to Amineri of Pavonis Interactive who wrote this original code. These classes apply a temporary effect (like a buff/debuff) to troops in game, which when it's applied grants the item / increases the existing item count, as appropriate. They also ensure (when properly configured) that requisite abilities are granted to the troops so they can use medkits and throw grenades. The game state for this effect makes sure the items are cleaned up at the end of each tactical mission.

Given that, this mod's original code simply involves overriding OnPostTemplatesCreated() to amend all soldier character templates to include two additional new abilities, FSKSmokeGrenade and FSKMedkit. These are new passive abilities which trigger Pavonis' temporary item effect when a tactical mission begins.

An early attempt at this mod used a different approach: rather than patching all soldier character templates, it used a UIScreenListener on the tactical HUD UI to apply the temporary item effect directly units on XCOM's team when tactical mission play began, skipping templates completely. This had (minor) pros and (mostly) cons. Restart Mission didn't work, as the tactical HUD UI is not recreated wihout an exit to the main menu, so mod init code did not run again. Behaviour was inconsistent: rarely on some missions, one soldier wouldn't be granted items, for reasons unknown. The mod could and would grant equipment to VIPs on evac missions by default, as they're on XCOM's team, which was rather nice but would still be possible by modifying their character templates if using the current approach instead. The lack of template use led to more initialization code plus nasty assertion log messages from the game, which expected effects to have templates. More X2Effect instances were also created than are strictly necessary, as really just one per template is required rather than one per tactical mission. Overall it was a bad plan, hence the current approach.

## Folder Structure

The mod's files and folders are organised as required by the XCOM 2 ModBuddy build process - which is very picky - not aesthetically.

## License

This mod doesn't really do anything which isn't heavily based on existing code from Firaxis and Pavonis. As far as the author is concerned, it's free for you to reuse, modify and distribute as you see fit.

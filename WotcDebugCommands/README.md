# Debug Commands

Adds additional debug commands to the game.

## NarrativeMoment(string Moment)

Plays a narrative moment by name. For example:

    > NarrativeMoment X2NarrativeMoments.S_Ambient_Burger_Contraband_Central

## FixDoom()

Fix unusual, unpleasant and broken Avatar Project "doom" states.

    > FixDoom

This applies all conceivable fixes to attempt to resuscitate the doom clock,
as follows.

- Mark everything about doom as known to the player
- Render the fortress (statue in the Pacific Ocean) visible
- Break out of "lose mode", wherein the game is about to end
- Remove any "permanent and irreversable" doom pips
- Reset the doom meter to at least two pips from the end
- Remove any pending doom not yet shown in the doom meter
- Reboot the generation of fortress doom
- Reboot the generation of facility doom, if there are any facilities
- Reboot the building of new facilities, if there are less than the maximum

In theory this should leave no odd doom states.

In particular it can fix issues caused by highlander mods (and dependent mods)
preventing critical narrative moments from appearing, such as the Avatar Project
reveal sequence.

# SLMC-Seeker-2020
Original Concept by Sin Straaf. This Git merely puts his idea into action.

The purpose of this git is to provide examples of the ways to implement improved behaviour for tracking munitions and launchers in order to make them compliant with regions that may be looking at supporting them.

A quick run-down:

- All rockets have LBA descriptions. Ending with the CSV of "SKR", which stands for "SeeKing Rocket". This way we're not sending messages to every LBA object in the detection radius of a flare, smoke, or other intercepting device.

- Dealing 0 damage will cause the rocket to track the source.

- Dealing negative damage (healing) will cause the rocket to break lock-on, sending it down it's last trajectory or towards the last recorded position of their target.

- Dealing positive LBA (actual damage) destroys the rocket.

- Launchers should raycast for phantom objects with "smoke" in their name. If such an object is detected, this should prevent the launcher from locking onto objects either within or behind the smoke. This is how IR Smoke works.

- Aircraft should have a CSV description ending in "AIR", tanks or other ground vehicles should use "VEH". This is so rockets won't target emplacements and so things like AA can discriminate between vehicle types.

Keep in mind these are not regulations but how the system is intended to function on the most basic level. There may very well other requirements put in place by others on a group-by-group basis (sounds, limiting what can redirect, etc).

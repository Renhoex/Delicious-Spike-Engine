# Delicious-Spike-Engine
A public open source clone of I wanna be the guy fangame recreated in godot to help aid new developers get an understanding of godot

This was created with Godot 4.1.2 which can be aquired at https://godotengine.org/
for godot 3 see the branch archive see https://github.com/Renhoex/Delicious-Spike-Engine/tree/Godot-3-Archive

# Change-log
# 1.0
- initial release

# 1.1
- Cleaned the code to remove errors from the debugger such as unused variables and unfinished threads
- Moving platforms are more accurate
- Better blood physics
- Death button has been added
- A Reverse Gravity group has been added for platforms that work in anti gravity
- Ignore blood group has been added for solids that should not interact with blood particles (such as moving platforms)
- Play from scene now works in scenes with the room initializer script (you can reload but you can't reset the game, a seperate file is used for testing)
- Progress tracking is built into the saves
- Progress icons have been added to the file select
- Progress orbs have been added as an item
- Added Time and Death counters as an in game overlay or as a window caption
- Updated the timer to show milliseconds
- Options menu has been added
- Volume and Sound controls have been added
- Customizable key and button bindings
- Auto key and game pad rebinding is now supported
- Fixed the death sound player not using a bus sound channel
- Recoded the way time is saved to prevent time reseting and not reseting on new files
- Game configuration file now uses the GameConfiguration class

# 2.0
- removed semicolons from scripts
- rewrote the platforms to take advantage of animated static bodies
- rewrote movements to work better with Godots new physics
- moved process code to physics code to keep gameplay consistent
- fixed up and converted all code to work with godot 4.1

# Read the Delicious Spike Engine Guide for more information

![Screenshot-2](https://github.com/user-attachments/assets/2ef50935-acce-42c7-aecb-4d082f0b13f3)
![Screenshot-1](https://github.com/user-attachments/assets/83f912da-6779-4aae-934e-c09a3f574696)

### How to build
- I built this project using Xcode Version 16.0 (16A242) and tested it on macOS 15.1 Beta (24B5035e). 
- If you have any issues, feel free to contact me.
- 
### Features
- Game logic for arbitrary sizes and guess counts.
- Autocompletion for equation input. It suggests the part after "=" sign. Try it out, it is pretty cool little feature!
	- To accept the completion, press return key. To submit the guess, press it again.
- Navigation using keyboard arrows
	- Left/right to move cursor.
	- Up to substitute last guess, proved to be useful.
	- Down to clear current guess.
	- Navigation logic is similar to the original game, with some QoL tweaks.
- Keyboard input as well as on-screen keyboard.
	- Unfortunately, first responder is sometimes lost due to SwiftUI bug, you can re-enable keyboard input by clicking on the game field.
- Three difficulty levels. 
	- Use gear button to change. Will only affect new practice games.
- Daily and Practice modes. Daily mode is guaranteed to be equal for all players. 
	- Calendar button on toolbar loads daily mode.
	- Plus button loads practice mode (usable only on finished games).
- History persistence into sqlite database. Ability to load and view played games. Stats display.
- Ability to share game results using system share sheet.
- State restoration after application termination. It will restore your game, if you had any guesses in it.
- Slick UI, with some small animations here and there.
- Ability to create custom game from the equation in **pasteboard**. Use Command+N or click on menu item under File menu.
### Implementation details
- Equations are parsed and validated using simple recursive descent parser.
- Generation of random equations works by constructing random left hand parts as strings and repeating this process until the correct sized option will be found.
- Persistence is implemented using GRDB, my favourite SQLite library out there. This is the single one external dependency out there.
	- Please don't ask me about CoreData/SwiftData. They are garbage =)
- UI is implemented in SwiftUI, using AppKit in tight places and to manage the application lifecycle. SwiftUI Previews are used here and there for quick iterations.
- The project is divided into host application xcodeproj and NerdleKit framework package.
- NerdleKit coverage with tests is about 95%. Tested code includes
	- Expression parsing/validating. 
	- Game logic for coloring different symbols on field.
	- Game state logic and termination conditions. 
	- Input logic and cursor management. 
	- Persistence tests with in-memory SQLite DB. 
- For host application, mainly MVVM-like solution is used. `GameViewModel` is pretty big, that is a good place for refactoring, probably. Some of its logic may be tested as well.

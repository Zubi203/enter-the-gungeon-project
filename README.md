# Untitled Gun Game
### The Game
(namehere) is a top down shooter and dungeon crawler with roguelike elements. The game features twin-stick shooter gameplay, bullet hell combat, and procedurally generated levels. This project was made for my portfolio with the goal to learn, study, and recreate the mechanics of games like Enter the Gungeon and Nuclear Throne while also showcasing my proficiency in performance optimization systems like object pooling.

### Project Features
- A complex and customizable system for creating bullet patterns implemented using Composition, Resource-Driven Design, and the Strategy Pattern. This can be reused to create new gun types for the player and new bullet patterns for the enemies.
- Object pooling system to allow the game to handle spawning large amounts of bullets and particle effects.
- Procedural generation algorithm that randomly generates rooms using pre-defined templates and connects them together with corridors. The algorithm generates a node graph to represent the logical structure of the dungeon and uses it as a guide to spawn in the room templates and corridors.
- An Audio Player Pooling System that reuses existing audio stream players if they are available and creates new ones dynamically when needed.
- A service locator is used to decouple game systems by allowing different scripts to access the object pooling and audio pooling services from any part of the game without requiring a direct reference.
- Particles, screen shake, lighting, and meaty sound effects have been used to add satisfying game feel and juice.
- 8 different enemy types, 2 bosses.
- Full control remapping is available.
- State machine based UI architecture for menu screens.
- Input buffers to make controls feel responsive and clean.

### Engine
- This project was made in the Godot Engine.
- The code base for this project is written almost entirely in GDScript.

### How to Play
- If you're interested in playing the full game, it can be played in browser on itch.io: (project not yet uploaded).
- If you're interested in running the project on the Godot Engine, simply download the project files from this repository and import them into the engine.
- The code base for this project is fully commented and uses easy-to-understand variable, method, and class names.

### Credits
- All the code for this project was done by me.
- (Asset credits will be added when the project is completed and uploaded to itch.io)

### Contact
- Discord: @zubi_dev
- Work email: zubairhittam@gmail.com

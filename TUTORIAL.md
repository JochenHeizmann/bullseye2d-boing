---
marp: true
theme: default
class: lead
paginate: true
backgroundColor: #fff
backgroundImage: url('https://marp.app/assets/hero-background.svg')
size: 16:9
auto-scaling: true
style: |
  .columns {
    display: grid;
    grid-template-columns: repeat(2, minmax(0, 1fr));
    gap: 1rem;
  }
  code {
    font-size: 0.75em;
    line-height: 1.2;
  }
  pre {
    font-size: 0.7em;
    line-height: 1.1;
  }
  section {
    font-size: 28px;
  }
  section.small {
    font-size: 24px;
  }
  h1 { font-size: 2.5em; }
  h2 { font-size: 2em; }
  h3 { font-size: 1.5em; }
  ul, ol { font-size: 0.9em; }
---

# Building a Pong Clone 🏓

**Step-by-Step with Dart & Bullseye2D**

*From Empty App to Complete Game*

---

## What We'll Build Together

Let's create a **game**:

1. 🔴 **Setting up app** - Basic working app
2. 🎮 **Menu System** - Game states and navigation  
3. 🏓 **Moving Paddles** - Player controls
4. ⚪ **Bouncing Ball** - Physics and collision
5. 💥 **Impact Effects** - Visual feedback
6. 🏆 **Scoring System** - Game over logic
7. 🔊 **Sound Effects** - Audio integration
8. ✨ **Final Polish** - Complete game

---
## Disclaimer

**Boing**
- The original game was created by Eben Upton for the Book [Code the Classics](https://github.com/Wireframe-Magazine/Code-the-Classics/tree/master/boing-master) in Python.
- I converted it to Dart using my game library [Bullseye2D](https://bullseye2d.org/)

---

## Prerequisites & Setup

**What You Need:**
- Basic Dart knowledge
- Understanding of game loops
- Text editor and terminal

**Let's Install Everything:**
```bash
# 1. Install Dart SDK from https://dart.dev/get-dart

# 2. Activate required tools
dart pub global activate webdev
dart pub global activate bullseye2d
```

---

# Step 1: Create new project

Let's use the Bullseye2D CLIE to create a new project:

```bash
# Create new Bullseye2D project
bullseye2d create boing_game
cd boing_game

# Start the development server
webdev serve --auto refresh
```

**Result:** Open http://localhost:8080 to see your basic app.

---

## Let's get started

Replace all content in `web/main.dart` with:

```dart
import 'package:bullseye2d/bullseye2d.dart';

class BoingApp extends App {
  BoingApp() {
    canvas.width = 800;
    canvas.height = 480;
  }

  @override
  void onRender() {
    gfx.clear(1.0, 0.0, 0.0);
  }
}

void main() {
  BoingApp();
}
```

---

## 🎉 Hooray!

```bash
webdev serve --auto refresh
```

**Expected Result:**
- Browser shows a beautiful **red rectangle**
- This proves your Bullseye2D app is working!

**What We Did:**
- Created `BoingApp` class extending Bullseye2D's `App`
- Set canvas size to our game dimensions
- Used `gfx.clear(1, 0, 0)` to fill screen with red
- `main()` function creates and starts the app

---

# Step 2: Add Game Configuration

```dart
import 'package:bullseye2d/bullseye2d.dart';

// Game configuration constants
class GameConfig {
  static const double width = 800;
  static const double height = 480;
  static const double halfWidth = width / 2;
  static const double halfHeight = height / 2;
}

// Possible game states
enum GameState { menu, play, gameOver }

// Global app reference for easy access
late BoingApp app;
```

---

## Update BoingApp with State

We render different things depending on the game state.

```dart
class BoingApp extends App {
  GameState state = GameState.menu;
  
  BoingApp() {
    canvas.width = GameConfig.width.toInt();
    canvas.height = GameConfig.height.toInt();
  }

  @override
  void onCreate() {
    app = this; // Set global reference, for easier access later on
  }

```
---
```dart
  @override
  void onRender() {
    if (state == GameState.menu) {
      gfx.clear(0, 0.5, 1.0); // Blue for menu
    } else if (state == GameState.play) {
      gfx.clear(0, 0.8, 0);   // Green for play
    } else {
      gfx.clear(0.9, 0, 0);   // Red for game over
    }
  }
}
```

---

## 🎉 Red pill or blue pill?

```bash
webdev serve --auto refresh
```

**Expected Result:**
- Screen is now **blue** (menu state)

**What We Added:**
- Game constants in `GameConfig` class
- `GameState` enum for different screens
- State-based rendering (different colors per state)
- Global `app` variable for easy access throughout code

---

# Step 3: Download Assets

Before continuing, download the game assets:

**🔗 Download:** https://bullseye2d.org/downloads/boing-assets.zip

**Extract to your project:**
```bash
curl -O https://bullseye2d.org/downloads/boing-assets.zip
unzip -o boing-assets.zip
cp -r boing-assets/* ./web/
rm -r boing-assets boing-assets.zip
```

**Your project should now have:**
- `web/images/` - 30+ image files
- `web/sounds/` - 15+ sound files
- `web/music/` - Background music

---

## Add Asset Loading

Lets load some images:

```dart
class BoingApp extends App {
  GameState state = GameState.menu;
  Map<String, Images> assets = {};
  int numPlayers = 1;

  ...

  @override
  void onCreate() {
    app = this;
    loadAssets();
  }

  void loadAssets() {
    // Load menu images
    assets["menu0"] = resources.loadImage("images/menu0.png", pivotX: 0.0, pivotY: 0.0);
    assets["menu1"] = resources.loadImage("images/menu1.png", pivotX: 0.0, pivotY: 0.0);
    assets["table"] = resources.loadImage("images/table.png", pivotX: 0.0, pivotY: 0.0);
  }
}
```

---

Next, we Update the `BoingApp` class methods to handle the menu logic:

```dart
@override
void onUpdate() {
  // Check for Up/Down arrows in menu
  if (state == GameState.menu) {
    if (keyboard.keyHit(KeyCodes.Up)) {
      numPlayers = 1;
    } else if (keyboard.keyHit(KeyCodes.Down)) {
      numPlayers = 2;
    } else if (keyboard.keyHit(KeyCodes.Space)) {
      state = GameState.play;
    }
  }
}

```

---

```dart
@override
void onRender() {
  gfx.clear(0, 0, 0); // Black background
  
  if (state == GameState.menu) {
    // Draw table background
    gfx.drawImage(assets["table"]!, 0, 0, 0);
    // Draw menu overlay (1 or 2 player selection)
    String menuImage = "menu${numPlayers - 1}";
    gfx.drawImage(assets[menuImage]!, 0, 0, 0);
  } else ...
}
```

---

## 🎉 Test the menu!

```bash
webdev serve --auto refresh
```

**Expected Result:**
- See menu
- **Up/Down arrows** change between "1 PLAYER" and "2 PLAYERS"
- **Spacebar** switches to green screen (play state)

**What We Added:**
- Keyboard input handling
- Menu navigation with visual feedback
- State transitions between menu and play

---

# Step 4: Add Moving Paddles

Let's create a new `Actor` class:
- Base class for all game objects (paddles, ball, effects)
- `draw()` method renders the object
- `update()` method for movement/logic (override in subclasses)

```dart
class Actor {
  double x, y;
  String image;

  Actor(this.image, this.x, this.y);

  void draw() => gfx.drawImage(app.assets[image]!, 0, x, y);
  void update() {}
}
```

---

Now we create the new Bat class that represents a paddle. `moveFunc` Function pointer will later get the logic for either player input or AI behaviour.

```dart
class Bat extends Actor {
  int player;
  double Function() moveFunc;

  Bat(this.player, double Function()? moveFunc)
    : moveFunc = moveFunc ?? (() => 0.0),
      super("bat${player}0", player == 0 ? 40 : 760, GameConfig.halfHeight);

  @override
  void update() {
    double yMovement = moveFunc();
    y = (y + yMovement).clamp(80.0, 400.0);
  }
}
```

---

## Bat Features:
- `player` - 0 (left) or 1 (right)
- `moveFunc` - function that returns movement speed
- Positioned at left (x=40) or right (x=760) side
- `clamp()` keeps paddle on screen (y between 80-400)

---

## Add Player Control Functions

Add to `BoingApp` class:

```dart
double p1Controls() =>
    keyboard.keyDown(KeyCodes.Z) || keyboard.keyDown(KeyCodes.Down)
        ? 6.0  // Move down
        : keyboard.keyDown(KeyCodes.A) || keyboard.keyDown(KeyCodes.Up)
        ? -6.0 // Move up
        : 0.0; // No movement

double p2Controls() =>
    keyboard.keyDown(KeyCodes.M)
        ? 6.0  // Move down
        : keyboard.keyDown(KeyCodes.K)
        ? -6.0 // Move up
        : 0.0; // No movement
```
---

## Controls:
- **Player 1:** Z/Down (down), A/Up (up)
- **Player 2:** M (down), K (up)
- Returns movement speed per frame

---

## Add Game Class and Paddles

Add after `Bat` class:

```dart
class Game {
  late List<Bat> bats;

  Game(List<double Function()?> controls) {
    bats = [
      Bat(0, controls[0]), // Left paddle
      Bat(1, controls[1])  // Right paddle
    ];
  }

  void update() {
    for (var bat in bats) {
      bat.update();
    }
  }

```

---
```dart
  void draw() {
    gfx.drawImage(app.game.assets["table"]!, 0, 0, 0);
    for (var bat in bats) {
      bat.draw();
    }
  }
}
```

---

## Load Paddle Assets

Update `loadAssets()` method to load the bat images:

```dart
void loadAssets() {
  assets["menu0"] = resources.loadImage("images/menu0.png");
  assets["menu1"] = resources.loadImage("images/menu1.png");
  assets["table"] = resources.loadImage("images/table.png");
  
  // Load paddle images with center pivot
  assets["bat00"] = resources.loadImage("images/bat00.png", pivotX: 0.5, pivotY: 0.5);
  assets["bat10"] = resources.loadImage("images/bat10.png", pivotX: 0.5, pivotY: 0.5);
}
```

Add `Game` reference to `BoingApp` class:

```dart
class BoingApp extends App {
  GameState state = GameState.menu;
  Map<String, Images> assets = {};
  int numPlayers = 1;
  late Game game;
```

---

## Update Game Loop for Paddles

Update `onUpdate()` method:

```dart
@override
void onUpdate() {
  if (state == GameState.menu) {
    if (keyboard.keyHit(KeyCodes.Up)) {
      numPlayers = 1;
    } else if (keyboard.keyHit(KeyCodes.Down)) {
      numPlayers = 2;
    } else if (keyboard.keyHit(KeyCodes.Space)) {
      state = GameState.play;
      // Create game with controls
      List<double Function()?> controls = [p1Controls];
      controls.add(numPlayers == 2 ? p2Controls : null);
      game = Game(controls, this);
    }
  } else if (state == GameState.play) {
    game.update();
  }
}
```

---

## Update Rendering for Paddles

Update `onRender()` method:

```dart
@override
void onRender() {
  gfx.clear(0, 0, 0);
  
  if (state == GameState.menu) {
    gfx.drawImage(assets["table"]!, 0, 0, 0);
    String menuImage = "menu${numPlayers - 1}";
    gfx.drawImage(assets[menuImage]!, 0, 0, 0);
  } else if (state == GameState.play) {
    game.draw(); // replace green screen with rendering the game
  }
}
```

---

## 🎉 The paddles are now moving!

**Expected Result:**
- Press **Spacebar** to start game
- **Player 1/2** Controls
- Paddles stay within screen bounds

**What We Added:**
- Actor system for game objects
- Bat class with movement logic
- Player control functions
- Game coordination class
- Asset loading for paddle graphics

---

# Step 5: Add the Bouncing Ball

The game would benefit from a Ball, so let's create one:

```dart
class Ball extends Actor {
  double dx, dy;  // Direction and speed
  int speed = 5;  // Pixels per frame

  Ball(this.dx) : dy = 0, super("ball", GameConfig.halfWidth, GameConfig.halfHeight);

  bool get out => x < 0 || x > GameConfig.width;

  @override
  void update() {
    // Move ball multiple times per frame for smooth high-speed movement
    for (int i = 0; i < speed; i++) {
      x += dx;
      y += dy;
      
```
---

```dart
      // Bounce off top and bottom walls
      if ((y - GameConfig.halfHeight).abs() > 220) {
        dy = -dy;
        y += dy; // Adjust position after bounce
      }
    }
  }
}
```

**Ball Features:**
- Starts at screen center
- `dx, dy` control direction (-1 to 1 range)
- `speed` determines how fast it moves
- `out` property checks if ball left screen
- Bounces off top/bottom walls

---

## Load Ball Asset and Add to Game

Let's load the ball sprite:

```dart
void loadAssets() {
  assets["menu0"] = resources.loadImage("images/menu0.png");
  assets["menu1"] = resources.loadImage("images/menu1.png");
  assets["table"] = resources.loadImage("images/table.png");
  assets["bat00"] = resources.loadImage("images/bat00.png", pivotX: 0.5, pivotY: 0.5);
  assets["bat10"] = resources.loadImage("images/bat10.png", pivotX: 0.5, pivotY: 0.5);
  
  // Load ball with center pivot
  assets["ball"] = resources.loadImage("images/ball.png", pivotX: 0.5, pivotY: 0.5);
}
```

---

## Update Game Class for Ball

We will now add the Ball to the `Game` class:

```dart
class Game {
  late List<Bat> bats;
  late Ball ball;

  Game(List<double Function()?> controls) {
    bats = [
      Bat(0, controls[0]),
      Bat(1, controls[1])
    ];
    ball = Ball(-1); // Ball starts moving left
  }

  void update() {
    for (var bat in bats) {
      bat.update();
    }
    ball.update();
  }

```
---

We need to draw the ball:

```dart
  void draw() {
    app.assets["table"]!.draw(0, 0);
    for (var bat in bats) {
      bat.draw();
    }
    ball.draw();
  }
}
```

---

## 🎉 Almost a game!

```bash
webdev serve --auto refresh
```

**Expected Result:**
- Menu and paddles work as before
- **White ball** appears and moves across screen
- Ball goes off left/right edges (we'll fix this next)

**What We Added:**
- Ball class with physics movement
- Wall collision detection
- Multi-step movement for smooth high-speed ball
- Ball integrated into game loop

---

# Step 6: Add Paddle-Ball Collision

Update the `Ball.update()` method:

```dart
@override
void update() {
  for (int i = 0; i < speed; i++) {
    double originalX = x;
    x += dx;
    y += dy;
    
    // Check for paddle collision
    if ((x - GameConfig.halfWidth).abs() >= 344 && (originalX - GameConfig.halfWidth).abs() < 344) {
      
      Bat bat;
      if (x < GameConfig.halfWidth) {
        bat = app.game.bats[0]; // Left paddle
      } else {
        bat = app.game.bats[1]; // Right paddle  
      }
      
      double differenceY = y - bat.y;
      
```
---
```dart
      // Hit paddle if ball is within paddle height
      if (differenceY > -64 && differenceY < 64) {
        dx = -dx; // Reverse horizontal direction
        dy += differenceY / 128; // Add spin based on hit position
        dy = dy.clamp(-1.0, 1.0); // Keep reasonable speed
        speed++; // Increase speed each hit
      }
    }
    
    // Wall collision (same as before)
    if ((y - GameConfig.halfHeight).abs() > 220) {
      dy = -dy;
      y += dy;
    }
  }
}
```

---

## 🎉 Paddle Collisions working!

```bash
webdev serve --auto refresh
```

**Expected Result:**
- Ball now **bounces off paddles**!
- Hit position affects ball angle (top = upward, bottom = downward)
- Ball **speeds up** with each paddle hit

**What We Added:**
- Collision detection between ball and paddles
- Spin effect based on where ball hits paddle
- Progressive speed increase
- Proper ball physics with direction changes

---

# Step 7: Add Scoring System

Update `Game` class to handle scoring:

```dart
class Game {
  late List<Bat> bats;
  late Ball ball;

  Game(List<double Function()?> controls) {
    bats = [
      Bat(0, controls[0]),
      Bat(1, controls[1])
    ];
    ball = Ball(-1);
  }

```
---
```dart
  void update() {
    for (var bat in bats) {
      bat.update();
    }
    ball.update();
    
    // Check if ball went off screen
    if (ball.out) {
      if (ball.x < GameConfig.width / 2) {
        bats[1].score++; // Right player scores
      } else {
        bats[0].score++; // Left player scores  
      }
      
      // Reset ball towards the player who was scored on
      int direction = (ball.x < GameConfig.width / 2) ? -1 : 1;
      ball = Ball(direction.toDouble());
    }
  }
  
}
```

---

## Add Score to Bat Class

Update `Bat` class:

```dart
class Bat extends Actor {
  int player;
  int score = 0; // Add this line
  double Function() moveFunc;

  Bat(this.player, double Function()? moveFunc)
    : moveFunc = moveFunc ?? (() => 0.0),
      super("bat${player}0", player == 0 ? 40 : 760, GameConfig.halfHeight);

  @override
  void update() {
    double yMovement = moveFunc();
    y = (y + yMovement).clamp(80.0, 400.0);
  }
}
```

---

## Load Score Display Assets

Update `loadAssets()` method:

```dart
void loadAssets() {
  assets["menu0"] = resources.loadImage("images/menu0.png", pivotX: 0.0, pivotY: 0.0);
  assets["menu1"] = resources.loadImage("images/menu1.png", pivotX: 0.0, pivotY: 0.0);
  assets["table"] = resources.loadImage("images/table.png", pivotX: 0.0, pivotY: 0.0);
  assets["bat00"] = resources.loadImage("images/bat00.png");
  assets["bat10"] = resources.loadImage("images/bat10.png");
  assets["ball"] = resources.loadImage("images/ball.png");
  
  // Load digit sprites for score display
  for (int i = 0; i <= 9; i++) {
    assets["digit0$i"] = resources.loadImage("images/digit0$i.png");
  }
}
```

---

## Add Score Display to Game

Update `Game.draw()` method:

```dart
void draw() {
  gfx.drawImage(app.assets["table"]!, 0, 0, 0);
  
  for (var bat in bats) {
    bat.draw();
  }
  ball.draw();
  
  // Draw scores
  for (int p = 0; p < 2; p++) {
    String score = bats[p].score.toString().padLeft(2, '0');
    for (int i = 0; i < 2; i++) {
      String imageName = "digit0${score[i]}";
      double drawX = 255.0 + (160 * p) + (i * 55);
      double drawY = 83.0;
      gfx.drawImage(app.assets[imageName]!, 0, drawX, drawY);
    }
  }
}
```

---

## Add Game Over Logic

Update `BoingApp.onUpdate()` method:

```dart
@override
void onUpdate() {
  if (state == GameState.menu) {
    if (keyboard.keyHit(KeyCodes.Up)) {
      numPlayers = 1;
    } else if (keyboard.keyHit(KeyCodes.Down)) {
      numPlayers = 2;
    } else if (keyboard.keyHit(KeyCodes.Space)) {
      state = GameState.play;
      List<double Function()?> controls = [p1Controls];
      controls.add(numPlayers == 2 ? p2Controls : null);
      game = Game(controls, this);
    }
```
---
```dart
  } else if (state == GameState.play) {
    game.update();
    
    // Check for game over (first to 10 wins)
    if (game.bats[0].score >= 10 || game.bats[1].score >= 10) {
      state = GameState.gameOver;
    }
  } else if (state == GameState.gameOver) {
    if (keyboard.keyHit(KeyCodes.Space)) {
      state = GameState.menu;
      numPlayers = 1;
    }
  }
}
```

---

## Add Game Over Screen

Load game over asset in `loadAssets()`, and update `onRender()`:

```dart
assets["over"] = resources.loadImage("images/over.png", pivotX: 0.0, pivotY: 0.0);

...

@override
void onRender() {
  gfx.clear(0, 0, 0);
  
  if (state == GameState.menu) {
    gfx.drawImage(assets["table"]!, 0, 0, 0);
    String menuImage = "menu${numPlayers - 1}";
    gfx.drawImage(assets[menuImage]!, 0, 0, 0);
  } else if (state == GameState.play) {
    game.draw();
  } else if (state == GameState.gameOver) {
    game.draw(); // Show final scores
    gfx.drawImage(assets["over"]!, 0, 0, 0);
  }
}
```

---

## 🎉 We call it a game now!

```bash
webdev serve --auto refresh
```

**Expected Result:**
- **Scores appear** at top of screen (00 vs 00)
- When ball goes off screen, **opponent scores**
- Ball **resets toward scored-on player**
- **First to 10 points wins**
- Game over screen appears with **"Space to continue"**
- Press Space to return to menu

---

**What We Added:**
- Scoring system with visual display
- Ball reset after goals
- Game over detection (first to 10)
- Complete game flow: menu → play → game over → menu

---

# Step 8: Add AI Opponent

We now update the `Bat` class to support AI behaviour:

```dart
class Bat extends Actor {
  int player;
  int score = 0;
  double Function() moveFunc;

  Bat(this.player, double Function()? moveFunc)
    : moveFunc = moveFunc ?? (() => 0.0),
      super("bat${player}0", player == 0 ? 40 : 760, GameConfig.halfHeight) {
    this.moveFunc = moveFunc ?? ai; // Use AI if no control function provided
  }

  @override
  void update() {
    double yMovement = moveFunc();
    y = (y + yMovement).clamp(80.0, 400.0);
  }
```
---
```dart

  // AI logic - smart but not perfect
  double ai() {
    double xDistance = (app.game.ball.x - x).abs();
    double targetY1 = GameConfig.halfHeight; // Center position
    double targetY2 = app.game.ball.y;       // Ball position
    
    // Mix between center and ball tracking based on distance
    double weight1 = (xDistance / GameConfig.halfWidth).clamp(0.0, 1.0);
    double weight2 = 1 - weight1;
    double targetY = (weight1 * targetY1) + (weight2 * targetY2);
    
    return (targetY - y).clamp(-6.0, 6.0); // Max AI speed = 6
  }
}
```

---

## Add AI Offset for Imperfection

Add to `Game` class:

```dart
// Add import at the top of file
import 'dart:math';

class Game {
  late List<Bat> bats;
  late Ball ball;
  double aiOffset = 0; // Random offset to make AI less perfect

  // Constructor and methods stay the same...
}
```

Update `Ball.update()` paddle collision section:

```dart
// In the paddle collision section, after speed++:
speed++;
app.game.aiOffset = (Random().nextInt(21) - 10).toDouble(); // -10 to +10
```


---

## Update AI Target Calculation

Update the `ai()` method in `Bat` class:

```dart
double ai() {
  double xDistance = (app.game.ball.x - x).abs();
  double targetY1 = GameConfig.halfHeight;
  double targetY2 = app.game.ball.y + app.game.aiOffset; // Add random offset
  
  double weight1 = (xDistance / GameConfig.halfWidth).clamp(0.0, 1.0);
  double weight2 = 1 - weight1;
  double targetY = (weight1 * targetY1) + (weight2 * targetY2);
  
  return (targetY - y).clamp(-6.0, 6.0);
}
```

---

## 🎉 Did we just create SkyNet?

```bash
webdev serve --auto refresh
```

**Expected Result:**
- In **1-player mode**, right paddle moves automatically
- AI **tracks the ball** but isn't perfect
- You can play against the computer!

**What We Added:**
- Intelligent AI that balances challenge and playability
- Random imperfection to make AI beatable
- Automatic opponent for single-player mode

---

# Step 9: Visual Effects 

Let's create some impact effects, to make the player really feel the game.

- A sort animation when ball hits something
- 5 frames: impact0, impact1, impact2, impact3, impact4
- Each frame shows image for 2 game ticks
- Total duration: 10 ticks

---

Add after `Ball` class:

```dart
class Impact extends Actor {
  int time = 0;

  Impact(double x, double y) : super("impact0", x, y);

  @override
  void update() {
    image = "impact${time ~/ 2}"; // Change frame every 2 updates
    time++;
  }
}
```

---

## Load Impact Assets

Update `loadAssets()` method:

```dart
void loadAssets() {
  // ... existing assets ...
  
  // Load impact animation frames
  for (int i = 0; i <= 4; i++) {
    assets["impact$i"] = resources.loadImage("images/impact$i.png");
  }

  // Load blank image for initial state
  assets["blank"] = resources.loadImage("images/blank.png", pivotX: 0.0, pivotY: 0.0);
}
```

---

## Add Impacts to the game

Update `Game` class:

```dart
class Game {
  late List<Bat> bats;
  late Ball ball;
  List<Impact> impacts = []; // Add this line
  double aiOffset = 0;
  ...
  void update() {
    for (var bat in bats) {
      bat.update();
    }
    ball.update();
    
    // Update impacts and remove finished ones
    for (var impact in impacts) {
      impact.update();
    }
    impacts.removeWhere((impact) => impact.time >= 10);
    
    // Scoring logic stays the same...
  }
```
---

We also need to render the impacts:

```dart
  void draw() {
    gfx.drawImage(app.assets["table"]!, 0, 0, 0);
    
    for (var bat in bats) {
      bat.draw();
    }
    ball.draw();
    
    // Draw impacts
    for (var impact in impacts) {
      impact.draw();
    }
    
    // Score display stays the same...
  }
}
```

---

## Add Impact Creation in Ball Collisions

When a collision occurs, we need to create a new impact fx in `Ball.update()` method:

```dart
// In paddle collision section, after reversing dx:
dx = -dx;
dy += differenceY / 128;
dy = dy.clamp(-1.0, 1.0);

// Add impact effect at collision point
int newDirX = x < GameConfig.halfWidth ? 1 : -1;
app.game.impacts.add(Impact(x - newDirX * 10, y));

speed++;
// ... rest of collision code
```

```dart
// In wall collision section, after reversing dy:
dy = -dy;
y += dy;

// Add impact effect at wall collision
app.game.impacts.add(Impact(x, y));
```

---

## Paddle Visual Feedback

When the paddle hits the ball, we also want to add some nice visual feedback.

We will use a similiar method as for the impacts, by dynamically altering the image key.

---

```dart
class Bat extends Actor {
  int player;
  int score = 0;
  int timer = 0; // Add this line
  double Function() moveFunc;
  ...
  @override
  void update() {
    timer--; // Countdown timer
    
    double yMovement = moveFunc();
    y = (y + yMovement).clamp(80.0, 400.0);
    
    // Update image based on state
    int frame = 0;
    if (timer > 0) {
      frame = 1; // Hit animation frame
    }
    image = "bat$player$frame";
  }
  
  // ai() method stays the same...
}
```

---

We also need to load the additional bat frames, so we need to update the `loadAssets()` method:

```dart
// Load all bat animation frames
assets["bat00"] = resources.loadImage("images/bat00.png");
assets["bat01"] = resources.loadImage("images/bat01.png");
assets["bat10"] = resources.loadImage("images/bat10.png");
assets["bat11"] = resources.loadImage("images/bat11.png");
```

In `Ball.update()` paddle collision, we need to start the bat animation:

```dart
// After creating impact effect:
app.game.impacts.add(Impact(x - newDirX * 10, y));
speed++;
app.game.aiOffset = (Random().nextInt(21) - 10).toDouble();
bat.timer = 10; // Trigger paddle hit animation
```

---

## 🎉 Testing time!

```bash
webdev serve --auto refresh
```

**Expected Result:**
- **Sparkle effects** appear when ball hits paddles or walls
- **Paddles flash** briefly when hit by ball
- Impact effects **animate and disappear**

**What We Added:**
- Impact animation system with 5-frame effects
- Paddle hit feedback with visual state changes
- Effect management (creation, update, cleanup)
- Polished visual feedback for all collisions

---

# Step 10: Add Sound Effects

Add to `BoingApp` class:

```dart
class BoingApp extends App {
  GameState state = GameState.menu;
  Map<String, Images> assets = {};
  Map<String, Sound> sounds = {}; // Add this line
  int numPlayers = 1;
  late Game game;
}
```
---

## Load Sound Assets

Add sound loading to `loadAssets()` method:

```dart
void loadAssets() {
  // ... existing image assets ...
  
  // Load sound effects
  Map<String, int> soundMap = {
    "hit": 5,
    "bounce": 5,
    "hit_slow": 1,
    "hit_medium": 1,
    "hit_fast": 1,
    "hit_veryfast": 1,
    "bounce_synth": 1,
    "score_goal": 1,
    "up": 1,
    "down": 1
  };
 ```
 ---
```dart
  soundMap.forEach((name, count) {
    for (int i = 0; i < count; i++) {
      sounds["$name$i"] = resources.loadSound("sounds/$name$i.ogg");
    }
  });
}
```

---

## Add Sound Storage and Music

Add to `BoingApp` class:

```dart
  @override
  void onCreate() {
    app = this;
    loadAssets();
    
    // Start background music
    audio.playMusic("music/theme.ogg", true); // Loop = true
    audio.musicVolume = 0.3; // 30% volume
  }
}
```

---

## Add Sound Playing Method to Game

Add to `Game` class:

```dart
static playSound(String name, {int count = 1, bool menuSound = false}) {
  // In attraction mode (demo), only play menu sounds
  if (!isAttractionMode || menuSound) {
    String soundName = "$name${count > 1 ? Random().nextInt(count) : 0}";
    audio.playSound(app.sounds[soundName]!);
  }
}

bool get isAttractionMode => bats[0].moveFunc == bats[0].ai;
```

**Sound System:**
- `playSound()` plays random variant when count > 1
- `isAttractionMode` checks if both players are AI (demo mode)
- Menu sounds always play, game sounds only during actual play

---

## Add Sound Effects to Collisions

Update `Ball.update()` method to add sounds:

```dart
// In paddle collision section, after creating impact:
app.game.impacts.add(Impact(x - newDirX * 10, y));
speed++;
app.game.aiOffset = (Random().nextInt(21) - 10).toDouble();
bat.timer = 10;

// Add sound effects based on ball speed
app.game.playSound("hit", count: 5); // Random hit sound
if (speed <= 10) {
  app.game.playSound("hit_slow");
} else if (speed <= 12) {
  app.game.playSound("hit_medium");
} else if (speed <= 16) {
  app.game.playSound("hit_fast");
} else {
  app.game.playSound("hit_veryfast");
}
```
---
```dart
// In wall collision section:
app.game.impacts.add(Impact(x, y));
app.game.playSound("bounce", count: 5);
app.game.playSound("bounce_synth");
```

---

## Add Menu and Scoring Sounds

Update `BoingApp.onUpdate()` for menu sounds:

```dart
if (keyboard.keyHit(KeyCodes.Up)) {
  numPlayers = 1;
  game.playSound("up", menuSound: true);
} else if (keyboard.keyHit(KeyCodes.Down)) {
  numPlayers = 2;
  game.playSound("down", menuSound: true);
... 
```
---
## Update `Game.update()` for scoring sound:

```dart
// In scoring section:
if (ball.out) {
  if (ball.x < GameConfig.width / 2) {
    bats[1].score++;
  } else {
    bats[0].score++;
  }
  
  playSound("score_goal"); // Add this line
  
  int direction = (ball.x < GameConfig.width / 2) ? -1 : 1;
  ball = Ball(direction.toDouble());
}
```

---

## Initialize Game for Menu

Add to `BoingApp.onCreate()`:

```dart
@override
void onCreate() {
  app = this;
  loadAssets();
  
  // Create demo game for menu (both AI)
  game = Game([null, null]);
  
  audio.playMusic("music/theme.ogg", true);
  audio.musicVolume = 0.3;
}
```

---

## 🎉 Test Complete Game with Sound!

```bash
webdev serve --auto refresh
```

**Expected Result:**
- **Background music** plays continuously
- **Menu sounds** when navigating up/down
- **Multiple hit sounds** - different for ball speed
- **Wall bounce sounds** with synth layer
- **Goal scoring sound** when points are made
- Demo mode runs silently in menu
---
**What We Added:**
- Complete sound system with multiple variants
- Speed-based sound effects for paddle hits
- Background music with volume control
- Menu navigation sounds
- Sound management (attraction mode vs play mode)

---

# 🎉 Congratulations! 

## You built a complete game!

**Total Code:** ~300 lines of Dart creating a fully playable game!

---

## Deployment Options

```bash
webdev build
```

**Any Web Server:**
- Copy `build/` folder contents to web hosting
- Game runs in any modern browser
- No server-side code needed

---

## Resources for Further Learning

**Bullseye2D Engine:**
- [Official Documentation](https://bullseye2d.org/docs)

**Dart Language:**
- [dart.dev](https://dart.dev) - Official Dart resources
- Advanced Dart features for larger projects

---

## Thank You! 

You've successfully built a complete game from scratch using:
- **Dart programming language**
- **Bullseye2D game engine** 

**Keep building, keep learning, and most importantly - keep having fun with game development!**

🎮 *Happy coding!* 🎮


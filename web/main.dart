import 'dart:math';
import 'package:bullseye2d/bullseye2d.dart';
import 'package:vector_math/vector_math_64.dart';

late BoingApp app;

class GameConfig {
  static const double width = 800;
  static const double height = 480;
  static const double halfWidth = width / 2;
  static const double halfHeight = height / 2;
  static const double playerSpeed = 6;
  static const double maxAiSpeed = 6;
}

enum GameState { menu, play, gameOver }

class Actor {
  double x, y;
  String image;

  Actor(this.image, this.x, this.y);

  void draw() => gfx.drawImage(app.assets[image]!, 0, x, y);
  void update() {}
}

class Impact extends Actor {
  int time = 0;

  Impact(double x, double y) : super("blank", x, y);

  @override
  void update() {
    image = "impact${time ~/ 2}";
    time++;
  }
}

class Ball extends Actor {
  double dx, dy;
  int speed = 5;

  Ball(this.dx) : dy = 0, super("ball", GameConfig.halfWidth, GameConfig.halfHeight);

  bool get out => x < 0 || x > GameConfig.width;

  @override
  void update() {
    for (int i = 0; i < speed; i++) {
      double originalX = x;

      x += dx;
      y += dy;

      if ((x - GameConfig.halfWidth).abs() >= 344 && (originalX - GameConfig.halfWidth).abs() < 344) {
        int newDirX;
        Bat bat;

        if (x < GameConfig.halfWidth) {
          newDirX = 1;
          bat = app.game.bats[0];
        } else {
          newDirX = -1;
          bat = app.game.bats[1];
        }

        double differenceY = y - bat.y;

        if (differenceY > -64 && differenceY < 64) {
          dx = -dx;
          dy += differenceY / 128;
          dy = dy.clamp(-1.0, 1.0);

          Vector2 newDir = Vector2(dx, dy);
          newDir.normalize();
          dx = newDir.x;
          dy = newDir.y;

          app.game.impacts.add(Impact(x - newDirX * 10, y));

          speed++;
          app.game.aiOffset = (Random().nextInt(21) - 10).toDouble();
          bat.timer = 10;

          app.game.playSound("hit", count: 5);
          if (speed <= 10) {
            app.game.playSound("hit_slow");
          } else if (speed <= 12) {
            app.game.playSound("hit_medium");
          } else if (speed <= 16) {
            app.game.playSound("hit_fast");
          } else {
            app.game.playSound("hit_veryfast");
          }
        }
      }

      if ((y - GameConfig.halfHeight).abs() > 220) {
        dy = -dy;
        y += dy;

        app.game.impacts.add(Impact(x, y));

        app.game.playSound("bounce", count: 5);
        app.game.playSound("bounce_synth");
      }
    }
  }
}

class Bat extends Actor {
  int player;
  int score = 0;
  int timer = 0;
  double Function() moveFunc;

  Bat(this.player, double Function()? moveFunc)
    : moveFunc = moveFunc ?? (() => 0.0),
      super("blank", player == 0 ? 40 : 760, GameConfig.halfHeight) {
    this.moveFunc = moveFunc ?? ai;
  }

  @override
  void update() {
    timer--;

    double yMovement = moveFunc();
    y = (y + yMovement).clamp(80.0, 400.0);

    int frame = 0;
    if (timer > 0) {
      if (app.game.ball.out) {
        frame = 2;
      } else {
        frame = 1;
      }
    }
    image = "bat$player$frame";
  }

  double ai() {
    double xDistance = (app.game.ball.x - x).abs();
    double targetY1 = GameConfig.halfHeight;
    double targetY2 = app.game.ball.y + app.game.aiOffset;

    double weight1 = min(1, xDistance / GameConfig.halfWidth);
    double weight2 = 1 - weight1;
    double targetY = (weight1 * targetY1) + (weight2 * targetY2);

    return (targetY - y).clamp(-GameConfig.maxAiSpeed, GameConfig.maxAiSpeed);
  }
}

class Game {
  late List<Bat> bats;
  late Ball ball;
  List<Impact> impacts = [];
  double aiOffset = 0;
  BoingApp game;

  Game(List<double Function()?> controls, this.game) {
    bats = [Bat(0, controls[0]), Bat(1, controls[1])];
    ball = Ball(-1);
  }

  bool get isAttractionMode => bats[0].moveFunc == bats[0].ai;
  List<Actor> get actors => [...bats, ball, ...impacts];

  void update() {
    for (var actor in actors) {
      actor.update();
    }

    impacts.removeWhere((impact) => impact.time >= 10);

    if (ball.out) {
      int scoringPlayer = (ball.x < GameConfig.width / 2) ? 1 : 0;
      int losingPlayer = 1 - scoringPlayer;

      if (bats[losingPlayer].timer < 0) {
        bats[scoringPlayer].score++;
        playSound("score_goal");
        bats[losingPlayer].timer = 20;
      } else if (bats[losingPlayer].timer == 0) {
        int direction = (losingPlayer == 0) ? -1 : 1;
        ball = Ball(direction.toDouble());
      }
    }
  }

  void draw() {
    gfx.drawImage(game.assets["table"]!, 0, 0, 0);

    for (int p = 0; p < 2; p++) {
      if (bats[p].timer > 0 && ball.out) {
        final effectImageName = "effect$p";
        gfx.drawImage(game.assets[effectImageName]!, 0, 0, 0);
      }
    }

    for (var actor in actors) {
      actor.draw();
    }

    for (int p = 0; p < 2; p++) {
      String score = bats[p].score.toString().padLeft(2, '0');
      for (int i = 0; i < 2; i++) {
        String colour = "0";
        int otherP = 1 - p;
        if (bats[otherP].timer > 0 && ball.out) {
          colour = (p == 0) ? "2" : "1";
        }
        String imageName = "digit$colour${score[i]}";
        final double drawX = 255.0 + (160 * p) + (i * 55);
        final double drawY = 46.0;
        gfx.drawImage(game.assets[imageName]!, 0, drawX, drawY);
      }
    }
  }

  void playSound(String name, {int count = 1, bool menuSound = false}) {
    if (!isAttractionMode || menuSound) {
      audio.playSound(game.sounds["$name${count > 1 ? Random().nextInt(count) : 0}"]!);
    }
  }
}

class BoingApp extends App {
  GameState state = GameState.menu;
  late Game game;
  int numPlayers = 1;

  Map<String, Images> assets = {};
  Map<String, Sound> sounds = {};

  BoingApp() : super(AppConfig(canvasElement: "#gameCanvas")) {
    canvas.width = GameConfig.width.toInt();
    canvas.height = GameConfig.height.toInt();
  }

  @override
  void onCreate() {
    app = this;
    _loadAssets();
    game = Game([null, null], this);
    audio.playMusic("music/theme.ogg", true);
    audio.musicVolume = 0.3;
  }

  void loadImage(List<String> names, [double pivotX = 0.0, double pivotY = 0.0]) {
    for (var name in names) {
      assets[name] = resources.loadImage("images/$name.png", pivotX: pivotX, pivotY: pivotY);
    }
  }

  void loadImageAnim(String prefix, int count, [int players = 1, double pivotX = 0.0, double pivotY = 0.0]) {
    if (players == 1) {
      for (int i = 0; i < count; i++) {
        assets["$prefix$i"] = resources.loadImage("images/$prefix$i.png", pivotX: pivotX, pivotY: pivotY);
      }
    } else {
      for (int p = 0; p < players; p++) {
        for (int i = 0; i < count; i++) {
          assets["$prefix$p$i"] = resources.loadImage("images/$prefix$p$i.png", pivotX: pivotX, pivotY: pivotY);
        }
      }
    }
  }

  void _loadAssets() {
    loadImage(["ball"], 0.5, 0.5);
    loadImage(["table", "blank", "over", "menu0", "menu1", "effect0", "effect1"]);
    loadImageAnim("impact", 5, 1, 0.5, 0.5);
    loadImageAnim("bat", 3, 2, 0.5, 0.5);
    loadImageAnim("digit", 10, 3);

    // dart format off
    final soundMap = {"hit": 5, "bounce": 5, "hit_slow": 1, "hit_medium": 1, "hit_fast": 1, "hit_veryfast": 1, "bounce_synth": 1, "score_goal": 1, "up": 1, "down": 1};
    soundMap.forEach((name, count) {
      for (int i = 0; i < count; i++) { sounds["$name$i"] = resources.loadSound("sounds/$name$i.ogg"); }
    });
    // dart format on
  }

  double p1Controls() =>
      keyboard.keyDown(KeyCodes.Z) || keyboard.keyDown(KeyCodes.Down)
          ? GameConfig.playerSpeed
          : keyboard.keyDown(KeyCodes.A) || keyboard.keyDown(KeyCodes.Up)
          ? -GameConfig.playerSpeed
          : 0;

  double p2Controls() =>
      keyboard.keyDown(KeyCodes.M)
          ? GameConfig.playerSpeed
          : keyboard.keyDown(KeyCodes.K)
          ? -GameConfig.playerSpeed
          : 0;

  @override
  void onUpdate() {
    bool spacePressed = keyboard.keyHit(KeyCodes.Space);

    switch (state) {
      case GameState.menu:
        if (spacePressed) {
          state = GameState.play;
          List<double Function()?> controls = [p1Controls];
          controls.add(numPlayers == 2 ? p2Controls : null);
          game = Game(controls, this);
        } else {
          if (numPlayers == 2 && keyboard.keyHit(KeyCodes.Up)) {
            game.playSound("up", menuSound: true);
            numPlayers = 1;
          } else if (numPlayers == 1 && keyboard.keyHit(KeyCodes.Down)) {
            game.playSound("down", menuSound: true);
            numPlayers = 2;
          }
          game.update();
        }
        break;
      case GameState.play:
        if (max(game.bats[0].score, game.bats[1].score) > 9) {
          state = GameState.gameOver;
        } else {
          game.update();
        }
        break;
      case GameState.gameOver:
        if (spacePressed) {
          state = GameState.menu;
          numPlayers = 1;
          game = Game([null, null], this);
        }
        break;
    }
  }

  @override
  void onRender() {
    gfx.clear(0, 0, 0);
    game.draw();

    switch (state) {
      case GameState.menu:
        final menuImage = "menu${numPlayers - 1}";
        gfx.drawImage(assets[menuImage]!, 0, 0, 0);
        break;

      case GameState.gameOver:
        gfx.drawImage(assets["over"]!, 0, 0, 0);
        break;

      case GameState.play:
        break;
    }
  }
}

void main() {
  BoingApp();
}

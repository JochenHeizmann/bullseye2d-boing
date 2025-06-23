# Boing - Bullseye2D Port

A Dart web port of the classic Pong game "Boing" from the **Code the Classics** collection, built using the Bullseye2D game library.

## About

This is a port of the Boing game originally developed for the **Code the Classics** book. The original Python/Pygame version has been ported to Dart and adapted to run in web browsers using the Bullseye2D library.

**Original Game:** [Boing from Code the Classics](https://github.com/Wireframe-Magazine/Code-the-Classics/tree/master/boing-master)  
**Book:** [Code the Classics Volume 1](https://magazine.raspberrypi.com/books/code-the-classics1)  
**Original Author:** Eben Upton (eben@raspberrypi.org)  
**Original License:** BSD-2-Clause  

## Controls

### Player 1
- **Move Up**: `A` or `Up Arrow`
- **Move Down**: `Z/Y` or `Down Arrow`

### Player 2 (Two Player Mode)
- **Move Up**: `K`
- **Move Down**: `M`

## Getting Started

### Prerequisites
- [Dart SDK](https://dart.dev/get-dart) (^3.7.3)
- Web browser with WebGL support

### Installation

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd b2d_boing
   ```

2. Install dependencies:
   ```bash
   dart pub get
   ```

3. Activate webdev (if not already installed):
   ```bash
   dart pub global activate webdev
   ```

### Running the Game

#### Development Server
```bash
webdev serve
```
Then open your browser to `http://localhost:8080`

## License

This port maintains the same BSD-2-Clause license as the original:

## Links

- [Original Boing Source](https://github.com/Wireframe-Magazine/Code-the-Classics/tree/master/boing-master)
- [Code the Classics Book](https://magazine.raspberrypi.com/books/code-the-classics1)
- [Bullseye2D Engine](https://pub.dev/packages/bullseye2d)
- [Dart Language](https://dart.dev)

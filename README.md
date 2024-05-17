## README.md

**Helicopter Mini-Game**

This repository contains a Perl mini-game where you control a helicopter and aim to land it on a designated platform. 

**Gameplay:**

* The game starts with your helicopter positioned on a take-off platform.
* You navigate the helicopter towards a landing platform to win the game.
* An opposing "reverse helicopter" mimics your movements in reverse.
* Both helicopters can drop bombs to destroy tanks located at the bottom of the screen.
* Each tank destroyed awards a unique point value, increasing your overall score.
* The game also features static obstacles to avoid, similar to Flappy Bird.
* Use arrow keys to control the helicopter's movement and the spacebar to drop bombs.

**Requirements:**

* Perl
* Tk library 
    ```bash
    cpan install Tk
    ```

**Running the Game:**

1. Ensure you have Perl and Tk installed.
2. Execute the `Main.pl` script.

**Database (Optional):**

The game can optionally utilize a MySQL database to store the obstacles' coordinates. If you don't want to use a database, you can create static coordinates directly within the `Main.pl` script.

**License:**

This project is licensed under the MIT License. Refer to the [LICENSE](.//LICENSE.md) file for details.

**Contributing:**

Feel free to fork this repository and contribute your improvements!

**Author:**

Hasina JY

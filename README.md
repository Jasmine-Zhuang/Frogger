
## CSC258H5S Fall 2021 Assembly Final Project: Frogger
## University of Toronto, St. George
## Student: Jasmine Zhuang

## Bitmap Display Configuration:
# - Unit width in pixels: 8
# - Unit height in pixels: 8
# - Display width in pixels: 256
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)
## Features implemented:
# 1. Have cars and logs move at different speeds
# 2. Display the number of lives remaining
# 3. Make a second level that starts after the player wins 3 times.(live display turns from yellow to blue)
# 4. Display the player's score at the top right of the screen(level1 max 3, level2 max3,but can keep playing if still alive)
# 5. After final player death, display game over/retry screen. Restart the game by pressing R key. End the game by pressing E key.(R and E can also be used during the game)
## Any additional information:
# frog move left or right once per pixel, up and down once per 4 pixel.
# lives display on the top left(if enter level2, lives turn from yellow to blue)
# scores display on the top right(max 5, to enter level2, 3 scores needed)
# 5 goal spots, once occuiped, disappered. In level2, 2 will remain.
# level2 have longer car, faster moving cars and logs.

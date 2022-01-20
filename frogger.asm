#####################################################################
#
# CSC258H5S Fall 2021 Assembly Final Project
# University of Toronto, St. George
#
# Student: Jasmine Zhuang, 1006697816
#
# Bitmap Display Configuration:
# - Unit width in pixels: 8
# - Unit height in pixels: 8
# - Display width in pixels: 256
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)
#
# Which milestone is reached in this submission?
# (See the assignment handout for descriptions of the milestones)
# - Milestone 5
#
# Which approved additional features have been implemented?
# (See the assignment handout for the list of additional features)
# 1. Have cars and logs move at different speeds
# 2. Display the number of lives remaining
# 3. Make a second level that starts after the player wins 3 times.(live display turns from yellow to blue)
# 4. Display the player's score at the top right of the screen(level1 max 3, level2 max3,but can keep playing if still alive)
# 5. After final player death, display game over/retry screen. Restart the game by pressing R key. End the game by pressing E key.(R and E can also be used during the game)
# Any additional information that the TA needs to know:
# - (write here, if any) 
# frog move left or right once per pixel, up and down once per 4 pixel.
# lives display on the top left(if enter level2, lives turn from yellow to blue)
# scores display on the top right(max 5, to enter level2, 3 scores needed)
# 5 goal spots, once occuiped, disappered. In level2, 2 will remain.
# level2 have longer car, faster moving cars and logs.
#####################################################################
.data
displayAddress: .word 0x10008000 #b
frog_x: .word 14
frog_y: .word 28
V1: .space 512 # array of colors of a row of vehicles
L1: .space 512 # array of colors of a row of logs
VR1_StartUnit: .word 2 #start pixel unit i(0<=u<=31) for VR1
VR2_StartUnit: .word 9
LR1_StartUnit: .word 5
LR2_StartUnit: .word 14
isCollidedwithVehicle: .word 0 # will be set to 1 if frog collided with vehicle
Vspeed: .word 6 #down-counter for vehhicle's speed(once 1, vehicle move. each repaint it will decrease by 1.)
Lspeed: .word 8
winnings: .word 0 #curr winnings
lives: .word 3 #remaining lives

level: .word 1 #level of difficulty;if winnings=3, go to second level
#second level difficulty:
Vspeed2: .word 4 #down-counter for vehhicle's speed(once 1, vehicle move. each repaint it will decrease by 1.)
Lspeed2: .word 6
winnings2: .word 0

goalspot1: .word 1 #0 if occupied
goalspot2: .word 1
goalspot3: .word 1
goalspot4: .word 1
goalspot5: .word 1
.text
main: 
lw $t0, displayAddress # $t0 stores the base address for display
#li $t1, 0xff0000 # $t1 stores the red colour code
#li $t2, 0x00ff00 # $t2 stores the green colour code
#li $t3, 0x0000ff # $t3 stores the blue colour code
#li $t4, 0x0A1900 # $t4 stores the black colour code
#li $t5, 0xCE264F # $t5 stores the pink colour code
#li $t6, 0xFFDA09 # $t6 stores the yellow colour code
#li $t7, 0x553700 # $t7 stores the brown colour code
lw $a2,winnings
beq $a2,3,SecondLevel
PaintBackground:
add $t8, $t0, $zero # $t8 has curr position
addi $t9, $t0,1024 # $t9 = b+128*8
# paint Goal region (green)
start0:
li $t2, 0x00ff00 # $t2 stores the green colour code
beq $t8,$t9,end0 
sw $t2, 0($t8)
addi $t8,$t8,4
j start0
end0:# paint Water region (blue)
addi $t8, $t0,1024
li $t3, 0x0000ff # $t3 stores the blue colour code
addi $t9, $t0,2048 # $t9 = b+128*16
DisplayGoalSpot:
lw $t1,goalspot1
addi $t4,$zero,1
jal displayGoalSpot
lw $t1,goalspot2
addi $t4,$zero,2
jal displayGoalSpot
lw $t1,goalspot3
addi $t4,$zero,3
jal displayGoalSpot
lw $t1,goalspot4
addi $t4,$zero,4
jal displayGoalSpot
lw $t1,goalspot5
addi $t4,$zero,5
jal displayGoalSpot

DisplayScore:
lw $t0, displayAddress
li $t1, 0xff0000 # $t1 stores the red colour code
lw $t3,winnings
jal displayScore

displayLivesLeft:
lw $t0, displayAddress
lw $t1,lives
li $t2, 0xFFE891 # light yellow representing life
li $t3, 0x00ff00 #green
beq $t1,2,TwoLives
beq $t1,3,ThreeLives
#OneLife
sw $t2,0($t0)
sw $t3,8($t0)
sw $t3,16($t0)
j start1
ThreeLives:
sw $t2,0($t0)
sw $t2,8($t0)
sw $t2,16($t0)
j start1
TwoLives:
sw $t2,0($t0)
sw $t2,8($t0)
sw $t3,16($t0)
start1:
li $t3, 0x0000ff # $t3 stores the blue colour code
beq $t8,$t9,end1 
sw $t3, 0($t8)
addi $t8,$t8,4
j start1
end1:
# paint Safe region (yellow)
li $t6, 0xFFDA09 # $t6 stores the yellow colour code 
addi $t9, $t9,512 # $t9 = b+128*20
start2:
beq $t8,$t9,end2 
sw $t6, 0($t8)
addi $t8,$t8,4
j start2
end2:
# paint Road region (black)
li $t4, 0x0A1900 # $t4 stores the black colour code
addi $t9, $t9,1024 # $t9 = b+128*28
start3:
beq $t8,$t9,end3
sw $t4, 0($t8)
addi $t8,$t8,4
j start3
end3:
# paint Starting region (green)
li $t2, 0x00ff00 # $t2 stores the green colour code
addi $t9, $t0,4096 # $t9 = $t0+128*32=4096+$t0
start4:
beq $t8,$t9,end4
sw $t2, 0($t8)
addi $t8,$t8,4
j start4
end4:


DrawVehicle: # fill V with colors s.t. V1 stores the row of vehicles' colors
la $s0,V1 # $s0 = V1's address

Fill4RowOfColor:
addi $s6,$zero,0 # $s6 = current row 
addi $s7,$zero,4 #number of rows = 4
addi $s2,$zero,0 #j=0
addi $s1,$zero,0 #i=0 
FillOneRow:
beq $s6,$s7, endFill4RowOfColor
addi $s2,$s2,6 # j=6
li $t1, 0xff0000 # $t1 stores the red colour code
add $s5,$zero,$t1 # $s5 stores current color 
jal FillColor
li $t4, 0x0A1900 # $t4 stores the black colour code
addi $s2,$s2,10 # j=16
add $s5,$zero,$t4
jal FillColor
addi $s2,$s2,6 # j=22
add $s5,$zero,$t1
jal FillColor
addi $s2,$s2,10 # j=32
add $s5,$zero,$t4
jal FillColor
addi $s6,$s6,1
j FillOneRow
endFill4RowOfColor:
j PaintVR


PaintVR:
#right move
PaintVR1:
la $s0,V1 # $s0 = V1's address
lw $s1, VR1_StartUnit
add $s3,$zero,$zero #i=0

# row 1:
addi $a0,$t0,2560 #left bound 
addi $a1,$t0,2688 #right bound
addi $v0,$zero,0 #curr row
sll $a2,$s1, 2 #offset = 4u
add $s2,$a2,$a0 # start position 
add $t8,$zero,$s2 #curr position
jal PaintOneRow 
# row2:
addi $a0,$a0,128 #left bound  
addi $a1,$a1,128 #right bound
addi $s2,$s2,128 # start position 
add $t8,$zero,$s2 #curr position
jal PaintOneRow
# row3:
addi $a0,$a0,128 #left bound  
addi $a1,$a1,128 #right bound 
addi $s2,$s2,128 # start position 
add $t8,$zero,$s2 #curr position
jal PaintOneRow
# row4:
addi $a0,$a0,128 #left bound  
addi $a1,$a1,128 #right bound
addi $s2,$s2,128 # start position 
add $t8,$zero,$s2 #curr position
jal PaintOneRow 

Update_VR1_StartUnit:
lw $t3, Vspeed
bge $t3,1, PaintVR2
la $s0, VR1_StartUnit
lw $s1, 0($s0)
beq $s1,31,resetVR1S
addi $s1,$s1,1
sw $s1,0($s0)
j PaintVR2 
resetVR1S:  
addi $s1,$zero,0
sw $s1,0($s0)

#left move
PaintVR2:
la $s0,V1 # $s0 = V1's address
lw $s1, VR2_StartUnit
add $s3,$zero,$zero #i=0

# row 1:
addi $a0,$a0,128 #left bound 
addi $a1,$a1,128 #right bound
sll $a2,$s1, 2 #offset = 4u
add $s2,$a2,$a0 # start position 
add $t8,$zero,$s2 #curr position
jal PaintOneRow 
# row2:
addi $a0,$a0,128 #left bound  
addi $a1,$a1,128 #right bound
addi $s2,$s2,128 # start position 
add $t8,$zero,$s2 #curr position
jal PaintOneRow
# row3:
addi $a0,$a0,128 #left bound  
addi $a1,$a1,128 #right bound 
addi $s2,$s2,128 # start position 
add $t8,$zero,$s2 #curr position
jal PaintOneRow
# row4:
addi $a0,$a0,128 #left bound  
addi $a1,$a1,128 #right bound
addi $s2,$s2,128 # start position 
add $t8,$zero,$s2 #curr position
jal PaintOneRow 
Update_VR2_StartUnit:
lw $t3, Vspeed
bge $t3,1,DrawLog
la $s0, VR2_StartUnit
lw $s1, 0($s0)
beq $s1,0,resetVR2S
addi $s1,$s1,-1
sw $s1,0($s0)
j DrawLog
resetVR2S:  
addi $s1,$zero,31
sw $s1,0($s0)


DrawLog:
la $s0,L1 #stores L1's address
Fill4RowOfColorOfL1:
addi $s6,$zero,0 # $s6 = current row 
addi $s7,$zero,4 #number of rows = 4
addi $s2,$zero,0 #j=0
addi $s1,$zero,0 #i=0 
FillOneRowOfL1:
beq $s6,$s7, endFill4RowOfColorOfL1
addi $s2,$s2,10 # j=10
li $t7, 0x553700 # $t7 stores the brown colour code
add $s5,$zero,$t7 # $s5 stores current color 
jal FillColor
addi $s2,$s2,6 # j=16
li $t3, 0x0000ff # $t3 stores the blue colour code
add $s5,$zero,$t3
jal FillColor
addi $s2,$s2,10 # j=26
add $s5,$zero,$t7
jal FillColor
addi $s2,$s2,6 # j=32
add $s5,$zero,$t3
jal FillColor
addi $s6,$s6,1
j FillOneRowOfL1
endFill4RowOfColorOfL1:
j PaintLR

# draw the row of logs with L1, array of colors
PaintLR:
#right move
PaintLR1:
la $s0,L1 # $s0 = V1's address
lw $s1, LR1_StartUnit
add $s3,$zero,$zero #i=0
# row 1:
addi $a0,$t0,1024 #left bound 
addi $a1,$a0,128 #right bound
addi $v0,$zero,0 #curr row
sll $a2,$s1, 2 #offset = 4u
add $s2,$a2,$a0 # start position 
add $t8,$zero,$s2 #curr position
jal PaintOneRow 
# row2:
addi $a0,$a0,128 #left bound  
addi $a1,$a1,128 #right bound
addi $s2,$s2,128 # start position 
add $t8,$zero,$s2 #curr position
jal PaintOneRow
# row3:
addi $a0,$a0,128 #left bound  
addi $a1,$a1,128 #right bound 
addi $s2,$s2,128 # start position 
add $t8,$zero,$s2 #curr position
jal PaintOneRow
# row4:
addi $a0,$a0,128 #left bound  
addi $a1,$a1,128 #right bound
addi $s2,$s2,128 # start position 
add $t8,$zero,$s2 #curr position
jal PaintOneRow 

Update_LR1_StartUnit:
lw $t5, Lspeed
bge $t5,1,PaintLR2
la $s0, LR1_StartUnit
lw $s1, 0($s0)
beq $s1,31,resetLR1S
addi $s1,$s1,1
sw $s1,0($s0)
j PaintLR2 
resetLR1S:  
addi $s1,$zero,0
sw $s1,0($s0)
#left move
PaintLR2:
la $s0,L1 # $s0 = V1's address
lw $s1, LR2_StartUnit
add $s3,$zero,$zero #i=0
# row 1:
addi $a0,$a0,128 #left bound 
addi $a1,$a1,128 #right bound
sll $a2,$s1, 2 #offset = 4u
add $s2,$a2,$a0 # start position 
add $t8,$zero,$s2 #curr position
jal PaintOneRow 
# row2:
addi $a0,$a0,128 #left bound  
addi $a1,$a1,128 #right bound
addi $s2,$s2,128 # start position 
add $t8,$zero,$s2 #curr position
jal PaintOneRow
# row3:
addi $a0,$a0,128 #left bound  
addi $a1,$a1,128 #right bound 
addi $s2,$s2,128 # start position 
add $t8,$zero,$s2 #curr position
jal PaintOneRow
# row4:
addi $a0,$a0,128 #left bound  
addi $a1,$a1,128 #right bound
addi $s2,$s2,128 # start position 
add $t8,$zero,$s2 #curr position
jal PaintOneRow 
Update_LR2_StartUnit:
lw $t5, Lspeed
bge $t5,1,DrawFrogWithMove
la $s0, LR2_StartUnit
lw $s1, 0($s0)
beq $s1,0,resetLR2S
addi $s1,$s1,-1
sw $s1,0($s0)
j DrawFrogWithMove
resetLR2S:  
addi $s1,$zero,31
sw $s1,0($s0)


DrawFrogWithMove: #if a key is pressed, move the frog based on that key's response
lw $a0,frog_x
lw $a1,frog_y
MoveFrog:
# check keyboard input
lw $t8,0xffff0000
beq $t8,1,keyboard_input
j checkCollision



keyboard_input:
lw $t9,0xffff0004
beq $t9,0x61,respond_to_A 
beq $t9,0x64,respond_to_D 
beq $t9,0x73,respond_to_S #s:01110011	
beq $t9,0x77,respond_to_W 
beq $t9,0x72,respone_to_R
beq $t9,0x65,respone_to_E 

checkCollision:

checkRegion:
lw $a0,frog_x
lw $a1,frog_y
bge $a1,28, FrogInStartRegion #frogy >=28
blt $a1,16,FrogaboveSafe # frogy<16,frog not in safe and is in above regions
beq $a1,16,FrogInSafe # 16=frogy,frog in safe 

j checkVRCollision

FrogInSafe:
j DrawFrog

FrogaboveSafe:
ble $a1,4,FrogInGoalRegion #frogy<=4
j checkWater #8<=frogy<16

FrogInStartRegion:
j DrawFrog

FrogInGoalRegion:
checkIfInGoalSpot:
lw $a0,frog_x
lw $a1,frog_y
beq $a0,2,FrogInGoalSpot1
beq $a0,8,FrogInGoalSpot2
beq $a0,14,FrogInGoalSpot3
beq $a0,20,FrogInGoalSpot4
beq $a0,26,FrogInGoalSpot5
j FrogNotInGoalSpot
FrogNotInGoalSpot:
j DrawFrog

FrogInGoalSpot1:
lw $t1,goalspot1
beq $t1,0,FrogNotInGoalSpot # check if goal spot available
la $t5,goalspot1
addi $t1,$zero,0
sw $t1,0($t5)
addi $t4,$zero,1
jal displayGoalSpot
j updateWinings
FrogInGoalSpot2:
lw $t1,goalspot2
beq $t1,0,FrogNotInGoalSpot
la $t5,goalspot2
addi $t1,$zero,0
sw $t1,0($t5)
addi $t4,$zero,2
jal displayGoalSpot
j updateWinings
FrogInGoalSpot3:
lw $t1,goalspot3
beq $t1,0,FrogNotInGoalSpot
la $t5,goalspot3
addi $t1,$zero,0
sw $t1,0($t5)
addi $t4,$zero,3
jal displayGoalSpot
j updateWinings
FrogInGoalSpot4:
lw $t1,goalspot4
beq $t1,0,FrogNotInGoalSpot
la $t5,goalspot4
addi $t1,$zero,0
sw $t1,0($t5)
addi $t4,$zero,4
jal displayGoalSpot
j updateWinings
FrogInGoalSpot5:
lw $t1,goalspot5
beq $t1,0,FrogNotInGoalSpot
la $t5,goalspot5
addi $t1,$zero,0
sw $t1,0($t5)
addi $t4,$zero,5
jal displayGoalSpot

updateWinings:
lw $a2,winnings
beq $a2,3,SecondLevel
la $t1,winnings
addi $a2,$a2,1
sw $a2,0($t1)
j resetFrogToStart


checkVRCollision:
# check the leftmost and upmost pixel of frog
li $t1, 0xff0000 # $t1 stores the red colour code
jal getActualLocation
lw $t2,0($v0)
beq $t1,$t2, CollisionwithVehicleIsDetected #if the leftupmost pixel of the frog to be drawn is red then it is collided with vehicle
addiu $a0,$a0,3
jal getActualLocation
lw $t2,0($v0)
beq $t1,$t2, CollisionwithVehicleIsDetected
addiu $a0,$a0,-3
addiu $a1,$a1,1
jal getActualLocation
lw $t2,0($v0)
beq $t1,$t2, CollisionwithVehicleIsDetected
addiu $a0,$a0,1
jal getActualLocation
lw $t2,0($v0)
beq $t1,$t2, CollisionwithVehicleIsDetected
addiu $a0,$a0,1
jal getActualLocation
lw $t2,0($v0)
beq $t1,$t2, CollisionwithVehicleIsDetected
addiu $a0,$a0,1
jal getActualLocation
lw $t2,0($v0)
beq $t1,$t2, CollisionwithVehicleIsDetected
addiu $a0,$a0,-2
addiu $a1,$a1,1
jal getActualLocation
lw $t2,0($v0)
beq $t1,$t2, CollisionwithVehicleIsDetected
addiu $a0,$a0,1
jal getActualLocation
lw $t2,0($v0)
beq $t1,$t2, CollisionwithVehicleIsDetected
addiu $a0,$a0,-2
addiu $a1,$a1,1
jal getActualLocation
lw $t2,0($v0)
beq $t1,$t2, CollisionwithVehicleIsDetected
addiu $a0,$a0,1
jal getActualLocation
lw $t2,0($v0)
beq $t1,$t2, CollisionwithVehicleIsDetected
addiu $a0,$a0,1
jal getActualLocation
lw $t2,0($v0)
beq $t1,$t2, CollisionwithVehicleIsDetected
addiu $a0,$a0,1
jal getActualLocation
lw $t2,0($v0)
beq $t1,$t2, CollisionwithVehicleIsDetected
j DrawFrog

checkWater: 
lw $a0,frog_x
lw $a1,frog_y
li $t1, 0x0000ff # $t3 stores the blue colour code
jal getActualLocation
lw $t2,0($v0)
beq $t1,$t2, CollisionwithVehicleIsDetected #if any pixel of the frog to be drawn is blue, then it is in water
addiu $a0,$a0,3
jal getActualLocation
lw $t2,0($v0)
beq $t1,$t2, CollisionwithVehicleIsDetected
addiu $a0,$a0,-3
addiu $a1,$a1,1
jal getActualLocation
lw $t2,0($v0)
beq $t1,$t2, CollisionwithVehicleIsDetected
addiu $a0,$a0,1
jal getActualLocation
lw $t2,0($v0)
beq $t1,$t2, CollisionwithVehicleIsDetected
addiu $a0,$a0,1
jal getActualLocation
lw $t2,0($v0)
beq $t1,$t2, CollisionwithVehicleIsDetected
addiu $a0,$a0,1
jal getActualLocation
lw $t2,0($v0)
beq $t1,$t2, CollisionwithVehicleIsDetected
addiu $a0,$a0,-2
addiu $a1,$a1,1
jal getActualLocation
lw $t2,0($v0)
beq $t1,$t2, CollisionwithVehicleIsDetected
addiu $a0,$a0,1
jal getActualLocation
lw $t2,0($v0)
beq $t1,$t2, CollisionwithVehicleIsDetected
addiu $a0,$a0,-2
addiu $a1,$a1,1
jal getActualLocation
lw $t2,0($v0)
beq $t1,$t2, CollisionwithVehicleIsDetected
addiu $a0,$a0,1
jal getActualLocation
lw $t2,0($v0)
beq $t1,$t2, CollisionwithVehicleIsDetected
addiu $a0,$a0,1
jal getActualLocation
lw $t2,0($v0)
beq $t1,$t2, CollisionwithVehicleIsDetected
addiu $a0,$a0,1
jal getActualLocation
lw $t2,0($v0)
beq $t1,$t2, CollisionwithVehicleIsDetected

# now all pixels aren't in water,i.e. is in log, check if any yellow
checkLog:# if any pixel of frog are on the log,check which LR it's in and move with the log (left/right depending on the log)
lw $a0,frog_x
lw $a1,frog_y
li $t1, 0xFFDA09 # stores the yellow colour code
jal getActualLocation
lw $t2,0($v0)
beq $t1,$t2, DrawFrog #if any pixel of the frog drawn to be brown, then it is on the log, if any yellow, jump to draw frog and do nothing
addiu $a0,$a0,3
jal getActualLocation
lw $t2,0($v0)
beq $t1,$t2, DrawFrog
addiu $a0,$a0,-3
addiu $a1,$a1,1
jal getActualLocation
lw $t2,0($v0)
beq $t1,$t2, DrawFrog
addiu $a0,$a0,1
jal getActualLocation
lw $t2,0($v0)
beq $t1,$t2, DrawFrog
addiu $a0,$a0,1
jal getActualLocation
lw $t2,0($v0)
beq $t1,$t2, DrawFrog
addiu $a0,$a0,1
jal getActualLocation
lw $t2,0($v0)
beq $t1,$t2, DrawFrog
addiu $a0,$a0,-2
addiu $a1,$a1,1
jal getActualLocation
lw $t2,0($v0)
beq $t1,$t2, DrawFrog
addiu $a0,$a0,1
jal getActualLocation
lw $t2,0($v0)
beq $t1,$t2, DrawFrog
addiu $a0,$a0,-2
addiu $a1,$a1,1
jal getActualLocation
lw $t2,0($v0)
beq $t1,$t2, DrawFrog
addiu $a0,$a0,1
jal getActualLocation
lw $t2,0($v0)
beq $t1,$t2, DrawFrog
addiu $a0,$a0,1
jal getActualLocation
lw $t2,0($v0)
beq $t1,$t2, DrawFrog
addiu $a0,$a0,1
jal getActualLocation
lw $t2,0($v0)
beq $t1,$t2, DrawFrog
j checkMoveDirectionWithLog

# Since all pixels are on log, check which log the frog is on(move if times is 0)
checkMoveDirectionWithLog:
lw $t3,Lspeed
bne $t3,0, DrawFrog #not move with log as log isn't moving
lw $a1,frog_y
beq $a1,8,respond_to_D1 #right move
beq $a1,12,respond_to_A1 #left move

respond_to_A1: #move left
#repaint the screen except the frog and then paint the frog
lw $a0,frog_x
lw $a1,frog_y
beq $a0,0,wrapperA
la $a2,frog_x
addi $a0,$a0,-1
sw $a0,0($a2)
j DrawFrog

respond_to_D1: #move right
lw $a0,frog_x
lw $a1,frog_y
beq $a0,28,wrapperD 
la $a2,frog_x
addi $a0,$a0,1
sw $a0,0($a2)
j DrawFrog

#no collision, no update of isCollidedwithVehicle and then draw frog as usual
j DrawFrog

CollisionwithVehicleIsDetected:
Update_isCollidedwithVehicle:
la $s0,isCollidedwithVehicle
addi $s1,$zero,1
sw $s1,0($s0)

DrawFrog:
lw $a0,frog_x
lw $a1,frog_y
jal drawFrog
addiu $a0,$a0,3
jal drawFrog
addiu $a0,$a0,-3
addiu $a1,$a1,1
jal drawFrog
addiu $a0,$a0,1
jal drawFrog
addiu $a0,$a0,1
jal drawFrog
addiu $a0,$a0,1
jal drawFrog
addiu $a0,$a0,-2
addiu $a1,$a1,1
jal drawFrog
addiu $a0,$a0,1
jal drawFrog
addiu $a0,$a0,-2
addiu $a1,$a1,1
jal drawFrog
addiu $a0,$a0,1
jal drawFrog
addiu $a0,$a0,1
jal drawFrog
addiu $a0,$a0,1
jal drawFrog

la $s0,isCollidedwithVehicle
lw $s1,0($s0)
beq $s1,1,LoseLife # is collided, lives-1

j Repaint

respone_to_E: #exit
j Exit

respone_to_R:#restart
#initialize
la $t1,Lspeed
addi $t2,$zero,8
sw $t2,0($t1)
la $t1,Vspeed
addi $t2,$zero,6
sw $t2,0($t1)
la $s0,isCollidedwithVehicle
addi $s1,$zero,0
sw $s1,0($s0)
la $a0,frog_x
la $a1,frog_y
addi $t1,$zero,14
addi $t2,$zero,28
sw $t1,0($a0)
sw $t2,0($a1)
la $t1,lives
addi $a0,$zero,3
sw $a0,0($t1)
la $t1,winnings
addi $a0,$zero,0
sw $a0,0($t1)
la $t1,goalspot1
addi $a0,$zero,0
sw $a0,0($t1)
la $t1,goalspot2
addi $a0,$zero,0
sw $a0,0($t1)
la $t1,goalspot3
addi $a0,$zero,0
sw $a0,0($t1)
la $t1,goalspot4
addi $a0,$zero,0
sw $a0,0($t1)
la $t1,goalspot5
addi $a0,$zero,0
sw $a0,0($t1)
j main

respond_to_A: #move left
#repaint the screen except the frog and then paint the frog
lw $a0,frog_x
lw $a1,frog_y
beq $a0,0,wrapperA 
la $a2,frog_x
addi $a0,$a0,-1
sw $a0,0($a2)
j DrawFrog

wrapperA:
# shift frog to rightmost 
la $a2,frog_x
addi $a0,$zero,28
sw $a0,0($a2)
lw $a0,frog_x
lw $a1,frog_y
j DrawFrog

respond_to_D: #move right
lw $a0,frog_x
lw $a1,frog_y
beq $a0,28,wrapperD 
la $a2,frog_x
addi $a0,$a0,1
sw $a0,0($a2)
j DrawFrog

wrapperD:
# shift frog to leftmost 
la $a2,frog_x
addi $a0,$zero,0
sw $a0,0($a2)
lw $a0,frog_x
lw $a1,frog_y
j DrawFrog

respond_to_S: #move down
lw $a0,frog_x
lw $a1,frog_y
beq $a1,28,wrapperS
la $a2,frog_y
addi $a1,$a1,4
sw $a1,0($a2)
j DrawFrog

wrapperS:
# shift frog to upmost 
la $a2,frog_y
addi $a1,$zero,0
sw $a1,0($a2)
lw $a0,frog_x
lw $a1,frog_y
j DrawFrog

respond_to_W: #move up
lw $a0,frog_x
lw $a1,frog_y
beq $a1,0,wrapperW
la $a2,frog_y
addi $a1,$a1,-4
sw $a1,0($a2)
j DrawFrog

wrapperW:
# shift frog to downmost 
la $a2,frog_y
addi $a1,$zero,28
sw $a1,0($a2)
lw $a0,frog_x
lw $a1,frog_y
j DrawFrog


resetFrogToStart:
la $a0,frog_x
la $a1,frog_y
addi $t1,$zero,14
addi $t2,$zero,28
sw $t1,0($a0)
sw $t2,0($a1)
j Repaint

LoseLife:
la $t1,lives
lw $t2,lives
addi $t2,$t2,-1
beq $t2,0,GameOverScreen # end game if no life remain
sw $t2,0($t1)
j resetFrogToStart

Repaint:
updateLspeed:#each time minus 1 till it reached 1, then reset to 8.
la $t1,Lspeed
lw $t2,0($t1)
ble $t2,0,setBackLspeed
addi $t2,$t2,-1
sw $t2,0($t1)
j updateVspeed

setBackLspeed:
addi $t2,$zero,8
sw $t2,0($t1)

updateVspeed:#each time minus 1 till it reached 1, then reset to 6.
la $t1,Vspeed
lw $t2,0($t1)
ble $t2,0,setBackVspeed
addi $t2,$t2,-1
sw $t2,0($t1)
j resetCollisionStatus
setBackVspeed:
addi $t2,$zero,6
sw $t2,0($t1)

resetCollisionStatus:
la $s0,isCollidedwithVehicle
addi $s1,$zero,0
sw $s1,0($s0)

li $v0,32 #sleep
li $a0,16 # 60times per second, 1000//60=16
syscall
j main
#j end0
GameOverScreen: #GameOver/Retry screen
lw $t8,0xffff0000
beq $t8,1,keyboard_input
lw $t9,0xffff0004
beq $t9,0x72,respone_to_R #to main
beq $t9,0x65,respone_to_E #to Exit
li $t1,0xFFFFFF #white
li $t2, 0x00ff00 #green
addi $t9,$t0,4096
addi $t8,$t0,0
PaintBackgroundWhite:
beq $t8,$t9,paintGameOverRetry
sw $t1,0($t8)
addi $t8,$t8,4
j PaintBackgroundWhite
paintGameOverRetry:
#G:
addi $a0,$zero,1
addi $a1,$zero,1
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,1
addi $a1,$zero,2
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,1
addi $a1,$zero,3
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,2
addi $a1,$zero,0
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,2
addi $a1,$zero,4
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,3
addi $a1,$zero,0
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,3
addi $a1,$zero,2
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,3
addi $a1,$zero,4
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,4
addi $a1,$zero,0
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,4
addi $a1,$zero,2
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,4
addi $a1,$zero,3
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,4
addi $a1,$zero,4
jal getActualLocation
sw $t2,0($v0)
#A:
addi $a0,$zero,6
addi $a1,$zero,1
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,6
addi $a1,$zero,2
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,6
addi $a1,$zero,3
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,6
addi $a1,$zero,4
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,7
addi $a1,$zero,0
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,7
addi $a1,$zero,2
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,8
addi $a1,$zero,0
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,8
addi $a1,$zero,2
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,9
addi $a1,$zero,1
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,9
addi $a1,$zero,2
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,9
addi $a1,$zero,3
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,9
addi $a1,$zero,4
jal getActualLocation
sw $t2,0($v0)
#M
addi $a0,$zero,11
addi $a1,$zero,0
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,11
addi $a1,$zero,1
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,11
addi $a1,$zero,2
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,11
addi $a1,$zero,3
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,11
addi $a1,$zero,4
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,12
addi $a1,$zero,1
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,13
addi $a1,$zero,2
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,14
addi $a1,$zero,1
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,15
addi $a1,$zero,0
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,15
addi $a1,$zero,1
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,15
addi $a1,$zero,2
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,15
addi $a1,$zero,3
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,15
addi $a1,$zero,4
jal getActualLocation
sw $t2,0($v0)
#E
addi $a0,$zero,17
addi $a1,$zero,0
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,17
addi $a1,$zero,1
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,17
addi $a1,$zero,2
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,17
addi $a1,$zero,3
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,17
addi $a1,$zero,4
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,18
addi $a1,$zero,0
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,18
addi $a1,$zero,2
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,18
addi $a1,$zero,4
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,19
addi $a1,$zero,0
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,19
addi $a1,$zero,2
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,19
addi $a1,$zero,4
jal getActualLocation
sw $t2,0($v0)
#O
addi $a0,$zero,1
addi $a1,$zero,8
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,1
addi $a1,$zero,9
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,1
addi $a1,$zero,10
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,2
addi $a1,$zero,7
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,2
addi $a1,$zero,11
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,3
addi $a1,$zero,7
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,3
addi $a1,$zero,11
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,4
addi $a1,$zero,8
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,4
addi $a1,$zero,9
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,4
addi $a1,$zero,10
jal getActualLocation
sw $t2,0($v0)
#V
addi $a0,$zero,6
addi $a1,$zero,7
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,6
addi $a1,$zero,8
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,6
addi $a1,$zero,9
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,7
addi $a1,$zero,10
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,8
addi $a1,$zero,11
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,9
addi $a1,$zero,10
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,10
addi $a1,$zero,7
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,10
addi $a1,$zero,8
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,10
addi $a1,$zero,9
jal getActualLocation
sw $t2,0($v0)
#E
addi $a0,$zero,12
addi $a1,$zero,7
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,12
addi $a1,$zero,8
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,12
addi $a1,$zero,9
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,12
addi $a1,$zero,10
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,12
addi $a1,$zero,11
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,13
addi $a1,$zero,7
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,13
addi $a1,$zero,9
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,13
addi $a1,$zero,11
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,14
addi $a1,$zero,7
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,14
addi $a1,$zero,9
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,14
addi $a1,$zero,11
jal getActualLocation
sw $t2,0($v0)
#R
addi $a0,$zero,16
addi $a1,$zero,7
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,16
addi $a1,$zero,8
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,16
addi $a1,$zero,9
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,16
addi $a1,$zero,10
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,16
addi $a1,$zero,11
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,17
addi $a1,$zero,7
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,17
addi $a1,$zero,9
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,18
addi $a1,$zero,7
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,18
addi $a1,$zero,9
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,18
addi $a1,$zero,10
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,19
addi $a1,$zero,8
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,19
addi $a1,$zero,9
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,19
addi $a1,$zero,11
jal getActualLocation
sw $t2,0($v0)
#slash
addi $a0,$zero,21
addi $a1,$zero,11
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,22
addi $a1,$zero,10
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,23
addi $a1,$zero,9
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,24
addi $a1,$zero,8
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,25
addi $a1,$zero,7
jal getActualLocation
sw $t2,0($v0)
#R
addi $a0,$zero,1
addi $a1,$zero,14
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,1
addi $a1,$zero,15
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,1
addi $a1,$zero,16
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,1
addi $a1,$zero,17
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,1
addi $a1,$zero,18
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,2
addi $a1,$zero,14
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,2
addi $a1,$zero,16
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,3
addi $a1,$zero,14
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,3
addi $a1,$zero,16
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,3
addi $a1,$zero,17
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,4
addi $a1,$zero,15
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,4
addi $a1,$zero,16
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,4
addi $a1,$zero,18
jal getActualLocation
sw $t2,0($v0)
#E
addi $a0,$zero,6
addi $a1,$zero,14
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,6
addi $a1,$zero,15
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,6
addi $a1,$zero,16
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,6
addi $a1,$zero,17
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,6
addi $a1,$zero,18
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,7
addi $a1,$zero,14
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,7
addi $a1,$zero,16
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,7
addi $a1,$zero,18
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,8
addi $a1,$zero,14
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,8
addi $a1,$zero,16
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,8
addi $a1,$zero,18
jal getActualLocation
sw $t2,0($v0)
#T
addi $a0,$zero,10
addi $a1,$zero,14
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,11
addi $a1,$zero,14
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,11
addi $a1,$zero,15
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,11
addi $a1,$zero,16
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,11
addi $a1,$zero,17
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,11
addi $a1,$zero,18
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,12
addi $a1,$zero,14
jal getActualLocation
sw $t2,0($v0)
#R
addi $a0,$zero,14
addi $a1,$zero,14
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,14
addi $a1,$zero,15
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,14
addi $a1,$zero,16
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,14
addi $a1,$zero,17
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,14
addi $a1,$zero,18
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,15
addi $a1,$zero,14
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,15
addi $a1,$zero,16
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,16
addi $a1,$zero,14
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,16
addi $a1,$zero,16
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,16
addi $a1,$zero,17
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,17
addi $a1,$zero,15
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,17
addi $a1,$zero,16
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,17
addi $a1,$zero,18
jal getActualLocation
sw $t2,0($v0)
#Y
addi $a0,$zero,19
addi $a1,$zero,14
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,20
addi $a1,$zero,15
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,21
addi $a1,$zero,16
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,21
addi $a1,$zero,17
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,21
addi $a1,$zero,18
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,22
addi $a1,$zero,15
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,23
addi $a1,$zero,14
jal getActualLocation
sw $t2,0($v0)
li $v0,32 #sleep
li $a0,16 # 60times per second, 1000//60=16
syscall
j GameOverScreen



Exit:
endscreen:
li $t1,0xFFFFFF #white
li $t2, 0x00ff00 #green
addi $t9,$t0,4096
addi $t8,$t0,0
PaintBackgroundWhite_end:
beq $t8,$t9,paintEnd_end
sw $t1,0($t8)
addi $t8,$t8,4
j PaintBackgroundWhite_end
paintEnd_end:
#E:
addi $a0,$zero,1
addi $a1,$zero,0
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,1
addi $a1,$zero,1
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,1
addi $a1,$zero,2
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,1
addi $a1,$zero,3
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,1
addi $a1,$zero,4
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,2
addi $a1,$zero,0
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,2
addi $a1,$zero,2
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,2
addi $a1,$zero,4
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,3
addi $a1,$zero,0
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,3
addi $a1,$zero,2
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,3
addi $a1,$zero,4
jal getActualLocation
sw $t2,0($v0)
#N:
addi $a0,$zero,7
addi $a1,$zero,0
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,7
addi $a1,$zero,1
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,7
addi $a1,$zero,2
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,7
addi $a1,$zero,3
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,7
addi $a1,$zero,4
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,8
addi $a1,$zero,1
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,9
addi $a1,$zero,2
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,10
addi $a1,$zero,3
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,11
addi $a1,$zero,0
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,11
addi $a1,$zero,1
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,11
addi $a1,$zero,2
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,11
addi $a1,$zero,3
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,11
addi $a1,$zero,4
jal getActualLocation
sw $t2,0($v0)
#D
addi $a0,$zero,15
addi $a1,$zero,0
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,15
addi $a1,$zero,1
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,15
addi $a1,$zero,2
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,15
addi $a1,$zero,3
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,15
addi $a1,$zero,4
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,16
addi $a1,$zero,0
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,17
addi $a1,$zero,1
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,18
addi $a1,$zero,2
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,17
addi $a1,$zero,3
jal getActualLocation
sw $t2,0($v0)
addi $a0,$zero,16
addi $a1,$zero,4
jal getActualLocation
sw $t2,0($v0)
li $v0, 10 # terminate the program gracefully
syscall

#helper for displaying current score(=winnings)
displayScore: #$t1:color,$t3:winnings(max=5)
beq $t3,0,ZeroScore
beq $t3,1,OneScore
beq $t3,2,TwoScore
beq $t3,4,FourScore
beq $t3,5,FiveScore
addi $t2,$t0,124 # three score
sw $t1,0($t2)
addi $t2,$t2,256
sw $t1,0($t2)
addi $t2,$t2,256
sw $t1,0($t2)
j ZeroScore
OneScore:
addi $t2,$t0,124
sw $t1,0($t2)
j ZeroScore
TwoScore:
addi $t2,$t0,124
sw $t1,0($t2)
addi $t2,$t2,256
sw $t1,0($t2)
j ZeroScore
FourScore:
addi $t2,$t0,124
sw $t1,0($t2)
addi $t2,$t2,256
sw $t1,0($t2)
addi $t2,$t2,256
sw $t1,0($t2)
addi $t2,$t2,256
sw $t1,0($t2)
j ZeroScore
FiveScore:
addi $t2,$t0,124
sw $t1,0($t2)
addi $t2,$t2,256
sw $t1,0($t2)
addi $t2,$t2,256
sw $t1,0($t2)
addi $t2,$t2,256
sw $t1,0($t2)
addi $t2,$t0,116
sw $t1,0($t2)
j ZeroScore
ZeroScore:
jr $ra

#helper function of drawing frog
drawFrog: 
li $t5, 0xCE264F # $t5 stores the pink colour code
addiu $t9,$zero,128 # $t9=128
multu $a1, $t9 # lo = 128 * frog_y
mflo $t8 # $t8 = 128 * frog_y
add $t8,$t8,$t0 #$t8 = 128 * frog_y + $t0
addiu $t9,$zero,4 #$ t9=4
multu $a0, $t9 # lo = 4 * frog_x
mflo $t9 # $t9 = 128 * frog_x
add $t8,$t8,$t9 #$t8 = 128 * frog_y + $t0 + 4 * frog_x
sw $t5,0($t8)
jr $ra

#helper for filling colors in .space array
FillColor:
loop:
beq $s1,$s2,end # when i =j, exit the loop
sll $s3,$s1,2 # $s3=4*i
add $s4,$s0,$s3 # $s4 = addr(V[offset])
sw $s5,0($s4) 
addi $s1,$s1,1 # i+=1
j loop
end:
jr $ra

#helper func for paint one row of VR1
PaintOneRow:    
#beq $t8, $a1,endPaintOneRow 
beq $t8,$a1,warpToLeft #reach right bound
sll $s4,$s3,2 # offset= 4*i
add $s4,$s0,$s4 #$s4 = addr(V[offset])
lw $s5,0($s4) # $s5=curr color 
sw $s5, 0($t8)
addi $t8,$t8,4
addi $s3,$s3,1 # i+=1
j PaintOneRow
 
warpToLeft: 
addi $t8,$a0, 0 #starts at left bound
warp_loop:
beq $t8,$s2, endPaintOneRow # reach start position
sll $s4,$s3,2 # offset= 4*i
add $s4,$s0,$s4 #$s4 = addr(V[offset])
lw $s5,0($s4) # $s5=curr color
sw $s5, 0($t8)
addi $t8,$t8,4
addi $s3,$s3,1 # i+=1
j warp_loop

endPaintOneRow:
jr $ra

#helper that return the bi-location from (x in $a0, y in $a1)
getActualLocation:
addiu $v1,$zero,128 # $t9=128
multu $a1, $v1 # lo =128 * y 
mflo $v0 # $t8 = 128 * y
add $v0,$v0,$t0 #$t8 = 128 * y + $t0
addiu $v1,$zero,4 #$ t9=4
multu $a0, $v1 # lo = 4 * x
mflo $v1 # $t9 = 4 * x
add $v0,$v0,$v1 #$t8 = 128 * y + $t0 + 4 * x
jr $ra #return $v0

displayGoalSpot:  #$t4: if goalspot1, then =1; $t1:lw goalspot
beq $t1,0,OccupiedGoalSpot
li $t3,0xFFFFFF #white as remained
j chooseGoalSpot
OccupiedGoalSpot:
li $t3, 0x00ff00 # green as occuipied
chooseGoalSpot:
beq $t4,1,paintGoalSpot1
beq $t4,2,paintGoalSpot2
beq $t4,3,paintGoalSpot3
beq $t4,4,paintGoalSpot4
paintGoalSpot5:
addi $t2,$t0,616
sw $t3,0($t2)
sw $t3,4($t2)
sw $t3,8($t2)
sw $t3,12($t2)
addi $t2,$t2,128
sw $t3,0($t2)
sw $t3,4($t2)
sw $t3,8($t2)
sw $t3,12($t2)
addi $t2,$t2,128
sw $t3,0($t2)
sw $t3,4($t2)
sw $t3,8($t2)
sw $t3,12($t2)
addi $t2,$t2,128
sw $t3,0($t2)
sw $t3,4($t2)
sw $t3,8($t2)
sw $t3,12($t2)
j finishPaintGoalSpot
paintGoalSpot1:
addi $t2,$t0,520
sw $t3,0($t2)
sw $t3,4($t2)
sw $t3,8($t2)
sw $t3,12($t2)
addi $t2,$t2,128
sw $t3,0($t2)
sw $t3,4($t2)
sw $t3,8($t2)
sw $t3,12($t2)
addi $t2,$t2,128
sw $t3,0($t2)
sw $t3,4($t2)
sw $t3,8($t2)
sw $t3,12($t2)
addi $t2,$t2,128
sw $t3,0($t2)
sw $t3,4($t2)
sw $t3,8($t2)
sw $t3,12($t2)
j finishPaintGoalSpot
paintGoalSpot2:
addi $t2,$t0,544
sw $t3,0($t2)
sw $t3,4($t2)
sw $t3,8($t2)
sw $t3,12($t2)
addi $t2,$t2,128
sw $t3,0($t2)
sw $t3,4($t2)
sw $t3,8($t2)
sw $t3,12($t2)
addi $t2,$t2,128
sw $t3,0($t2)
sw $t3,4($t2)
sw $t3,8($t2)
sw $t3,12($t2)
addi $t2,$t2,128
sw $t3,0($t2)
sw $t3,4($t2)
sw $t3,8($t2)
sw $t3,12($t2)
j finishPaintGoalSpot
paintGoalSpot3:
addi $t2,$t0,568
sw $t3,0($t2)
sw $t3,4($t2)
sw $t3,8($t2)
sw $t3,12($t2)
addi $t2,$t2,128
sw $t3,0($t2)
sw $t3,4($t2)
sw $t3,8($t2)
sw $t3,12($t2)
addi $t2,$t2,128
sw $t3,0($t2)
sw $t3,4($t2)
sw $t3,8($t2)
sw $t3,12($t2)
addi $t2,$t2,128
sw $t3,0($t2)
sw $t3,4($t2)
sw $t3,8($t2)
sw $t3,12($t2)
j finishPaintGoalSpot
paintGoalSpot4:
addi $t2,$t0,592
sw $t3,0($t2)
sw $t3,4($t2)
sw $t3,8($t2)
sw $t3,12($t2)
addi $t2,$t2,128
sw $t3,0($t2)
sw $t3,4($t2)
sw $t3,8($t2)
sw $t3,12($t2)
addi $t2,$t2,128
sw $t3,0($t2)
sw $t3,4($t2)
sw $t3,8($t2)
sw $t3,12($t2)
addi $t2,$t2,128
sw $t3,0($t2)
sw $t3,4($t2)
sw $t3,8($t2)
sw $t3,12($t2)
j finishPaintGoalSpot
finishPaintGoalSpot:
jr $ra

SecondLevel:
PaintBackground2:
add $t8, $t0, $zero # $t8 has curr position
addi $t9, $t0,1024 # $t9 = b+128*8
# paint Goal region (green)
start02:
li $t2, 0x00ff00 # $t2 stores the green colour code
beq $t8,$t9,end02
sw $t2, 0($t8)
addi $t8,$t8,4
j start02
end02:# paint Water region (blue)
addi $t8, $t0,1024
li $t3, 0x0000ff # $t3 stores the blue colour code
addi $t9, $t0,2048 # $t9 = b+128*16
DisplayGoalSpot2:
lw $t1,goalspot1
addi $t4,$zero,1
jal displayGoalSpot
lw $t1,goalspot2
addi $t4,$zero,2
jal displayGoalSpot
lw $t1,goalspot3
addi $t4,$zero,3
jal displayGoalSpot
lw $t1,goalspot4
addi $t4,$zero,4
jal displayGoalSpot
lw $t1,goalspot5
addi $t4,$zero,5
jal displayGoalSpot

DisplayScore2:
lw $t0, displayAddress
li $t1, 0xff0000 # $t1 stores the red colour code
lw $t3,winnings
lw $s0,winnings2
add $t3,$t3,$s0
jal displayScore

displayLivesLeft2:
lw $t0, displayAddress
lw $t1,lives
li $t2, 0x0000ff # lives became blue in level 2
li $t3, 0x00ff00 #green
beq $t1,2,TwoLives2
beq $t1,3,ThreeLives2
#OneLife
sw $t2,0($t0)
sw $t3,8($t0)
sw $t3,16($t0)
j start12
ThreeLives2:
sw $t2,0($t0)
sw $t2,8($t0)
sw $t2,16($t0)
j start12
TwoLives2:
sw $t2,0($t0)
sw $t2,8($t0)
sw $t3,16($t0)
start12:
li $t3, 0x0000ff # $t3 stores the blue colour code
beq $t8,$t9,end12
sw $t3, 0($t8)
addi $t8,$t8,4
j start12
end12:
# paint Safe region (yellow)
li $t6, 0xFFDA09 # $t6 stores the yellow colour code 
addi $t9, $t9,512 # $t9 = b+128*20
start22:
beq $t8,$t9,end22
sw $t6, 0($t8)
addi $t8,$t8,4
j start22
end22:
# paint Road region (black)
li $t4, 0x0A1900 # $t4 stores the black colour code
addi $t9, $t9,1024 # $t9 = b+128*28
start32:
beq $t8,$t9,end32
sw $t4, 0($t8)
addi $t8,$t8,4
j start32
end32:
# paint Starting region (green)
li $t2, 0x00ff00 # $t2 stores the green colour code
addi $t9, $t0,4096 # $t9 = $t0+128*32=4096+$t0
start42:
beq $t8,$t9,end42
sw $t2, 0($t8)
addi $t8,$t8,4
j start42
end42:


DrawVehicle2: # fill V with colors s.t. V1 stores the row of vehicles' colors
la $s0,V1 # $s0 = V1's address

Fill4RowOfColor2:
addi $s6,$zero,0 # $s6 = current row 
addi $s7,$zero,4 #number of rows = 4
addi $s2,$zero,0 #j=0
addi $s1,$zero,0 #i=0 
FillOneRow2:
beq $s6,$s7, endFill4RowOfColor2
addi $s2,$s2,8 # j=8
li $t1, 0xff0000 # $t1 stores the red colour code
add $s5,$zero,$t1 # $s5 stores current color 
jal FillColor
li $t4, 0x0A1900 # $t4 stores the black colour code
addi $s2,$s2,8 # j=16
add $s5,$zero,$t4
jal FillColor
addi $s2,$s2,8 # j=24
add $s5,$zero,$t1
jal FillColor
addi $s2,$s2,8 # j=32
add $s5,$zero,$t4
jal FillColor
addi $s6,$s6,1
j FillOneRow2
endFill4RowOfColor2:
j PaintVR_2


PaintVR_2:
#right move
PaintVR12:
la $s0,V1 # $s0 = V1's address
lw $s1, VR1_StartUnit
add $s3,$zero,$zero #i=0

# row 1:
addi $a0,$t0,2560 #left bound 
addi $a1,$t0,2688 #right bound
addi $v0,$zero,0 #curr row
sll $a2,$s1, 2 #offset = 4u
add $s2,$a2,$a0 # start position 
add $t8,$zero,$s2 #curr position
jal PaintOneRow 
# row2:
addi $a0,$a0,128 #left bound  
addi $a1,$a1,128 #right bound
addi $s2,$s2,128 # start position 
add $t8,$zero,$s2 #curr position
jal PaintOneRow
# row3:
addi $a0,$a0,128 #left bound  
addi $a1,$a1,128 #right bound 
addi $s2,$s2,128 # start position 
add $t8,$zero,$s2 #curr position
jal PaintOneRow
# row4:
addi $a0,$a0,128 #left bound  
addi $a1,$a1,128 #right bound
addi $s2,$s2,128 # start position 
add $t8,$zero,$s2 #curr position
jal PaintOneRow 

Update_VR1_StartUnit2:
lw $t3, Vspeed2
bge $t3,1, PaintVR22
la $s0, VR1_StartUnit
lw $s1, 0($s0)
beq $s1,31,resetVR1S2
addi $s1,$s1,1
sw $s1,0($s0)
j PaintVR22
resetVR1S2:  
addi $s1,$zero,0
sw $s1,0($s0)

#left move
PaintVR22:
la $s0,V1 # $s0 = V1's address
lw $s1, VR2_StartUnit
add $s3,$zero,$zero #i=0

# row 1:
addi $a0,$a0,128 #left bound 
addi $a1,$a1,128 #right bound
sll $a2,$s1, 2 #offset = 4u
add $s2,$a2,$a0 # start position 
add $t8,$zero,$s2 #curr position
jal PaintOneRow 
# row2:
addi $a0,$a0,128 #left bound  
addi $a1,$a1,128 #right bound
addi $s2,$s2,128 # start position 
add $t8,$zero,$s2 #curr position
jal PaintOneRow
# row3:
addi $a0,$a0,128 #left bound  
addi $a1,$a1,128 #right bound 
addi $s2,$s2,128 # start position 
add $t8,$zero,$s2 #curr position
jal PaintOneRow
# row4:
addi $a0,$a0,128 #left bound  
addi $a1,$a1,128 #right bound
addi $s2,$s2,128 # start position 
add $t8,$zero,$s2 #curr position
jal PaintOneRow 
Update_VR2_StartUnit2:
lw $t3, Vspeed2
bge $t3,1,DrawLog2
la $s0, VR2_StartUnit
lw $s1, 0($s0)
beq $s1,0,resetVR2S2
addi $s1,$s1,-1
sw $s1,0($s0)
j DrawLog2
resetVR2S2:  
addi $s1,$zero,31
sw $s1,0($s0)


DrawLog2:
la $s0,L1 #stores L1's address
FillOneRowOfL12:
beq $s6,$s7, endFill4RowOfColorOfL12
addi $s2,$s2,10 # j=10
li $t7, 0x553700 # $t7 stores the brown colour code
add $s5,$zero,$t7 # $s5 stores current color 
jal FillColor
addi $s2,$s2,6 # j=16
li $t3, 0x0000ff # $t3 stores the blue colour code
add $s5,$zero,$t3
jal FillColor
addi $s2,$s2,10 # j=26
add $s5,$zero,$t7
jal FillColor
addi $s2,$s2,6 # j=32
add $s5,$zero,$t3
jal FillColor
addi $s6,$s6,1
j FillOneRowOfL12
endFill4RowOfColorOfL12:
j PaintLR_2

# draw the row of logs with L1, array of colors
PaintLR_2:
#right move
PaintLR12:
la $s0,L1 # $s0 = V1's address
lw $s1, LR1_StartUnit
add $s3,$zero,$zero #i=0
# row 1:
addi $a0,$t0,1024 #left bound 
addi $a1,$a0,128 #right bound
addi $v0,$zero,0 #curr row
sll $a2,$s1, 2 #offset = 4u
add $s2,$a2,$a0 # start position 
add $t8,$zero,$s2 #curr position
jal PaintOneRow 
# row2:
addi $a0,$a0,128 #left bound  
addi $a1,$a1,128 #right bound
addi $s2,$s2,128 # start position 
add $t8,$zero,$s2 #curr position
jal PaintOneRow
# row3:
addi $a0,$a0,128 #left bound  
addi $a1,$a1,128 #right bound 
addi $s2,$s2,128 # start position 
add $t8,$zero,$s2 #curr position
jal PaintOneRow
# row4:
addi $a0,$a0,128 #left bound  
addi $a1,$a1,128 #right bound
addi $s2,$s2,128 # start position 
add $t8,$zero,$s2 #curr position
jal PaintOneRow 

Update_LR1_StartUnit2:
lw $t5, Lspeed2
bge $t5,1,PaintLR22
la $s0, LR1_StartUnit
lw $s1, 0($s0)
beq $s1,31,resetLR1S2
addi $s1,$s1,1
sw $s1,0($s0)
j PaintLR22
resetLR1S2:  
addi $s1,$zero,0
sw $s1,0($s0)
#left move
PaintLR22:
la $s0,L1 # $s0 = V1's address
lw $s1, LR2_StartUnit
add $s3,$zero,$zero #i=0
# row 1:
addi $a0,$a0,128 #left bound 
addi $a1,$a1,128 #right bound
sll $a2,$s1, 2 #offset = 4u
add $s2,$a2,$a0 # start position 
add $t8,$zero,$s2 #curr position
jal PaintOneRow 
# row2:
addi $a0,$a0,128 #left bound  
addi $a1,$a1,128 #right bound
addi $s2,$s2,128 # start position 
add $t8,$zero,$s2 #curr position
jal PaintOneRow
# row3:
addi $a0,$a0,128 #left bound  
addi $a1,$a1,128 #right bound 
addi $s2,$s2,128 # start position 
add $t8,$zero,$s2 #curr position
jal PaintOneRow
# row4:
addi $a0,$a0,128 #left bound  
addi $a1,$a1,128 #right bound
addi $s2,$s2,128 # start position 
add $t8,$zero,$s2 #curr position
jal PaintOneRow 
Update_LR2_StartUnit2:
lw $t5, Lspeed2
bge $t5,1,DrawFrogWithMove_2
la $s0, LR2_StartUnit
lw $s1, 0($s0)
beq $s1,0,resetLR2S2
addi $s1,$s1,-1
sw $s1,0($s0)
j DrawFrogWithMove_2
resetLR2S2:  
addi $s1,$zero,31
sw $s1,0($s0)


DrawFrogWithMove_2: #if a key is pressed, move the frog based on that key's response
lw $a0,frog_x
lw $a1,frog_y
MoveFrog_2:
# check keyboard input
lw $t8,0xffff0000
beq $t8,1,keyboard_input_2
j checkCollision_2

keyboard_input_2:
lw $t9,0xffff0004
beq $t9,0x61,respond_to_A_2 
beq $t9,0x64,respond_to_D_2 
beq $t9,0x73,respond_to_S_2 #s:01110011	
beq $t9,0x77,respond_to_W_2 
beq $t9,0x72,respone_to_R
beq $t9,0x65,respond_to_E_2 

checkCollision_2:

checkRegion_2:
lw $a0,frog_x
lw $a1,frog_y
bge $a1,28, FrogInStartRegion_2 #frogy >=28
blt $a1,16,FrogaboveSafe_2 # frogy<16,frog not in safe and is in above regions
beq $a1,16,FrogInSafe_2 # 16=frogy,frog in safe 

j checkVRCollision_2

FrogInSafe_2:
j DrawFrog_2

FrogaboveSafe_2:
ble $a1,4,FrogInGoalRegion_2 #frogy<=4
j checkWater_2 #8<=frogy<16

FrogInStartRegion_2:
j DrawFrog_2

FrogInGoalRegion_2:
checkIfInGoalSpot2:
lw $a0,frog_x
lw $a1,frog_y
beq $a0,2,FrogInGoalSpot12
beq $a0,8,FrogInGoalSpot22
beq $a0,14,FrogInGoalSpot32
beq $a0,20,FrogInGoalSpot42
beq $a0,26,FrogInGoalSpot52
j FrogNotInGoalSpot2
FrogNotInGoalSpot2:
j DrawFrog_2
FrogInGoalSpot12:
lw $t1,goalspot1
beq $t1,0,FrogNotInGoalSpot2 # check if goal spot available
la $t5,goalspot1
addi $t1,$zero,0
sw $t1,0($t5)
addi $t4,$zero,1
jal displayGoalSpot
j updateWinings2
FrogInGoalSpot22:
lw $t1,goalspot2
beq $t1,0,FrogNotInGoalSpot2
la $t5,goalspot2
addi $t1,$zero,0
sw $t1,0($t5)
addi $t4,$zero,2
jal displayGoalSpot
j updateWinings2
FrogInGoalSpot32:
lw $t1,goalspot3
beq $t1,0,FrogNotInGoalSpot2
la $t5,goalspot3
addi $t1,$zero,0
sw $t1,0($t5)
addi $t4,$zero,3
jal displayGoalSpot
j updateWinings2
FrogInGoalSpot42:
lw $t1,goalspot4
beq $t1,0,FrogNotInGoalSpot2
la $t5,goalspot4
addi $t1,$zero,0
sw $t1,0($t5)
addi $t4,$zero,4
jal displayGoalSpot
j updateWinings2
FrogInGoalSpot52:
lw $t1,goalspot5
beq $t1,0,FrogNotInGoalSpot2
la $t5,goalspot5
addi $t1,$zero,0
sw $t1,0($t5)
addi $t4,$zero,5
jal displayGoalSpot

updateWinings2:
lw $a2,winnings2
la $t1,winnings2
addi $a2,$a2,1
sw $a2,0($t1)
j resetFrogToStart_2


checkVRCollision_2:
# check the leftmost and upmost pixel of frog
li $t1, 0xff0000 # $t1 stores the red colour code
jal getActualLocation
lw $t2,0($v0)
beq $t1,$t2, CollisionwithVehicleIsDetected_2 #if the leftupmost pixel of the frog to be drawn is red then it is collided with vehicle
addiu $a0,$a0,3
jal getActualLocation
lw $t2,0($v0)
beq $t1,$t2, CollisionwithVehicleIsDetected_2
addiu $a0,$a0,-3
addiu $a1,$a1,1
jal getActualLocation
lw $t2,0($v0)
beq $t1,$t2, CollisionwithVehicleIsDetected_2
addiu $a0,$a0,1
jal getActualLocation
lw $t2,0($v0)
beq $t1,$t2, CollisionwithVehicleIsDetected_2
addiu $a0,$a0,1
jal getActualLocation
lw $t2,0($v0)
beq $t1,$t2, CollisionwithVehicleIsDetected_2
addiu $a0,$a0,1
jal getActualLocation
lw $t2,0($v0)
beq $t1,$t2, CollisionwithVehicleIsDetected_2
addiu $a0,$a0,-2
addiu $a1,$a1,1
jal getActualLocation
lw $t2,0($v0)
beq $t1,$t2, CollisionwithVehicleIsDetected_2
addiu $a0,$a0,1
jal getActualLocation
lw $t2,0($v0)
beq $t1,$t2, CollisionwithVehicleIsDetected_2
addiu $a0,$a0,-2
addiu $a1,$a1,1
jal getActualLocation
lw $t2,0($v0)
beq $t1,$t2, CollisionwithVehicleIsDetected_2
addiu $a0,$a0,1
jal getActualLocation
lw $t2,0($v0)
beq $t1,$t2, CollisionwithVehicleIsDetected_2
addiu $a0,$a0,1
jal getActualLocation
lw $t2,0($v0)
beq $t1,$t2, CollisionwithVehicleIsDetected_2
addiu $a0,$a0,1
jal getActualLocation
lw $t2,0($v0)
beq $t1,$t2, CollisionwithVehicleIsDetected_2
j DrawFrog_2

checkWater_2: 
lw $a0,frog_x
lw $a1,frog_y
li $t1, 0x0000ff # $t3 stores the blue colour code
jal getActualLocation
lw $t2,0($v0)
beq $t1,$t2, CollisionwithVehicleIsDetected_2 #if any pixel of the frog to be drawn is blue, then it is in water
addiu $a0,$a0,3
jal getActualLocation
lw $t2,0($v0)
beq $t1,$t2, CollisionwithVehicleIsDetected_2
addiu $a0,$a0,-3
addiu $a1,$a1,1
jal getActualLocation
lw $t2,0($v0)
beq $t1,$t2, CollisionwithVehicleIsDetected_2
addiu $a0,$a0,1
jal getActualLocation
lw $t2,0($v0)
beq $t1,$t2, CollisionwithVehicleIsDetected_2
addiu $a0,$a0,1
jal getActualLocation
lw $t2,0($v0)
beq $t1,$t2, CollisionwithVehicleIsDetected_2
addiu $a0,$a0,1
jal getActualLocation
lw $t2,0($v0)
beq $t1,$t2, CollisionwithVehicleIsDetected_2
addiu $a0,$a0,-2
addiu $a1,$a1,1
jal getActualLocation
lw $t2,0($v0)
beq $t1,$t2, CollisionwithVehicleIsDetected_2
addiu $a0,$a0,1
jal getActualLocation
lw $t2,0($v0)
beq $t1,$t2, CollisionwithVehicleIsDetected_2
addiu $a0,$a0,-2
addiu $a1,$a1,1
jal getActualLocation
lw $t2,0($v0)
beq $t1,$t2, CollisionwithVehicleIsDetected_2
addiu $a0,$a0,1
jal getActualLocation
lw $t2,0($v0)
beq $t1,$t2, CollisionwithVehicleIsDetected_2
addiu $a0,$a0,1
jal getActualLocation
lw $t2,0($v0)
beq $t1,$t2, CollisionwithVehicleIsDetected_2
addiu $a0,$a0,1
jal getActualLocation
lw $t2,0($v0)
beq $t1,$t2, CollisionwithVehicleIsDetected_2

# now all pixels aren't in water,i.e. is in log, check if any yellow
checkLog_2:# if any pixel of frog are on the log,check which LR it's in and move with the log (left/right depending on the log)
lw $a0,frog_x
lw $a1,frog_y
li $t1, 0xFFDA09 # stores the yellow colour code
jal getActualLocation
lw $t2,0($v0)
beq $t1,$t2, DrawFrog_2 #if any pixel of the frog drawn to be brown, then it is on the log, if any yellow, jump to draw frog and do nothing
addiu $a0,$a0,3
jal getActualLocation
lw $t2,0($v0)
beq $t1,$t2, DrawFrog_2
addiu $a0,$a0,-3
addiu $a1,$a1,1
jal getActualLocation
lw $t2,0($v0)
beq $t1,$t2, DrawFrog_2
addiu $a0,$a0,1
jal getActualLocation
lw $t2,0($v0)
beq $t1,$t2, DrawFrog_2
addiu $a0,$a0,1
jal getActualLocation
lw $t2,0($v0)
beq $t1,$t2, DrawFrog_2
addiu $a0,$a0,1
jal getActualLocation
lw $t2,0($v0)
beq $t1,$t2, DrawFrog_2
addiu $a0,$a0,-2
addiu $a1,$a1,1
jal getActualLocation
lw $t2,0($v0)
beq $t1,$t2, DrawFrog_2
addiu $a0,$a0,1
jal getActualLocation
lw $t2,0($v0)
beq $t1,$t2, DrawFrog_2
addiu $a0,$a0,-2
addiu $a1,$a1,1
jal getActualLocation
lw $t2,0($v0)
beq $t1,$t2, DrawFrog_2
addiu $a0,$a0,1
jal getActualLocation
lw $t2,0($v0)
beq $t1,$t2, DrawFrog_2
addiu $a0,$a0,1
jal getActualLocation
lw $t2,0($v0)
beq $t1,$t2, DrawFrog_2
addiu $a0,$a0,1
jal getActualLocation
lw $t2,0($v0)
beq $t1,$t2, DrawFrog_2
j checkMoveDirectionWithLog_2

# Since all pixels are on log, check which log the frog is on(move if times is 0)
checkMoveDirectionWithLog_2:
lw $t3,Lspeed2
bne $t3,0, DrawFrog_2 #not move with log as log isn't moving
lw $a1,frog_y
beq $a1,8,respond_to_D21 #right move
beq $a1,12,respond_to_A21 #left move


respond_to_A21: #move left
#repaint the screen except the frog and then paint the frog
lw $a0,frog_x
lw $a1,frog_y
beq $a0,0,wrapperA_2
la $a2,frog_x
addi $a0,$a0,-1
sw $a0,0($a2)
j DrawFrog_2


respond_to_D21: #move right
lw $a0,frog_x
lw $a1,frog_y
beq $a0,28,wrapperD_2 
la $a2,frog_x
addi $a0,$a0,1
sw $a0,0($a2)
j DrawFrog_2


#no collision, no update of isCollidedwithVehicle and then draw frog as usual
j DrawFrog_2

CollisionwithVehicleIsDetected_2:
Update_isCollidedwithVehicle_2:
la $s0,isCollidedwithVehicle
addi $s1,$zero,1
sw $s1,0($s0)

DrawFrog_2:
lw $a0,frog_x
lw $a1,frog_y
jal drawFrog
addiu $a0,$a0,3
jal drawFrog
addiu $a0,$a0,-3
addiu $a1,$a1,1
jal drawFrog
addiu $a0,$a0,1
jal drawFrog
addiu $a0,$a0,1
jal drawFrog
addiu $a0,$a0,1
jal drawFrog
addiu $a0,$a0,-2
addiu $a1,$a1,1
jal drawFrog
addiu $a0,$a0,1
jal drawFrog
addiu $a0,$a0,-2
addiu $a1,$a1,1
jal drawFrog
addiu $a0,$a0,1
jal drawFrog
addiu $a0,$a0,1
jal drawFrog
addiu $a0,$a0,1
jal drawFrog

la $s0,isCollidedwithVehicle
lw $s1,0($s0)
beq $s1,1,LoseLife_2 # is collided, lives-1

j Repaint_2
respond_to_E_2:
j Exit
respond_to_A_2: #move left
#repaint the screen except the frog and then paint the frog
lw $a0,frog_x
lw $a1,frog_y
beq $a0,0,wrapperA_2 
la $a2,frog_x
addi $a0,$a0,-1
sw $a0,0($a2)
j DrawFrog_2

wrapperA_2:
# shift frog to rightmost 
la $a2,frog_x
addi $a0,$zero,28
sw $a0,0($a2)
lw $a0,frog_x
lw $a1,frog_y
j DrawFrog_2

respond_to_D_2: #move right
lw $a0,frog_x
lw $a1,frog_y
beq $a0,28,wrapperD_2
la $a2,frog_x
addi $a0,$a0,1
sw $a0,0($a2)
j DrawFrog_2

wrapperD_2:
# shift frog to leftmost 
la $a2,frog_x
addi $a0,$zero,0
sw $a0,0($a2)
lw $a0,frog_x
lw $a1,frog_y
j DrawFrog_2

respond_to_S_2: #move down
lw $a0,frog_x
lw $a1,frog_y
beq $a1,28,wrapperS_2
la $a2,frog_y
addi $a1,$a1,4
sw $a1,0($a2)
j DrawFrog_2

wrapperS_2:
# shift frog to upmost 
la $a2,frog_y
addi $a1,$zero,0
sw $a1,0($a2)
lw $a0,frog_x
lw $a1,frog_y
j DrawFrog_2

respond_to_W_2: #move up
lw $a0,frog_x
lw $a1,frog_y
beq $a1,0,wrapperW_2
la $a2,frog_y
addi $a1,$a1,-4
sw $a1,0($a2)
j DrawFrog_2
wrapperW_2:
# shift frog to downmost 
la $a2,frog_y
addi $a1,$zero,28
sw $a1,0($a2)
lw $a0,frog_x
lw $a1,frog_y
j DrawFrog_2


resetFrogToStart_2:

la $a0,frog_x
la $a1,frog_y
addi $t1,$zero,14
addi $t2,$zero,28
sw $t1,0($a0)
sw $t2,0($a1)
j Repaint_2

LoseLife_2:
la $t1,lives
lw $t2,lives
addi $t2,$t2,-1
beq $t2,0,GameOverScreen # end game if no life remain
sw $t2,0($t1)
j resetFrogToStart_2

Repaint_2:
updateLspeed_2:#each time minus 1 till it reached 1, then reset to 8.
la $t1,Lspeed2
lw $t2,0($t1)
ble $t2,0,setBackLspeed_2
addi $t2,$t2,-1
sw $t2,0($t1)
j updateVspeed_2

setBackLspeed_2:
addi $t2,$zero,6
sw $t2,0($t1)

updateVspeed_2:#each time minus 1 till it reached 1, then reset to 6.
la $t1,Vspeed2
lw $t2,0($t1)
ble $t2,0,setBackVspeed_2
addi $t2,$t2,-1
sw $t2,0($t1)
j resetCollisionStatus_2
setBackVspeed_2:
addi $t2,$zero,4
sw $t2,0($t1)

resetCollisionStatus_2:
la $s0,isCollidedwithVehicle
addi $s1,$zero,0
sw $s1,0($s0)

li $v0,32 #sleep
li $a0,16 # 60times per second, 1000//60=16
syscall
j SecondLevel


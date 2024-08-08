extensions [table]

globals [
  percent-similar  ; on the average, what percent of a turtle's neighbors
                   ; are the same color as that turtle?
  percent-unhappy  ; what percent of the turtles are unhappy?
  turtle-colors           ; colors of agents
  prefs            ; what percent similar wanted does each type of agents have?
  color-names
  color-values
]

turtles-own [
  happy?           ; for each turtle, indicates whether at least %-similar-wanted percent of
                   ;   that turtle's neighbors are the same color as the turtle
  similar-nearby   ; how many neighboring patches have a turtle with my color?
  other-nearby     ; how many have a turtle of another color?
  total-nearby     ; sum of previous two variables
]

to run-model
  clear-all-plots
  clear-drawing
  clear-output
  clear-patches
  clear-ticks
  clear-turtles

  ; create turtles on random patches.
  ask patches [

    set pcolor white
    if random 100 < density [   ; set the occupancy density
      sprout 1 [
        set color one-of turtle-colors
        set size 1
      ]
    ]
  ]
  update-turtles
  update-globals
  reset-ticks
end

to new-model
  clear-all

  ; set up
  set color-values ["red" "blue" "green" "cyan" "orange" "magenta" "yellow" "lime" "turquoise" "sky" "violet" "pink" "brown"]
  set color-names [red blue green cyan orange magenta yellow lime turquoise sky violet pink brown]
  set color-pref 50

  set prefs table:make
  set turtle-colors sublist color-names 0 num-colors ; get set of colors
  foreach turtle-colors [ x -> table:put prefs x color-pref ] ; generate the pref table

  run-model
end

; run the model for one tick
to go
  if all? turtles [ happy? ] [ stop ]
  move-unhappy-turtles
  update-turtles
  update-globals
  tick
end

; unhappy turtles try a new spot
to move-unhappy-turtles
  ask turtles with [ not happy? ]
    [ find-new-spot ]
end

; move until we find an unoccupied spot
to find-new-spot
  rt random-float 360
  fd random-float 10
  if any? other turtles-here [ find-new-spot ] ; keep going until we find an unoccupied patch
  move-to patch-here  ; move to center of patch
end

to update-turtles
  ask turtles [
    ; in next two lines, we use "neighbors" to test the eight patches
    ; surrounding the current patch
    set similar-nearby count (turtles-on neighbors)  with [ color = [ color ] of myself ]
    set other-nearby count (turtles-on neighbors) with [ color != [ color ] of myself ]
    set total-nearby similar-nearby + other-nearby
    let %-my-sim table:get prefs color
    set happy? similar-nearby >= (%-my-sim * total-nearby / 100)
    ; add visualization here
    ifelse happy? [ set shape "square" ] [ set shape "X" ]
  ]
end

to update-globals
  let similar-neighbors sum [ similar-nearby ] of turtles
  let total-neighbors sum [ total-nearby ] of turtles
  set percent-similar (similar-neighbors / total-neighbors) * 100
  set percent-unhappy (count turtles with [ not happy? ]) / (count turtles) * 100
end

;;; utility functions

to-report get-pref [c]
  set-plot-pen-color c
  report table:get-or-default prefs c -1
end

to-report get-name-index [cname]
  report position cname color-values
end

to-report get-index [c]
  let cindex position c turtle-colors
  report cindex
end

; Model adapted from the NetLogo model library model "Segregation", Copyright 1997 Uri Wilensky.
; Changes made by SWise as part of In2Science coursework
@#$#@#$#@
GRAPHICS-WINDOW
375
10
791
427
-1
-1
8.0
1
10
1
1
1
0
1
1
1
-25
25
-25
25
1
1
1
ticks
30.0

MONITOR
265
350
355
395
% unhappy
percent-unhappy
1
1
11

MONITOR
265
205
355
250
% similar
percent-similar
1
1
11

PLOT
10
125
260
270
Percent Similar
time
%
0.0
5.0
0.0
100.0
true
false
"" ""
PENS
"percent" 1.0 0 -16777216 true "" "plot percent-similar"

BUTTON
140
10
232
43
run model
run-model
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
80
60
180
95
go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

BUTTON
190
60
290
95
go one step
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

SLIDER
805
20
1080
53
density
density
50
99
72.0
1
1
%
HORIZONTAL

PLOT
10
280
260
430
Number-unhappy
NIL
NIL
0.0
10.0
0.0
100.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot count turtles with [not happy?]"

MONITOR
265
300
355
345
num-unhappy
count turtles with [not happy?]
1
1
11

MONITOR
265
155
355
200
# agents
count turtles
1
1
11

SLIDER
805
60
977
93
num-colors
num-colors
0
14
3.0
1
1
NIL
HORIZONTAL

CHOOSER
805
105
945
150
color-type-prefs
color-type-prefs
"red" "blue" "green" "cyan" "orange" "magenta" "yellow" "lime" "turquoise" "sky" "violet" "pink" "brown"
0

INPUTBOX
950
105
1085
165
color-pref
50.0
1
0
Number

BUTTON
970
180
1072
213
update pref
let stupid get-name-index color-type-prefs\nif stupid < num-colors [\n   let my-color item stupid turtle-colors\n   table:put prefs my-color color-pref\n]
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
830
180
922
213
check pref
let cindex position color-type-prefs color-values\nlet cname item cindex color-names\nset color-pref table:get-or-default prefs cname -1
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
825
260
1095
410
Preference for Same Color Type
NIL
NIL
0.0
14.0
0.0
100.0
true
false
"set-plot-x-range 0 num-colors" ""
PENS
"default" 1.0 1 -16777216 true "foreach turtle-colors [ x -> plotxy get-index x get-pref x]" "clear-plot\nforeach turtle-colors [ x -> plotxy get-index x get-pref x]"

BUTTON
15
10
112
43
new model
new-model
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

@#$#@#$#@
## WHAT IS IT?

This project models the behavior of different types of agents in a neighborhood. The red agents and blue agents get along with one another. But each agent wants to make sure that it lives near some of "its own." That is, each red agent wants to live near at least some red agents, and each blue agent wants to live near at least some blue agents. The simulation shows how these individual preferences ripple through the neighborhood, leading to large-scale patterns.

This project was inspired by Thomas Schelling's writings about social systems (such as housing patterns in cities).

## HOW TO USE IT

Decide how many types of agents you would like to simulate with the NUM-COLORS slider. Next, click the SETUP button to set up the agents. There are approximately equal numbers of agents of each type - if you have selected 2 colors, there will be roughly the same number of red and blue agents. The agents are set up so no patch has more than one agent. 
Click GO to start the simulation. If agents don't have enough same-color neighbors, they move to a nearby patch. (The topology is wrapping, so that patches on the bottom edge are neighbors with patches on the top and similar for left and right).

The DENSITY slider controls the occupancy density of the neighborhood (and thus the total number of agents). (It takes effect the next time you click SETUP.)  The COLOR-TYPE-PREFS dropdown controls the percentage of same-color agents that each agent wants among its neighbors; this is also shown in the table below it. You can check what percentage of like neighbors each color wants by clicking on the "CHECK PREF" button, and change this number by typing a new number into the "MY PREF" input and then clicking the "UPDATE PREF" button. For example, if the COLOR-TYPE_PREF is showing blue and the CHECK PREF button shows 30, each blue agent wants at least 30% of its neighbors to be blue agents.

The % SIMILAR monitor shows the average percentage of same-color neighbors for each agent. It starts at a number around 1/NUM-COLORS. For example, in the case of two colors around 50%: each agent starts (on average) with an equal number of red and blue agents as neighbors. The NUM-UNHAPPY monitor shows the number of unhappy agents, and the % UNHAPPY monitor shows the percent of agents that have fewer same-color neighbors than they want (and thus want to move). The % SIMILAR and the NUM-UNHAPPY monitors are also plotted.

Unhappy agents are visualized as Xs.

## THINGS TO NOTICE

When you execute SETUP, the different colored agents are randomly distributed throughout the neighborhood. But many agents are "unhappy" since they don't have enough same-color neighbors. The unhappy agents move to new locations in the vicinity. But in the new locations, they might tip the balance of the local population, prompting other agents to leave. For example, a few red agents move into an area, the local blue agents might leave. But when the blue agents move to a new area, they might prompt red agents to leave that area.

Over time, the number of unhappy agents decreases. But the neighborhood becomes more segregated, with clusters of specific colors of agents.

Relatively small individual preferences can lead to significant overall segregation.

## THINGS TO TRY

Try different values for the preferences. Try changing the value for only SOME types of agents. How does the overall degree of segregation change?

If each agent wants at least 40% same-color neighbors, what percentage (on average) do they end up with?

Try different values of DENSITY. How does the initial occupancy density affect the percentage of unhappy agents? How does it affect the time it takes for the model to finish?

Can you set the parameters so that the model never finishes running, and agents keep looking for new locations?


## CREDITS AND REFERENCES

Schelling, T. (1978). Micromotives and Macrobehavior. New York: Norton.

See also: Rauch, J. (2002). Seeing Around Corners; The Atlantic Monthly; April 2002;Volume 289, No. 4; 35-48. https://www.theatlantic.com/magazine/archive/2002/04/seeing-around-corners/302471/

## COPYRIGHT AND LICENSE

The original model from which this model has been adapted is copyright 1997 Uri Wilensky.

![CC BY-NC-SA 3.0](http://ccl.northwestern.edu/images/creativecommons/byncsa.png)

This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 License.  To view a copy of this license, visit https://creativecommons.org/licenses/by-nc-sa/3.0/ or send a letter to Creative Commons, 559 Nathan Abbott Way, Stanford, California 94305, USA.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

face-happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

person2
false
0
Circle -7500403 true true 105 0 90
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 285 180 255 210 165 105
Polygon -7500403 true true 105 90 15 180 60 195 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

square
false
0
Rectangle -7500403 true true 30 30 270 270

square - happy
false
0
Rectangle -7500403 true true 30 30 270 270
Polygon -16777216 false false 75 195 105 240 180 240 210 195 75 195

square - unhappy
false
0
Rectangle -7500403 true true 30 30 270 270
Polygon -16777216 false false 60 225 105 180 195 180 240 225 75 225

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

square-small
false
0
Rectangle -7500403 true true 45 45 255 255

square-x
false
0
Rectangle -7500403 true true 30 30 270 270
Line -16777216 false 75 90 210 210
Line -16777216 false 210 90 75 210

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 0 0 0 300 300 300 30 30

triangle2
false
0
Polygon -7500403 true true 150 0 0 300 300 300

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

x
false
0
Polygon -7500403 true true 300 60 225 0 0 225 60 300
Polygon -7500403 true true 0 60 75 0 300 240 225 300
@#$#@#$#@
NetLogo 6.1.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
1
@#$#@#$#@

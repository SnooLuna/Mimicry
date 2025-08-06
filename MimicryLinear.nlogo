globals [
  seed ; random seed used in setup
]


;; two breeds of prey
breed [ models model ]  ; lethal models
breed [ mimics mimic ]  ; harmless mimics
models-own [
  visibility  ; the color of a prey agent and how visible they are
]
mimics-own [
  visibility
]

;; breed of predators
breed [ predators predator ]
predators-own [
  prey-mean  ; which visibility level they see as edible
  energy
]


;;
;; Setup Procedures
;;

to setup
  clear-all

  set seed new-seed
  random-seed seed

  setup-turtles
  reset-ticks
end

to setup-turtles
  ask patches [ set pcolor 78.8 ]
  set-default-shape models       "butterfly viceroy"   ; shapes taken from Wilensky
  set-default-shape mimics       "butterfly monarch"
  set-default-shape predators    "hawk"

  create-predators carrying-capacity-predators                                       ;; create predators
  [
    set color brown
    set size 3

    set prey-mean ifelse-value (predator-set-visibility?) [prey-visibility-predator] [random-float 100]
    set energy 200
  ]

  create-models carrying-capacity-models [                                           ;; create prey
    set color to-color ifelse-value (model-set-visibility?) [visibility-model] [random 100]
    set size 1.5

    set visibility from-color color
  ]
  create-mimics carrying-capacity-mimics [
    set color to-color ifelse-value mimic-set-visibility? [visibility-mimic] [random 100]
    set size 1.5

    set visibility from-color color
  ]

  ;; scatter all three breeds around the world
  ask turtles [ setxy random-xcor random-ycor ]
end




;;
;; Runtime Procedures
;;

to go
  ;; all agents move
  ask turtles [
    wiggle
  ]

  ask predators [
    predators-eat                ; predators might die here
    predators-find-other-food
    predators-age                ; predators might die here
    predators-reproduce
  ]

  ;; turtles that are not predators are prey
  ask turtles with [breed != predators] [
    preys-reproduce
  ]

  tick
end


to wiggle  ; turtle procedure
  rt random 100
  lt random 100
  fd 1
end

;; predator meets prey and maybe attacks it
to predators-eat  ; predator procedure
  let prey-here one-of turtles-here with [breed != predators]
  if prey-here != nobody [
    if sees? prey-here [
      if attacks? prey-here [
        if [breed] of prey-here = models [
          if model-dangerous? [
            ask prey-here [ die ]
            die                                  ; prey was poisonous
          ]
        ]
        ask prey-here [ die ]
        set energy energy + energy-in-prey       ; prey was edible
      ]
    ]
  ]
end

;; can the predator see the prey?
to-report sees? [prey] ; predator procedure
  if random-float 100 < ((abs [visibility] of prey) + base-visibility)
    [ report true ]
  report false
end

to-report attacks? [prey] ; predator procedure
  let prey-visibility [visibility] of prey
  ;; probability of attack depends on proximity to prey-mean
  let dist abs (prey-visibility - prey-mean)
  ;; do not attack outside preying range
  if dist > prey-range [ report false ]
  ;; lower dist means more chance to attack
  if random prey-range < (prey-range - dist) [ report true ]
  report false
end

;; the predators have a chance to gain energy randomly
to predators-find-other-food ; predator procedure
  if random-float 100 < food-available [
    set energy energy + energy-other-food
  ]
end

to predators-age ;; predator procedure                                                       predator evolution
  set energy energy - 1
  if energy <= 0  [
    die
  ]
end

;;         Unaltered from Wilensky model
;; Each predator has an equal chance of reproducing
;; depending on how close to carrying capacity the
;; population is.
to predators-reproduce ;; predator procedure
  if count predators < carrying-capacity-predators
  [ hatch-predator ]
end

to hatch-predator ;; predator procedure
  if random-float 100 < reproduction-chance
  [
    hatch 1
    [
      fd 1
      ;; the predators will have a predation color similar to its parent,
      ;; this can mutate based on a normal range, but stays within normal values.
      ;; mean = parent's color, sd = mutation-predator (slider)
      set prey-mean from-color to-color random-normal prey-mean mutation-predator
    ]
 ]
end


;;         Unaltered from Wilensky model
;; Each prey has an equal chance of reproducing
;; depending on how close to carrying capacity the
;; population is.
to preys-reproduce ; prey procedure
  ifelse breed = models
  [ if random count models < carrying-capacity-models - count models
     [ hatch-prey ] ]
  [ if random count mimics < carrying-capacity-mimics - count mimics
     [ hatch-prey ] ]
end

to hatch-prey ; prey procedure
  if random-float 100 < reproduction-chance
  [
    hatch 1
    [
      fd 1
      ;; the prey will have a color similar to its parent,
      ;; this can mutate based on a normal range, but stays within normal values.
      ;; mean = parent's color, sd = mutation-prey (slider)
      let parent-color [visibility] of myself
      set color to-color random-normal parent-color mutation-prey
      set visibility from-color color
    ]
 ]
end


;; helper to report a random color within range
to-report random-color
  report to-color random-float 100
end

;; from visibility percentage to color
to-report to-color [value]
  if value = 50 [
    report 19.9
  ]
  ;; color needs to be within certain range
  while [value < 0 or value > 100] [
    if value > 100 [set value 100 - (value - 100)]
    if value < 0  [set value abs value]
  ]

  ;; 0-100 -> green - white - red
  ifelse value > 50 [
    set value 15 + sqrt ((value / -2) + 50)
  ][
    set value sqrt (value / 2) + 55
  ]

  report value
end

;; from color to visibility percentage
to-report from-color [value]
  ;; green - white - red -> 0-100
  ifelse value < 35 [
    set value -2 * (value - 15) * (value - 15) + 100
  ][
    set value 2 * (value - 55) * (value - 55)
  ]

  ;; color needs to be within certain range
  while [value < 0 or value > 100] [
    if value > 100 [set value 100 - (value - 100)]
    if value < 0  [set value abs value]
  ]
  report value
end
@#$#@#$#@
GRAPHICS-WINDOW
195
10
724
540
-1
-1
5.21
1
10
1
1
1
0
1
1
1
0
99
-99
0
1
1
1
ticks
30.0

BUTTON
11
268
99
301
setup
setup
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
101
268
189
301
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

MONITOR
1011
137
1104
182
NIL
count models
0
1
11

MONITOR
857
234
918
279
maximum
max [visibility] of models
3
1
11

MONITOR
798
234
854
279
average
mean [visibility] of models
3
1
11

MONITOR
1011
185
1104
230
NIL
count mimics
0
1
11

MONITOR
857
280
918
325
maximum
max [visibility] of mimics
3
1
11

MONITOR
798
280
854
325
average
mean [visibility] of mimics
3
1
11

PLOT
730
10
1007
230
Average Colors Over Time
Time
Average Visibility
0.0
100.0
0.0
100.0
true
true
"" ""
PENS
"Mimics" 1.0 0 -10899396 true "" "plot mean [visibility] of mimics"
"Models" 1.0 0 -2674135 true "" "plot mean [visibility] of models"
"Predators" 1.0 0 -6459832 true "" "plot mean [prey-mean] of predators"

TEXTBOX
732
244
798
262
Model colors:
11
0.0
1

TEXTBOX
733
286
799
304
Mimic colors:
11
0.0
1

MONITOR
921
234
978
279
minimum
min [visibility] of models
3
1
11

MONITOR
921
280
978
325
minimum
min [visibility] of mimics
3
1
11

PLOT
730
329
930
479
Model Visibility
visibility level
count
0.0
101.0
0.0
300.0
false
false
"" "histogram [visibility] of models\nset-plot-x-range 0 101"
PENS
"model color" 1.0 1 -5298144 true "" ""

PLOT
730
482
930
632
Mimic Visibility
visibility level
count
0.0
101.0
0.0
300.0
false
false
"" "histogram [visibility] of mimics\nset-plot-x-range 0 101"
PENS
"Colubrid Colors" 1.0 1 -12087248 true "" ""

SLIDER
12
378
189
411
prey-range
prey-range
0
100
30.0
1
1
NIL
HORIZONTAL

PLOT
932
482
1132
632
Predator mean preying color
preying mean
count
0.0
10.0
0.0
100.0
false
false
"" "histogram [prey-mean] of predators\nset-plot-x-range 0 101"
PENS
"default" 1.0 1 -8431303 true "" ""

MONITOR
1012
10
1105
55
mean energy
mean [energy] of predators
2
1
11

MONITOR
1011
89
1104
134
count Predators
count predators
17
1
11

SLIDER
12
414
188
447
reproduction-chance
reproduction-chance
0
10
0.7
0.1
1
NIL
HORIZONTAL

SLIDER
9
10
188
43
carrying-capacity-mimics
carrying-capacity-mimics
0
600
200.0
1
1
NIL
HORIZONTAL

SLIDER
9
45
188
78
carrying-capacity-models
carrying-capacity-models
0
600
300.0
1
1
NIL
HORIZONTAL

SLIDER
9
81
188
114
carrying-capacity-predators
carrying-capacity-predators
0
300
150.0
1
1
NIL
HORIZONTAL

SLIDER
12
450
188
483
energy-in-prey
energy-in-prey
0
200
100.0
1
1
NIL
HORIZONTAL

MONITOR
981
234
1038
279
median
median [visibility] of models
3
1
11

MONITOR
981
280
1038
325
median
mean [visibility] of mimics
3
1
11

MONITOR
1041
234
1104
279
mode
one-of modes [round visibility] of models
3
1
11

MONITOR
1041
280
1104
325
mode
one-of modes [round visibility] of mimics
3
1
11

SLIDER
12
486
188
519
base-visibility
base-visibility
0
100
10.0
1
1
NIL
HORIZONTAL

SLIDER
12
342
189
375
mutation-prey
mutation-prey
0
100
15.0
1
1
NIL
HORIZONTAL

SLIDER
12
306
189
339
mutation-predator
mutation-predator
0
100
10.0
1
1
NIL
HORIZONTAL

SWITCH
11
231
189
264
model-dangerous?
model-dangerous?
0
1
-1000

PLOT
933
329
1133
479
Population counts
Ticks
Agent count
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Mimics" 1.0 0 -10899396 true "" "plot count mimics"
"Models" 1.0 0 -2674135 true "" "plot count models"
"Predators" 1.0 0 -6459832 true "" "plot count predators"

SLIDER
12
524
188
557
food-available
food-available
0
20
2.0
0.1
1
NIL
HORIZONTAL

SLIDER
12
559
188
592
energy-other-food
energy-other-food
0
100
30.0
1
1
NIL
HORIZONTAL

SWITCH
9
153
189
186
model-set-visibility?
model-set-visibility?
0
1
-1000

SWITCH
9
118
189
151
mimic-set-visibility?
mimic-set-visibility?
0
1
-1000

SWITCH
8
189
189
222
predator-set-visibility?
predator-set-visibility?
0
1
-1000

SLIDER
46
117
189
150
visibility-mimic
visibility-mimic
0
100
0.0
1
1
NIL
HORIZONTAL

SLIDER
46
152
189
185
visibility-model
visibility-model
0
100
100.0
1
1
NIL
HORIZONTAL

SLIDER
46
188
189
221
prey-visibility-predator
prey-visibility-predator
0
100
0.0
1
1
NIL
HORIZONTAL

@#$#@#$#@
# CORAL SNAKE MIMICRY

## COLOUR SYSTEM

This version of the model uses the Linear colour system. This means visibility values range between 0 to 100, corresponding to agent colours of green(0) to white(50) to red(100). 

## CREDITS

This model was loosely based on Wilensky's model of Batesian mimicry (1997), which can be found in the NetLogo model library, labelled "Mimicry".
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

bird 1
false
0
Polygon -7500403 true true 2 6 2 39 270 298 297 298 299 271 187 160 279 75 276 22 100 67 31 0

bird 2
false
0
Polygon -7500403 true true 2 4 33 4 298 270 298 298 272 298 155 184 117 289 61 295 61 105 0 43

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

butterfly monarch
false
15
Line -1 true 0 0 424 424
Line -1 true 299 1 -128 424

butterfly viceroy
false
15
Circle -1 false true 34 34 232

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

cutesnake
true
0
Rectangle -16777216 true false 120 0 195 15
Rectangle -7500403 true true 120 15 195 30
Rectangle -7500403 true true 135 15 180 75
Rectangle -2674135 true false 150 60 165 105
Rectangle -7500403 true true 105 60 150 75
Rectangle -7500403 true true 105 30 120 75
Rectangle -7500403 true true 165 60 210 75
Rectangle -7500403 true true 195 30 210 75
Rectangle -16777216 true false 120 30 135 60
Rectangle -16777216 true false 180 30 195 60
Rectangle -16777216 true false 105 15 120 30
Rectangle -16777216 true false 90 30 105 75
Rectangle -16777216 true false 210 30 225 75
Rectangle -16777216 true false 195 15 210 30
Rectangle -16777216 true false 105 75 150 90
Rectangle -16777216 true false 165 75 210 90
Rectangle -16777216 true false 120 75 135 135
Rectangle -16777216 true false 105 135 120 150
Rectangle -7500403 true true 135 90 150 180
Rectangle -7500403 true true 135 105 180 165
Rectangle -7500403 true true 165 90 180 135
Rectangle -7500403 true true 120 135 165 180
Rectangle -7500403 true true 75 150 135 195
Rectangle -7500403 true true 60 135 105 180
Rectangle -7500403 true true 75 120 120 135
Rectangle -7500403 true true 75 120 105 150
Rectangle -16777216 true false 75 105 120 120
Rectangle -16777216 true false 60 120 75 135
Rectangle -16777216 true false 45 135 60 180
Rectangle -16777216 true false 30 135 60 150
Rectangle -7500403 true true 30 150 45 210
Rectangle -16777216 true false 15 150 30 210
Rectangle -16777216 true false 30 210 45 225
Rectangle -16777216 true false 45 225 60 240
Rectangle -7500403 true true 30 180 60 210
Rectangle -7500403 true true 45 195 75 225
Rectangle -7500403 true true 60 210 180 240
Rectangle -16777216 true false 75 195 135 210
Rectangle -16777216 true false 135 180 165 195
Rectangle -16777216 true false 165 165 180 180
Rectangle -16777216 true false 180 90 195 165
Rectangle -7500403 true true 135 195 195 225
Rectangle -7500403 true true 165 180 210 210
Rectangle -7500403 true true 180 165 225 195
Rectangle -7500403 true true 195 120 210 165
Rectangle -7500403 true true 195 135 225 180
Rectangle -16777216 true false 180 105 210 120
Rectangle -16777216 true false 210 120 225 135
Rectangle -16777216 true false 225 135 240 195
Rectangle -16777216 true false 210 195 225 210
Rectangle -16777216 true false 195 210 210 225
Rectangle -16777216 true false 180 225 195 255
Rectangle -16777216 true false 60 240 195 255
Rectangle -16777216 true false 195 255 240 270
Rectangle -16777216 true false 240 240 255 255
Rectangle -16777216 true false 255 195 270 240
Rectangle -16777216 true false 270 180 285 210
Rectangle -16777216 true false 225 210 270 225
Rectangle -7500403 true true 210 210 225 255
Rectangle -7500403 true true 195 225 240 255
Rectangle -7500403 true true 225 225 255 240
Rectangle -16777216 true false 60 180 75 195

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

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

hawk
true
0
Polygon -7500403 true true 151 170 136 170 123 229 143 244 156 244 179 229 166 170
Polygon -16777216 true false 152 154 137 154 125 213 140 229 159 229 179 214 167 154
Polygon -7500403 true true 151 140 136 140 126 202 139 214 159 214 176 200 166 140
Polygon -16777216 true false 151 125 134 124 128 188 140 198 161 197 174 188 166 125
Polygon -7500403 true true 152 86 227 72 286 97 272 101 294 117 276 118 287 131 270 131 278 141 264 138 267 145 228 150 153 147
Polygon -7500403 true true 160 74 159 61 149 54 130 53 139 62 133 81 127 113 129 149 134 177 150 206 168 179 172 147 169 111
Circle -16777216 true false 144 55 7
Polygon -16777216 true false 129 53 135 58 139 54
Polygon -7500403 true true 148 86 73 72 14 97 28 101 6 117 24 118 13 131 30 131 22 141 36 138 33 145 72 150 147 147

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

smoothsnake
true
0
Polygon -7500403 true true 60 45 60 90 60 90 75 105 150 105 165 90 165 90 165 75 195 75 210 90 210 120 195 135 150 135 90 150 75 165 60 195 75 240 90 270 135 285 180 285 210 270 240 255 255 240 270 225 285 180 285 150 270 195 255 210 240 225 210 240 180 255 165 255 135 240 120 210 120 195 120 195 135 180 150 180 195 180 225 165 255 135 255 105 255 90 240 60 225 45 210 30 180 15 135 15 90 30 90 30 60 45
Polygon -7500403 true true 45 105
Rectangle -2674135 true false 105 90 120 120
Rectangle -16777216 true false 75 60 90 90
Rectangle -16777216 true false 135 60 150 90

snakey
true
0
Rectangle -7500403 true true 120 15 195 30
Rectangle -7500403 true true 135 15 180 75
Rectangle -2674135 true false 150 60 165 105
Rectangle -7500403 true true 105 60 150 75
Rectangle -7500403 true true 105 30 120 75
Rectangle -7500403 true true 165 60 210 75
Rectangle -7500403 true true 195 30 210 75
Rectangle -16777216 true false 120 30 135 60
Rectangle -16777216 true false 180 30 195 60
Rectangle -7500403 true true 135 90 150 180
Rectangle -7500403 true true 135 105 180 165
Rectangle -7500403 true true 165 90 180 135
Rectangle -7500403 true true 120 135 165 180
Rectangle -7500403 true true 75 150 135 195
Rectangle -7500403 true true 60 135 105 180
Rectangle -7500403 true true 75 120 120 135
Rectangle -7500403 true true 75 120 105 150
Rectangle -7500403 true true 30 150 45 210
Rectangle -7500403 true true 30 180 60 210
Rectangle -7500403 true true 45 195 75 225
Rectangle -7500403 true true 60 210 180 240
Rectangle -7500403 true true 135 195 195 225
Rectangle -7500403 true true 165 180 210 210
Rectangle -7500403 true true 180 165 225 195
Rectangle -7500403 true true 195 120 210 165
Rectangle -7500403 true true 195 135 225 180
Rectangle -7500403 true true 210 210 225 255
Rectangle -7500403 true true 195 225 240 255
Rectangle -7500403 true true 225 225 255 240
Polygon -16777216 false false 255 225 255 240 240 255 195 255 180 240 60 240 30 210 30 150 45 150 60 135 75 120 120 120 120 135 105 150 135 120 135 75 105 75 105 30 120 30 120 15 195 15 195 30 210 30 210 75 180 75 180 165 165 180 135 195 105 210 75 195 60 180 45 150 60 135 60 180 75 195 135 195 165 180 180 165 195 120 180 120 210 120 225 135 225 195 180 240 225 195 225 210 255 225 255 210 270 195 255 210 270 195 270 210 255 240 240 255 195 255 180 240 60 240 30 210 30 150 45 150 75 120 135 120 135 75 105 75 105 30 120 15 195 15 210 30 210 75 180 75 180 120 210 120 225 135 225 210

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

ssnake
true
0
Polygon -7500403 true true 45 105
Polygon -7500403 true true 120 285 120 300 180 300 180 285 210 285 210 270 240 270 240 255 255 255 255 240 270 240 270 225 285 225 285 165 270 165 270 195 255 195 255 210 240 210 240 225 210 225 210 240 180 240 180 255 135 255 135 240 120 240 120 225 105 225 105 195 120 195 120 180 180 180 180 165 225 165 225 150 255 150 255 135 270 135 270 60 255 60 255 45 240 45 240 30 210 30 210 15 105 15 105 30 75 30 75 45 60 45 60 90 75 90 75 105 150 105 150 90 165 90 165 75 210 75 210 105 195 105 195 120 135 120 135 135 75 135 75 150 60 150 60 165 45 165 45 240 60 240 60 270 90 270 90 285
Rectangle -2674135 true false 105 90 120 120
Rectangle -16777216 true false 75 60 90 90
Rectangle -16777216 true false 135 60 150 90

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
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

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

try
true
0
Polygon -7500403 true true 45 105
Polygon -7500403 true true 120 285 120 300 180 300 180 285 210 285 210 270 240 270 240 255 255 255 255 240 270 240 270 225 285 225 285 165 270 165 270 195 255 195 255 210 240 210 240 225 210 225 210 240 180 240 180 255 135 255 135 240 120 240 120 225 105 225 105 195 120 195 120 180 180 180 180 165 225 165 225 150 255 150 255 135 270 135 270 60 255 60 255 45 240 45 240 30 210 30 210 15 105 15 105 30 75 30 75 45 60 45 60 90 75 90 75 105 150 105 150 90 165 90 165 75 210 75 210 105 195 105 195 120 135 120 135 135 75 135 75 150 60 150 60 165 45 165 45 240 60 240 60 270 90 270 90 285
Rectangle -2674135 true false 105 90 120 120
Rectangle -16777216 true false 75 60 90 90
Rectangle -16777216 true false 135 60 150 90
Polygon -16777216 false false 60 150 75 150 75 135 135 135 135 120 195 120 195 105 195 120 135 120 135 135 75 135 75 150
Polygon -16777216 false false 255 150 225 150 225 165 180 165 180 180 120 180 180 180 180 165 225 165 225 150
Polygon -16777216 false false 135 240 135 240 135 240 180 255 180 240 210 240 210 225 240 225 210 225 210 240 180 240 180 255 135 255

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
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.4.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="exp" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="20000"/>
    <metric>count turtles</metric>
    <metric>count mimics</metric>
    <metric>count models</metric>
    <metric>count predators</metric>
    <metric>[visibility] of mimics</metric>
    <metric>[visibility] of models</metric>
    <metric>[prey-mean] of predators</metric>
    <metric>list mean [visibility] of mimics</metric>
    <metric>list mean [visibility] of models</metric>
    <metric>list mean [prey-mean] of predators</metric>
    <enumeratedValueSet variable="carrying-capacity-mimics">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="prey-range">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-other-food">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="base-visibility">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="carrying-capacity-models">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mutation-prey">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mutation-predator">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-importance">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="visibility-model">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-in-prey">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="food-available">
      <value value="1.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="visibility-mimic">
      <value value="51"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-chance">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="snakes-eat?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="carrying-capacity-predators">
      <value value="150"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="20000"/>
    <metric>count turtles</metric>
    <metric>count mimics</metric>
    <metric>count models</metric>
    <metric>count predators</metric>
    <metric>[visibility] of mimics</metric>
    <metric>[visibility] of models</metric>
    <metric>[prey-mean] of predators</metric>
    <metric>list mean [visibility] of mimics</metric>
    <metric>list mean [visibility] of models</metric>
    <metric>list mean [prey-mean] of predators</metric>
    <enumeratedValueSet variable="carrying-capacity-mimics">
      <value value="255"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="prey-range">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-other-food">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="base-visibility">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="carrying-capacity-models">
      <value value="385"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mutation-prey">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mutation-predator">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-importance">
      <value value="1.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="visibility-model">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-in-prey">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="food-available">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="visibility-mimic">
      <value value="51"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-chance">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="snakes-eat?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="carrying-capacity-predators">
      <value value="150"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="finalmaybe" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="50000"/>
    <metric>count turtles</metric>
    <metric>count mimics</metric>
    <metric>count models</metric>
    <metric>count predators</metric>
    <metric>[visibility] of mimics</metric>
    <metric>[visibility] of models</metric>
    <metric>[prey-mean] of predators</metric>
    <metric>list mean [visibility] of mimics</metric>
    <metric>list mean [visibility] of models</metric>
    <metric>list mean [prey-mean] of predators</metric>
    <enumeratedValueSet variable="carrying-capacity-mimics">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mimic-set-visibility?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="prey-range">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-other-food">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="base-visibility">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="prey-visibility-predator">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="carrying-capacity-models">
      <value value="180"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mutation-prey">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mutation-predator">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="visibility-model">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-in-prey">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="model-set-visibility?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="food-available">
      <value value="1.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="visibility-mimic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-chance">
      <value value="1.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="model_dangerous?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="predator-set-visibility?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="carrying-capacity-predators">
      <value value="140"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="linear" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="50000"/>
    <metric>count turtles</metric>
    <metric>count mimics</metric>
    <metric>count models</metric>
    <metric>count predators</metric>
    <metric>[visibility] of mimics</metric>
    <metric>[visibility] of models</metric>
    <metric>[prey-mean] of predators</metric>
    <metric>list mean [visibility] of mimics</metric>
    <metric>list mean [visibility] of models</metric>
    <metric>list mean [prey-mean] of predators</metric>
    <enumeratedValueSet variable="carrying-capacity-mimics">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mimic-set-visibility?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="prey-range">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-other-food">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="base-visibility">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="prey-visibility-predator">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="carrying-capacity-models">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mutation-prey">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mutation-predator">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="visibility-model">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-in-prey">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="model-set-visibility?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="food-available">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="visibility-mimic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-chance">
      <value value="0.7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="model-dangerous?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="predator-set-visibility?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="carrying-capacity-predators">
      <value value="150"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="linearRandom" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="50000"/>
    <metric>count turtles</metric>
    <metric>count mimics</metric>
    <metric>count models</metric>
    <metric>count predators</metric>
    <metric>[visibility] of mimics</metric>
    <metric>[visibility] of models</metric>
    <metric>[prey-mean] of predators</metric>
    <metric>list mean [visibility] of mimics</metric>
    <metric>list mean [visibility] of models</metric>
    <metric>list mean [prey-mean] of predators</metric>
    <enumeratedValueSet variable="carrying-capacity-mimics">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mimic-set-visibility?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="prey-range">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-other-food">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="base-visibility">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="prey-visibility-predator">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="carrying-capacity-models">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mutation-prey">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mutation-predator">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="visibility-model">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-in-prey">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="model-set-visibility?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="food-available">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="visibility-mimic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-chance">
      <value value="0.7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="model-dangerous?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="predator-set-visibility?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="carrying-capacity-predators">
      <value value="150"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="ranran" repetitions="100" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="10005"/>
    <metric>median [visibility] of models</metric>
    <metric>median [visibility] of mimics</metric>
    <runMetricsCondition>ticks = 10000</runMetricsCondition>
    <enumeratedValueSet variable="carrying-capacity-mimics">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mimic-set-visibility?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="prey-range">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-other-food">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="base-visibility">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="prey-visibility-predator">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="carrying-capacity-models">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mutation-prey">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mutation-predator">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="visibility-model">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-in-prey">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="model-set-visibility?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="food-available">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="visibility-mimic">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-chance">
      <value value="0.7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="model-dangerous?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="predator-set-visibility?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="carrying-capacity-predators">
      <value value="150"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="fewmodels" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="50000"/>
    <metric>count turtles</metric>
    <metric>count mimics</metric>
    <metric>count models</metric>
    <metric>count predators</metric>
    <metric>[visibility] of mimics</metric>
    <metric>[visibility] of models</metric>
    <metric>[prey-mean] of predators</metric>
    <metric>list mean [visibility] of mimics</metric>
    <metric>list mean [visibility] of models</metric>
    <metric>list mean [prey-mean] of predators</metric>
    <enumeratedValueSet variable="carrying-capacity-mimics">
      <value value="600"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mimic-set-visibility?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="prey-range">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-other-food">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="base-visibility">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="prey-visibility-predator">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="carrying-capacity-models">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mutation-prey">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mutation-predator">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="visibility-model">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-in-prey">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="model-set-visibility?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="food-available">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="visibility-mimic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-chance">
      <value value="0.7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="model-dangerous?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="predator-set-visibility?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="carrying-capacity-predators">
      <value value="150"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
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
0
@#$#@#$#@

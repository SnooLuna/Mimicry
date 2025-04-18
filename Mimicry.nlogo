;; two breeds of prey
breed [ models model ]
breed [ mimics mimic ]
models-own [
  visibility
]
mimics-own [
  visibility
]

breed [ predators predator ]
predators-own [
  avoidance-mean
  energy
]

globals [
  color-range-begin               ;; "lowest" color for a prey
  color-range-end                 ;; "highest" color for a prey
]




;;
;; Setup Procedures
;;

to setup
  clear-all
  setup-variables
  setup-turtles
  reset-ticks
end

;; initialize constants
to setup-variables
  set color-range-begin 0
  set color-range-end 15
end

;; create 100 predators and 600 preys of which half are
;; models and half are mimics. Initially, the
;; models are at the middle of the color range and
;; the mimics are at the top of the color range.

to setup-turtles
  ask patches [ set pcolor 58.5 ]
  set-default-shape models       "ssnake"
  set-default-shape mimics       "cutesnake"
  set-default-shape predators    "hawk"

  create-predators carrying-capacity-predators                                       ;; create predators
  [
    set color brown
    set avoidance-mean  random-float 100
    set energy 200
    set size 3
  ]

  create-models carrying-capacity-models [                                           ;; create prey
    set color to-color 100
    set visibility from-color color
    set size 1.5
  ]
  create-mimics carrying-capacity-mimics [
    set color to-color 50
    set visibility from-color color
    set size 1.5
  ]

  ;; scatter all three breeds around the world
  ask turtles [ setxy random-xcor random-ycor ]
end




;;
;; Runtime Procedures
;;

to go
  ask predators [
    wiggle
  ]
  ;; turtles that are not predators are preys
  ask turtles with [breed != predators] [
    wiggle
    preys-get-eaten
    preys-reproduce
  ]

  ask predators [
    predators-age
    predators-reproduce
  ]

  tick
end

to wiggle ;; predator procedure
  rt random 100
  lt random 100
  fd 1
end


to preys-get-eaten  ;; prey procedure                                                      predator meets prey
  let predator-here one-of predators-here
  if predator-here != nobody [
    if [sees? myself] of predator-here [
      if [attacks? myself] of predator-here [
        ifelse breed = models [
          ask predator-here [ die ] ;; prey was poisonous
        ] [
          ask predator-here [ set energy energy + energy-in-prey]
        ]
        die                     ;; prey was attacked
      ]
    ]
  ]
end

;; does the predator see the prey?
to-report sees? [prey] ;; predator procedure
  if random-float 50 < ([visibility] of prey + 7)  ;; bottom 50% colors is camouflage
    [ report true ]
  report false
end

to-report attacks? [prey]
  let prey-visibility [visibility] of prey
  ;; probability of attack decreases as prey visibility gets closer to avoided range
  let dist abs (prey-visibility - avoidance-mean)
  if dist < avoidance-range [
    report true ;; avoid it
  ]
  report random-float 100 < 20 ;; EDIT false
end




;; Each prey has an equal chance of reproducing
;; depending on how close to carrying capacity the
;; population is.
;;                 from original model
to preys-reproduce ;; prey procedure                                                          prey evolution
  ifelse breed = models
  [ if random count models < carrying-capacity-models - count models
     [ hatch-prey ] ]
  [ if random count mimics < carrying-capacity-mimics - count mimics
     [ hatch-prey ] ]
end

to hatch-prey ;; prey procedure
  if random-float 100 < reproduction-chance
  [
    hatch 1
    [
      fd 1
      ;; the prey will have a color similar to its parent,
      ;; but this can mutate within a certain normal range.
      ;; mean = parent's color, sd = mutation-rate (slider)
      let parent-color [visibility] of myself
      set color to-color random-normal parent-color mutation-rate
      set visibility from-color color
    ]
 ]
end



to predators-age                                                                          ;; predator evolution
  set energy energy - 1
  if energy <= 0 [ die ]
end


;; Each predator has an equal chance of reproducing
;; depending on how close to carrying capacity the
;; population is.
;;                 from original model
to predators-reproduce ;; predator procedure
  if random count predators < carrying-capacity-predators - count predators
  [ hatch-predator ]
end

to hatch-predator ;; predator procedure
  if random-float 100 < reproduction-chance
  [

    hatch 1
    [
      fd 1
      set avoidance-mean  random-normal avoidance-mean avoidance-range / 2
    ]
    ; set energy energy / 2  ;; cost to reproduce
 ]
end






;; helper to report a random color within range                                                 helper productions
to-report random-color
  report random-float (color-range-end - color-range-begin) + color-range-begin
end

;; from visibility percentage to color
to-report to-color [value]
  ;; color needs to be within certain range
  if value > 100 [set value 100]
  if value < 0  [set value 0]

  ;; 0-100 -> 10-0+10-15 (white - black - red )
  set value value / 100 * 15
  if value < 10 [ set value abs (value - 9.99999999999) ]
  report value
end

;; from color to visibility percentage
to-report from-color [value]
  ;; color needs to be within certain range
  if value > 15 [set value 15]
  if value < 0  [set value 0]

  ;; white - black - red -> 0-100
  if value < 10 [ set value abs (value - 9.99999999999) ]
  set value value / 15 * 100
  report value
end

; Copyright 1997 Uri Wilensky.
; See Info tab for full copyright and license.
@#$#@#$#@
GRAPHICS-WINDOW
208
12
637
442
-1
-1
5.54
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
75
-75
0
1
1
1
ticks
30.0

BUTTON
10
196
98
229
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
100
196
188
229
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

SLIDER
11
236
188
269
mutation-rate
mutation-rate
0
100
13.0
1
1
NIL
HORIZONTAL

MONITOR
678
76
785
121
NIL
count models
0
1
11

MONITOR
790
343
861
388
maximum
max [visibility] of models
3
1
11

MONITOR
718
343
789
388
average
mean [visibility] of models
3
1
11

MONITOR
786
76
893
121
NIL
count mimics
0
1
11

MONITOR
790
389
861
434
maximum
max [visibility] of mimics
3
1
11

MONITOR
718
389
789
434
average
mean [visibility] of mimics
3
1
11

PLOT
655
122
932
342
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
"Models" 1.0 0 -2674135 true "" "plot mean [visibility] of models"
"Mimics" 1.0 0 -13345367 true "" "plot mean [visibility] of mimics"
"Predator" 1.0 0 -6459832 true "" "plot mean [avoidance-mean] of predators"

TEXTBOX
649
357
735
375
Model colors:
11
0.0
1

TEXTBOX
650
399
730
417
Mimic colors:
11
0.0
1

MONITOR
862
343
933
388
minimum
min [visibility] of models
3
1
11

MONITOR
862
389
933
434
minimum
min [visibility] of mimics
3
1
11

PLOT
122
449
322
599
Model Visibility
color / visibility
count
0.0
101.0
0.0
300.0
false
false
"" "histogram [visibility] of models\nset-plot-x-range 0 101"
PENS
"model color" 1.0 1 -16777216 true "" ""

PLOT
327
449
527
599
Mimic Visibility
color / visibility
count
0.0
101.0
0.0
300.0
false
false
"" "histogram [visibility] of mimics\nset-plot-x-range 0 101"
PENS
"Colubrid Colors" 1.0 1 -16777216 true "" ""

SLIDER
11
276
188
309
avoidance-range
avoidance-range
0
100
30.0
1
1
NIL
HORIZONTAL

PLOT
533
450
733
600
Predator mean avoidance color
color
count
0.0
10.0
0.0
10.0
true
false
"" "histogram [avoidance-mean] of predators\nset-plot-x-range 0 101"
PENS
"default" 1.0 1 -16777216 true "" ""

MONITOR
744
451
850
496
energy
mean [energy] of predators
17
1
11

MONITOR
680
28
784
73
count Predators
count predators
17
1
11

SLIDER
11
317
187
350
reproduction-chance
reproduction-chance
0
100
40.0
1
1
NIL
HORIZONTAL

SLIDER
11
358
187
391
reproduction-threshold
reproduction-threshold
0
1000
115.0
1
1
NIL
HORIZONTAL

SLIDER
8
10
187
43
carrying-capacity-mimics
carrying-capacity-mimics
0
600
552.0
1
1
NIL
HORIZONTAL

SLIDER
8
45
187
78
carrying-capacity-models
carrying-capacity-models
0
600
66.0
1
1
NIL
HORIZONTAL

SLIDER
8
81
187
114
carrying-capacity-predators
carrying-capacity-predators
0
300
179.0
1
1
NIL
HORIZONTAL

SLIDER
9
122
187
155
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
9
158
187
191
visibility-mimic
visibility-mimic
0
100
50.0
1
1
NIL
HORIZONTAL

SLIDER
11
399
187
432
energy-in-prey
energy-in-prey
0
200
40.0
1
1
NIL
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?

Batesian mimicry is an evolutionary relationship in which a harmless species (the mimic) has evolved so that it looks very similar to a completely different species that isn't harmless (the model).  A classic example of Batesian mimicry is the similar appearance of monarch butterflies and viceroy moths. Monarchs and viceroys are unrelated species that are both colored similarly --- bright orange with black patterns. Their colorations are so similar, in fact, that the two species are virtually indistinguishable from one another.

The classic explanation for this phenomenon is that monarchs taste yucky.  Because monarchs eat milkweed, a plant full of toxins, they become essentially inedible to birds.  Researchers have documented birds vomiting within minutes of eating monarch butterflies.  The birds then remember the experience and avoid brightly colored orange butterfly/moth species.  Viceroys, although perfectly edible, avoid predation if they are colored bright orange because birds can't tell the difference.

Recent research now suggests that viceroys might also be unpalatable to bird predators, confusing this elegant explanation.  However, we have modeled the relationship anyway.  Batesian mimicry occurs in enough other situations (snakes, for example) that the explanation's general truth is unquestionable.  The monarch-viceroy story is so accessible --- and historically relevant --- that we believe it to be instructive even if its accuracy is now questioned.

## HOW IT WORKS

This model simulates the evolution of monarchs and viceroys from distinguishable, differently colored species to indistinguishable mimics and models.  At the simulation's beginning there are 450 monarchs and viceroys distributed randomly across the world.  The monarchs are all colored red, while the viceroys are all colored blue.  They are also distinguishable (to the human observer only) by their shape:  the letter "x" represents monarchs while the letter "o" represents viceroys.  Seventy-five birds are also randomly distributed across the world.

When the model runs, the birds and butterflies (for the remainder of this description "butterfly" will be used as a general term for monarchs and viceroys, even though viceroys are technically moths) move randomly across the world.  When a bird encounters a butterfly it eats the butterfly, unless it has a memory that the butterfly's color is "yucky."  If a bird eats a monarch, it acquires a memory of the butterfly's color as yucky.

As butterflies are eaten, they regenerate through asexual reproduction. Each turn, every butterfly must pass two "tests" in order to reproduce.  The first test is based on how many butterflies of that species already exist in the world. The carrying capacity of the world for each species is 225.  The chances of reproducing are smaller the closer to 225 each population gets.  The second test is simply a random test to keep reproduction in check (set to a 4% chance in this model).  When a butterfly does reproduce it either creates an offspring identical to itself or it creates a mutant.  Mutant offspring are the same species but have a random color between blue and red, but ending in five (e.g. color equals 15, 25, 35, 45, 55, 65, 75, 85, 95, 105).  Both monarchs and Viceroys have equal opportunities to reproduce mutants.

Birds can remember up to MEMORY-SIZE yucky colors at a time.  The default value is three.  If a bird has memories of three yucky colors and it eats a monarch with a new yucky color, the bird "forgets" its oldest memory and replaces it with the new one.  Birds also forget yucky colors after a certain amount of time.

## HOW TO USE IT

Each turn is called a TICK in this model.

The MEMORY-DURATION slider determines how long a bird can remember a color as being yucky.  The MEMORY-SIZE slider determines the number of memories a bird can hold in its memory at once.

The MUTATION-RATE slider determines the chances that a butterfly's offspring will be a mutant.  Setting the slider to 100 will make every offspring a mutant.  Setting the slider to 0 will make no offspring a mutant.

The SETUP button clears the world and randomly distributes the monarchs (all red), viceroys (all blue), and birds.  The GO button starts the simulation.

The number of monarchs and viceroys in the world are displayed in monitor as well as the maximum, minimum, and average colors for each type of butterfly.

The plot shows the average color of the monarchs and the average color of the viceroys plotted against time.

## THINGS TO NOTICE

Initially, the birds don't have any memory, so both monarchs and viceroys are eaten equally. However, soon the birds "learn" that red is a yucky color and this protects most of the monarchs.  As a result, the monarch population makes a comeback toward carrying capacity while the viceroy population continues to decline.  Notice also that as reproduction begins to replace eaten butterflies, some of the replacements are mutants and therefore randomly colored.

As the simulation progresses, birds continue to eat mostly butterflies that aren't red.  Occasionally, of course, a bird "forgets" that red is yucky, but a forgetful bird is immediately reminded when it eats another red monarch.  For the unlucky monarch that did the reminding, being red was no advantage, but every other red butterfly is safe from that bird for a while longer.  Monarch (non-red) mutants are therefore apt to be eaten.  Notice that throughout the simulation the average color of monarchs continues to be very close to its original value of 15.  A few mutant monarchs are always being born with random colors, but they never become dominant, as they and their offspring have a slim chance for survival.

Meanwhile, as the simulation continues, viceroys continue to be eaten, but as enough time passes, the chances are good that some viceroys will give birth to red mutants.  These butterflies and their offspring are likely to survive longer because they resemble the red monarchs.  With a mutation rate of 5%, it is likely that their offspring will be red too.  Soon most of the viceroy population is red.  With its protected coloration, the viceroy population will return to carrying capacity.

## THINGS TO TRY

If the MUTATION-RATE is high, advantageous color genes do not reproduce themselves.  Conversely, if MUTATION-RATE is too low, the chances of an advantageous mutant (red) viceroy being born are so slim that it may not happen enough, and the population may go extinct.  What is the most ideal setting for the MUTATION-RATE slider so that a stable state emerges most quickly in which there are red monarchs and viceroys co-existing in the world?  Why?

If the MEMORY-LENGTH slider is set too low, birds are unable to remember that certain colors are yucky.  How low can the MEMORY-LENGTH slider be set so that a stable state of co-existing red monarchs and viceroys emerges?

If you set MUTATION-RATE to 100 and MEMORY to 0, you will soon have two completely randomly colored populations.  Once the average color of both species is about 55, return the sliders to MUTATION-RATE equals 16 and MEMORY equals 30 without resetting the model.  Does a stable mimicry state emerge?  What is the "safe" color?

## EXTENDING THE MODEL

One very simple extension to this model is to add a RANDOM-COLOR button.  This button would give every butterfly in the world a random color.  The advantage of red would be gone, but some color (which could be red, or any other color) would eventually emerge as the advantageous color.  This models the evolutionary process from an earlier starting place, presumably when even monarchs had different colors.

It would be interesting to see what would happen if birds were made smarter than they are in this model.  A smart bird should probably continue to experiment with yucky colors a few times before being "convinced" that all butterflies of that color are indeed distasteful.

You could try to add variables that kept track of how many yucky individuals of the same color a bird ate.  Presumably if a bird has eaten several monarchs that are all the same color, it will be especially attentive to avoiding that color as compared to if it had just eaten one butterfly of that color.  Making changes of this nature would presumably make the proportion of models and mimics more in keeping with the predictions of theorists that there are generally more models than mimics.  In the current model, birds aren't smart enough to learn that most butterflies may be harmless in a given situation.

In a real world situation, the birds would also reproduce.  Young birds would not have the experiences necessary to know which colors to avoid.  Reproduction of birds, depending on how it happened and how often, might change the dynamics of this model considerably.

One could also refine the mutation-making procedures of the model so that a butterfly is more likely to reproduce a mutant that is only slightly differently colored than to reproduce a mutant that is completely differently colored.  In the current model, mutants' colors are simply random.

## HOW TO CITE

If you mention this model or the NetLogo software in a publication, we ask that you include the citations below.

For the model itself:

* Wilensky, U. (1997).  NetLogo Mimicry model.  http://ccl.northwestern.edu/netlogo/models/Mimicry.  Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

Please cite the NetLogo software as:

* Wilensky, U. (1999). NetLogo. http://ccl.northwestern.edu/netlogo/. Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

## COPYRIGHT AND LICENSE

Copyright 1997 Uri Wilensky.

![CC BY-NC-SA 3.0](http://ccl.northwestern.edu/images/creativecommons/byncsa.png)

This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 License.  To view a copy of this license, visit https://creativecommons.org/licenses/by-nc-sa/3.0/ or send a letter to Creative Commons, 559 Nathan Abbott Way, Stanford, California 94305, USA.

Commercial licenses are also available. To inquire about commercial licenses, please contact Uri Wilensky at uri@northwestern.edu.

This model was created as part of the project: CONNECTED MATHEMATICS: MAKING SENSE OF COMPLEX PHENOMENA THROUGH BUILDING OBJECT-BASED PARALLEL MODELS (OBPML).  The project gratefully acknowledges the support of the National Science Foundation (Applications of Advanced Technologies Program) -- grant numbers RED #9552950 and REC #9632612.

This model was converted to NetLogo as part of the projects: PARTICIPATORY SIMULATIONS: NETWORK-BASED DESIGN FOR SYSTEMS LEARNING IN CLASSROOMS and/or INTEGRATED SIMULATION AND MODELING ENVIRONMENT. The project gratefully acknowledges the support of the National Science Foundation (REPP & ROLE programs) -- grant numbers REC #9814682 and REC-0126227. Converted from StarLogoT to NetLogo, 2001.

<!-- 1997 2001 -->
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

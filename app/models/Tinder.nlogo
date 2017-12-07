extensions [ nw ]
globals [ is-first-swipe male-swipes female-swipes total-male-swipes total-female-swipes ]

turtles-own [
  sex
  sex-pref
  attractiveness
]

to setup
  clear-all
  set is-first-swipe 1
  set male-swipes 0
  set female-swipes 0
  set total-male-swipes 0
  set total-female-swipes 0
  set-default-shape turtles "person"
  create-users
  set-attractiveness
  reset-ticks
end

to create-users
  ;; create a random network
  nw:generate-random turtles links population 1 [
    setxy round random-xcor round random-ycor
    ;; 1 = male, 0 = female

    ifelse random 100 < male-population-percentage [
      ;; set males
      set sex 1
      set sex-pref 0 ;; set heteros
      if random 100 < gay-population-percentage [
        set sex-pref 1
      ]
    ] [
      ;; set females
      set sex 0
      set sex-pref 1 ;; set heteros
      if random 100 < lesb-population-percentage [
        set sex-pref 0
      ]
    ]
    set color ifelse-value (sex = 1) [blue] [red]
    set pcolor ifelse-value (sex-pref = 1) [blue - 2] [red - 2]
    ask my-links [hide-link]
  ]
end

;; set attractiveness for each user as normally distributed values
to set-attractiveness
  ;; mean
  let m 50.0
  ;; sigma
  let s 50.0 / 3.0

  ;; generate random number (mostly) in the range 0.0 to 100.0, centered at 50.0
  ask turtles [
    set attractiveness random-normal m s
  ]

  ;; set turtles with attractiveness below minimum to 0.0
  ask turtles with [attractiveness < 0.0] [
    set attractiveness 0.0
  ]

  ;; set turtles with attractiveness above maximum to 100.0
  ask turtles with [attractiveness > 100.0] [
    set attractiveness 100.0
  ]
end

to go
  remove-gender-conflicts
  ;; repeat the process until every turtle is matched with either 1 or no other turtle
  while [any? turtles with [count my-links > 1]] [
    swipe
    set is-first-swipe 0 ;; marks the end of phase 1 (swiping)
    tick
  ]

  ask turtles [ ask my-links [ show-link ] ]
  find-happy
  find-sad
  print "--------------"
  print male-swipes
  print total-male-swipes
  print 1.0 * male-swipes / total-male-swipes
  print "--------------"
  print female-swipes
  print total-female-swipes
  print 1.0 * female-swipes / total-female-swipes
  print "--------------"
end

to remove-gender-conflicts
  ;; iterate through each person and remove straight-gay links
  ask turtles [
    ask my-links with [[sex] of other-end != [sex-pref] of myself] [
      die
    ]
  ]
end

to swipe
  ;; swiping will be based on closeness to attractiveness level

  ;; at male-base-swipe-probability ~= 63 and female-base-swipe-probability ~= 30
  ;; the resulting swipe percentage for both male and female matches those according to the stats
  ;; 46%  for male, 1% for female


  ;; variables to store attractiveness of each turtle pair
  let a1 0.0
  let a2 0.0


  let base-swipe-probability 0.0
  let s 0
  ask turtles [
    ;; set the base probability based on gender and preference
    ifelse sex-pref != sex [
      set base-swipe-probability (male-base-swipe-probability * 1.0)

      if sex = 0 [
        set base-swipe-probability (female-base-swipe-probability * 1.0)
      ]
    ] [
      set base-swipe-probability (gay-base-swipe-probability * 1.0)
      if sex = 0 [
        set base-swipe-probability (lesb-base-swipe-probability * 1.0)
      ]
    ]

    set s sex
    ask my-links [
      ask end1 [
        set a1 attractiveness
      ]

      ask end2 [
        set a2 attractiveness
      ]

      if is-first-swipe = 1 [
        ifelse s = 0 [
          set total-female-swipes total-female-swipes + 1
        ] [
          set total-male-swipes total-male-swipes + 1
        ]
      ]


      ;; the chance of rejecting (terminating a link) is base-swipe-probability% minus the absolute difference of attractiveness
      ;; therefore the higher the gap between the attractiveness of the pair, the lower the chance of keeping the link
      ifelse (random-float 100.0) > (base-swipe-probability - (abs (a1 - a2)))[
        die
      ] [
        if is-first-swipe = 1 [
          ifelse s = 0 [
            set female-swipes (female-swipes + 1)
          ] [
            set male-swipes (male-swipes + 1)
          ]
        ]
      ]
    ]
  ]
end

to find-happy
  ask turtles with [count my-links = 1] [
    set shape "face happy"
  ]
end

to find-sad
  ask turtles with [count my-links = 0] [
    set shape "face sad"
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
285
11
982
709
-1
-1
10.6
1
10
1
1
1
0
0
0
1
-32
32
-32
32
0
0
1
ticks
30.0

BUTTON
18
21
81
54
NIL
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
87
21
150
54
NIL
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
1059
240
1268
285
Percent of population with matches
count (turtles with [count my-links != 0]) / population * 100.0
2
1
11

PLOT
999
10
1353
229
plot 1
ticks
percent with matches
0.0
10.0
0.0
100.0
true
true
"" ""
PENS
"pen-0" 1.0 0 -7500403 true "" "plot count (turtles with [count my-links != 0]) / count (turtles) * 100.0"

SLIDER
18
118
224
151
male-population-percentage
male-population-percentage
0
100
62.0
1
1
NIL
HORIZONTAL

SLIDER
18
280
223
313
male-base-swipe-probability
male-base-swipe-probability
0
100
63.0
1
1
NIL
HORIZONTAL

SLIDER
18
318
236
351
female-base-swipe-probability
female-base-swipe-probability
0
100
30.0
1
1
NIL
HORIZONTAL

MONITOR
1005
562
1145
607
Male swipe percentage
male-swipes / total-male-swipes
17
1
11

MONITOR
1165
562
1319
607
Female swipe percentage
female-swipes / total-female-swipes
17
1
11

BUTTON
156
21
265
54
setup then go
setup\ngo
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
18
79
190
112
population
population
10
500
300.0
10
1
NIL
HORIZONTAL

MONITOR
1005
506
1153
551
Straight people matched
count (turtles with [count my-links != 0 and sex-pref != sex])
2
1
11

MONITOR
1165
506
1291
551
Gay people matched
count (turtles with [count my-links != 0 and sex-pref = sex])
2
1
11

SLIDER
18
180
219
213
gay-population-percentage
gay-population-percentage
0
100
20.0
1
1
NIL
HORIZONTAL

SLIDER
17
383
264
416
gay-base-swipe-probability
gay-base-swipe-probability
0
100
30.0
1
1
NIL
HORIZONTAL

SLIDER
17
422
268
455
lesb-base-swipe-probability
lesb-base-swipe-probability
0
100
63.0
1
1
NIL
HORIZONTAL

SLIDER
18
218
275
251
lesb-population-percentage
lesb-population-percentage
0
100
20.0
1
1
NIL
HORIZONTAL

MONITOR
1169
300
1238
345
Females
count (turtles with [sex = 0])
17
1
11

MONITOR
1006
301
1063
346
Males
count (turtles with [sex = 1])
17
1
11

MONITOR
1005
424
1062
469
Gays
count (turtles with [sex = 1 and sex-pref = 1])
17
1
11

MONITOR
1169
425
1241
470
Lesbians
count (turtles with [sex = 0 and sex-pref = 0])
17
1
11

MONITOR
1006
376
1114
421
Straight Males
count (turtles with [sex = 1 and sex-pref = 0])
17
1
11

MONITOR
1169
377
1294
422
Straight Females
count (turtles with [sex = 0 and sex-pref = 1])
17
1
11

@#$#@#$#@
## WHAT IS IT?

This model is a prototype of the Tinder usage model. This model will simply generate a network of people (each link representing a potential match), and each person will randomly swipe left (reject) or swipe right (accept) the other. If both persons accept, the link stays; otherwise, the link is broken.

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
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

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

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

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.0.1
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

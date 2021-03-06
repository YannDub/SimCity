; Pr Philippe MATHIEU - CRISTAL - Univ Lille1
;
;
globals [ mouse-was-down? maison-entree usine-entree maison-sortie usine-sortie]

breed [maisons maison]
breed [usines usine]
breed [cars car]
breed [electricals electrical]
breed [electrons electron]
breed [watertowers watertower]
breed [waters water]

maisons-own[max_capacity current_capacity current_elec max_elec current_water max_water ttl]
usines-own[max_capacity current_capacity current_elec max_elec current_water max_water ttl]
electrons-own[current_capacity ttl]
waters-own[current_capacity ttl]

to-report mouse-clicked?
  report (mouse-was-down? = true and not mouse-down?)
end

to init
  set heading 90 * random 4
end

to make-roads
  clear-all
  crt 1 [ init ]
  reset-ticks
  ask patches [set pcolor green]
  while [count turtles > 0]
    [ ask turtles [ build ]
      tick
    ]
end

to build
  if pcolor = black [die]
  set pcolor black
  let h heading
  ifelse (not any? (patch-set (patch-at-heading-and-distance (h + 90) 1) (patch-at-heading-and-distance (h - 90) 1)) with [pcolor = black])
    [ if (random 100 < proba-turn)
      [ if (random 100 < proba-continue)
        [ hatch 1 [ fd 1 ]]
      ifelse (random 1 = 0) [ left 90 ] [ right 90 ] ]
  fd 1
  ]
    [ ifelse (random 1 = 0) [ left 90 ] [ right 90 ]]
end

to setup
  reset-ticks
  set-default-shape watertowers "house"
  set-default-shape electricals "house"
  set-default-shape maisons "house"
  set-default-shape usines "house"
  set-default-shape cars "car"
  set-default-shape electrons "star"
  set-default-shape waters "star"
  ;create-cars nb-cars [  init-car ]
end

to init-maison
  set size 2
  set ttl ttl_bat
  set color red
  set max_capacity (1 + random max_people_house)
  set current_capacity max_capacity
  set current_elec max_electricity
  set max_elec max_electricity
  set current_water max_water_capacity
  set max_water max_water_capacity
end

to init-usine
  set size 2
  set ttl ttl_bat
  set color orange
  set max_capacity (15 + random max_people_usine)
  set current_elec max_electricity
  set max_elec max_electricity
  set current_water max_water_capacity
  set max_water max_water_capacity
end

to init-electrical
  set size 2
  set color yellow
end

to init-watertower
  set size 2
  set color cyan
end

to init-car
  set size 2
  face one-of neighbors4 with [pcolor = black]
  set label ""
end

to init-electron
  set size 1
  set ttl ttl_elec
  face one-of neighbors4 with [pcolor = black]
  set label ""
end

to init-water
  set size 1
  set ttl ttl_water
  face one-of neighbors4 with [pcolor = black]
  set label ""
end

to mouse-manager
  let mouse-is-down? mouse-down?
  if mouse-clicked? [
    click
  ]
  set mouse-was-down? mouse-is-down?
end

to click
  if ([pcolor] of (patch mouse-xcor mouse-ycor) = cyan) [
    ask watertowers-on (patch mouse-xcor mouse-ycor) [die]
    ask patch mouse-xcor mouse-ycor [set pcolor green]
  ]

  if ([pcolor] of (patch mouse-xcor mouse-ycor) = yellow) [
    ask electricals-on (patch mouse-xcor mouse-ycor) [die]
    create-watertowers 1 [init-watertower setxy mouse-xcor mouse-ycor]
    ask patch mouse-xcor mouse-ycor [set pcolor cyan]
  ]

  if ([pcolor] of (patch mouse-xcor mouse-ycor) = orange) [
    ask usines-on (patch mouse-xcor mouse-ycor) [die]
    create-electricals 1 [init-electrical setxy mouse-xcor mouse-ycor]
    ask patch mouse-xcor mouse-ycor [set pcolor yellow]
  ]

  if ([pcolor] of (patch mouse-xcor mouse-ycor) = red) [
    ask maisons-on (patch mouse-xcor mouse-ycor) [killPeople die]
    create-usines 1 [init-usine setxy mouse-xcor mouse-ycor]
    ask patch mouse-xcor mouse-ycor [set pcolor orange]
  ]

  if ([pcolor] of (patch mouse-xcor mouse-ycor) = green) [
    ifelse (count ([neighbors4] of patch mouse-xcor mouse-ycor) with [pcolor = black] > 0) [
      create-maisons 1 [init-maison setxy mouse-xcor mouse-ycor]
      ask patch mouse-xcor mouse-ycor [set pcolor red]
    ] [
      crt 1 [setxy mouse-xcor mouse-ycor set color pink set shape "tree" set size 2]
    ]
  ]
end

to go
  ask cars [advance2]
  ask electrons [advanceElectron]
  ask waters [advanceWater]

  ask maisons with [current_capacity > 0] [if ((random maison-sortie) = 0) [generate_cars]]
  ask usines with [current_capacity > 0] [if ((random usine-sortie) = 0) [generate_cars]]
  ask electricals [if ((ticks mod 30) = 0) [generate_electrons]]
  ask watertowers [if ((ticks mod 30) = 0) [generate_waters]]

  ask maisons with [current_elec > 0] [decreaseElectron]
  ask usines with [current_elec > 0] [decreaseElectron]
  ask maisons with [current_water > 0] [decreaseWater]
  ask usines with [current_water > 0] [decreaseWater]

  ask maisons with [ttl <= 0] [killPeople ask patch-here [set pcolor green] die]
  ask usines with [ttl <= 0] [ask patch-here [set pcolor green] die]

  ask maisons with [current_elec = 0] [set ttl (ttl - 1)]
  ask usines with [current_elec = 0] [set ttl (ttl - 1)]
  ask maisons with [current_water = 0] [set ttl (ttl - 1)]
  ask usines with [current_water = 0] [set ttl (ttl - 1)]

  ask maisons with [current_elec > 0 and current_water > 0] [set ttl ttl_bat]

  mouse-manager

  if ((ticks mod 12000) <= 119999) [
    set maison-entree 1
    set maison-sortie 9000
    set usine-entree 9000
    set usine-sortie 1
  ]

  if ((ticks mod 12000) <= 8000) [
    set maison-entree 20
    set maison-sortie 100
    set usine-entree 9000
    set usine-sortie 5
  ]

  if ((ticks mod 12000) <= 6000) [
    set maison-entree 50
    set maison-sortie 50
    set usine-entree 100
    set usine-sortie 9000
  ]

  if ((ticks mod 12000) <= 2000) [
    set maison-entree 200
    set maison-sortie 5
    set usine-entree 1
    set usine-sortie 9000
  ]

  ask maisons [set label (word current_capacity "/" max_capacity)]
  ask usines [set label (word current_capacity "/" max_capacity)]
  tick
end

to generate_cars
  hatch-cars 1 [init-car setxy xcor ycor set color one-of base-colors]
  set current_capacity (current_capacity - 1)
end

to generate_electrons
  hatch-electrons 1 [init-electron setxy xcor ycor set color yellow set current_capacity 1000]
end

to generate_waters
  hatch-waters 1 [init-water setxy xcor ycor set color cyan set current_capacity 1000]
end

to decreaseElectron
  set current_elec (current_elec - 1 - current_capacity)
end

to decreaseWater
  set current_water (current_water - 1 - current_capacity)
end

to advance
  let f (patch-set (patch-ahead 1)) with [pcolor = black]
  let r (patch-set (patch-at-heading-and-distance (heading + 90) 1)) with [pcolor = black]
  let l (patch-set (patch-at-heading-and-distance (heading - 90) 1)) with [pcolor = black]
  ifelse (not any? (patch-set f r l))
    [ right 180 ]
    [ move-to one-of (patch-set f r l)
      ifelse ((patch-set patch-here) =  r) [right 90]
        [ if ((patch-set patch-here) =  l) [left 90] ]]
end

to advance2
  let f patch-ahead 1
  let r patch-at-heading-and-distance (heading + 90) 1
  let l patch-at-heading-and-distance (heading - 90) 1
  ifelse (not any? ((patch-set f r l) with [pcolor = black]))
    [ right 180 ]
    [ move-to one-of ((patch-set f r l) with [pcolor = black])
      ifelse (patch-here =  r) [right 90]
        [ if (patch-here =  l) [left 90] ]]

  let m one-of maisons with [patch-here = l]
  ifelse ([pcolor] of l = red) and (random maison-entree = 0) and (([current_capacity] of m) < ([max_capacity] of m)) [
    ask m [set current_capacity (current_capacity + 1)]
    die
  ] [
    set m one-of maisons with [patch-here = r]
    if ([pcolor] of r = red) and (random maison-entree = 0) and (([current_capacity] of m) < ([max_capacity] of m)) [
      ask m [set current_capacity (current_capacity + 1)]
      die
    ]
  ]

  let u one-of usines with [patch-here = l]
  ifelse ([pcolor] of l = orange) and (random usine-entree = 0) and (([current_capacity] of u) < ([max_capacity] of u)) [
    ask u [set current_capacity (current_capacity + 1)]
    die
  ] [
    set u one-of usines with [patch-here = r]
    if ([pcolor] of r = orange) and (random usine-entree = 0) and (([current_capacity] of u) < ([max_capacity] of u)) [
      ask u [set current_capacity (current_capacity + 1)]
      die
    ]
  ]


end

to killPeople
  ifelse count cars >= (max_capacity - current_capacity) [
    ask n-of (max_capacity - current_capacity) cars [die]
  ] [
    let diff (max_capacity - current_capacity - count cars)
    ask cars [die]
    ask (n-of 1 usines with [current_capacity > diff]) [set current_capacity (current_capacity - diff)]
  ]
end

to advanceElectron
  let f patch-ahead 1
  let r patch-at-heading-and-distance (heading + 90) 1
  let l patch-at-heading-and-distance (heading - 90) 1
  ifelse (not any? ((patch-set f r l) with [pcolor = black]))
    [ right 180 ]
    [ move-to one-of ((patch-set f r l) with [pcolor = black])
      ifelse (patch-here =  r) [right 90]
        [ if (patch-here =  l) [left 90] ]]

  set ttl (ttl - 1)
  if ((ttl = 0) or (current_capacity = 0)) [die]

  let m one-of maisons with [patch-here = l]

  ifelse ([pcolor] of l = red) and (([current_elec] of m) < ([max_elec] of m)) [
    ifelse (current_capacity > (([max_elec] of m) - ([current_elec] of m))) [
      set current_capacity (current_capacity - (([max_elec] of m) - ([current_elec] of m)))
      ask m [set current_elec max_elec]
    ] [
      let elec current_capacity
      set current_capacity 0
      ask m [set current_elec (current_elec + elec)]
      die
    ]
  ] [
    set m one-of maisons with [patch-here = r]
    if ([pcolor] of r = red) and (([current_elec] of m) < ([max_elec] of m)) [
      ifelse (current_capacity > (([max_elec] of m) - ([current_elec] of m))) [
        set current_capacity (current_capacity - (([max_elec] of m) - ([current_elec] of m)))
        ask m [set current_elec max_elec]
      ] [
        let elec current_capacity
        set current_capacity 0
        ask m [set current_elec (current_elec + elec)]
        die
      ]
    ]
  ]

  let u one-of usines with [patch-here = l]
  ifelse ([pcolor] of l = orange) and (([current_elec] of u) < ([max_elec] of u)) [
    ifelse (current_capacity > (([max_elec] of u) - ([current_elec] of u))) [
      set current_capacity (current_capacity - (([max_elec] of u) - ([current_elec] of u)))
      ask u [set current_elec max_elec]
    ] [
      let elec current_capacity
      set current_capacity 0
      ask u [set current_elec (current_elec + elec)]
      die
    ]
  ] [
    set u one-of usines with [patch-here = r]
    if ([pcolor] of r = orange) and (([current_elec] of u) < ([max_elec] of u)) [
      ifelse (current_capacity > (([max_elec] of u) - ([current_elec] of u))) [
        set current_capacity (current_capacity - (([max_elec] of u) - ([current_elec] of u)))
        ask u [set current_elec max_elec]
      ] [
        let elec current_capacity
        set current_capacity 0
        ask u [set current_elec (current_elec + elec)]
        die
      ]
    ]
  ]
end

to advanceWater
  let f patch-ahead 1
  let r patch-at-heading-and-distance (heading + 90) 1
  let l patch-at-heading-and-distance (heading - 90) 1
  ifelse (not any? ((patch-set f r l) with [pcolor = black]))
    [ right 180 ]
    [ move-to one-of ((patch-set f r l) with [pcolor = black])
      ifelse (patch-here =  r) [right 90]
        [ if (patch-here =  l) [left 90] ]]

  set ttl (ttl - 1)
  if ((ttl = 0) or (current_capacity = 0)) [die]

  let m one-of maisons with [patch-here = l]

  ifelse ([pcolor] of l = red) and (([current_water] of m) < ([max_water] of m)) [
    ifelse (current_capacity > (([max_water] of m) - ([current_water] of m))) [
      set current_capacity (current_capacity - (([max_water] of m) - ([current_water] of m)))
      ask m [set current_water max_water]
    ] [
      let w current_capacity
      set current_capacity 0
      ask m [set current_water (current_water + w)]
      die
    ]
  ] [
    set m one-of maisons with [patch-here = r]
    if ([pcolor] of r = red) and (([current_water] of m) < ([max_water] of m)) [
      ifelse (current_capacity > (([max_water] of m) - ([current_water] of m))) [
        set current_capacity (current_capacity - (([max_water] of m) - ([current_water] of m)))
        ask m [set current_water max_water]
      ] [
        let w current_capacity
        set current_capacity 0
        ask m [set current_elec (current_water + w)]
        die
      ]
    ]
  ]

  let u one-of usines with [patch-here = l]
  ifelse ([pcolor] of l = orange) and (([current_water] of u) < ([max_water] of u)) [
    ifelse (current_capacity > (([max_water] of u) - ([current_water] of u))) [
      set current_capacity (current_capacity - (([max_water] of u) - ([current_water] of u)))
      ask u [set current_water max_water]
    ] [
      let w current_capacity
      set current_capacity 0
      ask u [set current_water (current_water + w)]
      die
    ]
  ] [
    set u one-of usines with [patch-here = r]
    if ([pcolor] of r = orange) and (([current_water] of u) < ([max_water] of u)) [
      ifelse (current_capacity > (([max_water] of u) - ([current_water] of u))) [
        set current_capacity (current_capacity - (([max_water] of u) - ([current_water] of u)))
        ask u [set current_water max_water]
      ] [
        let w current_capacity
        set current_capacity 0
        ask u [set current_water (current_water + w)]
        die
      ]
    ]
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
955
2
1556
604
-1
-1
4.901
1
10
1
1
1
0
1
1
1
-60
60
-60
60
0
0
1
ticks
30.0

SLIDER
23
130
195
163
proba-turn
proba-turn
0
30
6.0
1
1
%
HORIZONTAL

SLIDER
26
179
198
212
proba-continue
proba-continue
0
100
69.0
1
1
%
HORIZONTAL

BUTTON
30
18
136
51
NIL
make-roads
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
135
84
198
117
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
30
365
515
694
plot 1
time
people
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"nbCars" 1.0 0 -13791810 true "" "plot count cars"
"nbWorker" 1.0 0 -2674135 true "" "plot sum [current_capacity] of usines"

BUTTON
27
84
93
117
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

SLIDER
236
29
430
62
max_people_house
max_people_house
0
8
5.0
1
1
NIL
HORIZONTAL

SLIDER
249
78
428
111
max_people_usine
max_people_usine
1
50
40.0
1
1
NIL
HORIZONTAL

SLIDER
254
132
426
165
max_electricity
max_electricity
50
5000
1000.0
1
1
NIL
HORIZONTAL

SLIDER
242
187
442
220
max_water_capacity
max_water_capacity
50
5000
1000.0
1
1
NIL
HORIZONTAL

SLIDER
504
29
676
62
ttl_elec
ttl_elec
0
1000
306.0
1
1
NIL
HORIZONTAL

SLIDER
507
88
679
121
ttl_water
ttl_water
0
1000
306.0
1
1
NIL
HORIZONTAL

SLIDER
507
143
679
176
ttl_bat
ttl_bat
0
1000
100.0
1
1
NIL
HORIZONTAL

PLOT
525
365
947
694
Demographie
time
people
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"people" 1.0 0 -16777216 true "" "plot sum [current_capacity] of maisons + sum [current_capacity] of usines + count cars"

PLOT
518
22
946
354
Energy
time
amount
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"electricity" 1.0 0 -2674135 true "" "plot sum [current_capacity] of electrons"
"water" 1.0 0 -13791810 true "" "plot sum [current_capacity] of waters"

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

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
0
Rectangle -7500403 true true 151 225 180 285
Rectangle -7500403 true true 47 225 75 285
Rectangle -7500403 true true 15 75 210 225
Circle -7500403 true true 135 75 150
Circle -16777216 true false 165 76 116

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
Polygon -7500403 true true 135 285 195 285 270 90 30 90 105 285
Polygon -7500403 true true 270 90 225 15 180 90
Polygon -7500403 true true 30 90 75 15 120 90
Circle -1 true false 183 138 24
Circle -1 true false 93 138 24

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.0.2
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

module Collision
    ( demo
    ) where

import Random

type Unit = {x : Float, y : Float, r : Float, w : Float, rgba : Color}

everyTen : Signal Int
everyTen = sampleOn (every (8 * second)) (constant 20)

genUnits : Signal [Unit]
genUnits = 
    map (\(x,y,r,g,b) -> 
            {x = x * 400 - 200
            , y = y * 400 - 200
            , r = 16, w = 1
            , rgba = rgba (floor <| 255 * r) (floor <| 255 * g) (floor <| 255 * b) 0.8}) <~
    (zip5 <~ Random.floatList everyTen 
           ~ Random.floatList everyTen 
           ~ Random.floatList everyTen 
           ~ Random.floatList everyTen 
           ~ Random.floatList everyTen)

zip5 xs1 xs2 xs3 xs4 xs5 = case (xs1,xs2,xs3,xs4,xs5) of
    (a::az,b::bz,c::cz,d::dz,e::ez) -> (a,b,c,d,e) :: zip5 az bz cz dz ez
    _ -> []

collideUnits : Signal [Unit]
collideUnits = 
    foldp (\randUnits xs -> case randUnits of
        [] -> map (\a -> moveXY a (0,0) 1 (filter (touching a) xs)) xs
        xs -> map (\a -> moveXY a (0,0) 1 (filter (touching a) xs)) xs 
    ) [] (merge (sampleOn (every (5 * second)) genUnits) <| sampleOn (fps 30) (constant []))

-- Are 2 units touching?
touching : Unit -> Unit -> Bool
touching a b = (a.x - b.x)^2 + (a.y - b.y)^2 <= (a.r + b.r)^2

moveXY :
    Unit -> -- Entity being moved
    (Float,Float) -> -- Desination
    Float -> -- Distance to move
    [Unit] -> -- Entities in range
    Unit -- New coordinates for entity
moveXY a (dx,dy) dist nearby = 
    let inRange = filter (\b -> touching a b && b /= a) nearby in
    let len = length inRange in
    let push = foldl
            (\(aox,aoy) (box,boy) -> (aox+box,aoy+boy)) (0,0) <| map (\b -> 
                let (xDif,yDif) = (a.x-b.x,a.y-b.y) in
                let wDif = (a.w + b.w) / (2 * a.w) / toFloat (len + 1) in
                let rDif = (a.r + b.r) - (sqrt <| xDif^2 + yDif^2) in
                let angl = atan2 yDif xDif in
                (cos angl * rDif * wDif, sin angl * rDif * wDif)
            ) inRange in
    let newXY (ox,oy) = 
            if len < 6 then 
                let angl = atan2 (dy - a.y) (dx - a.x)
                    rDif = min (sqrt <| (dy - a.y)^2 + (dx - a.x)^2) dist
                in 
                    (a.x + ox + cos angl * rDif, a.y + oy + sin angl * rDif)
            else 
                (a.x + ox, a.y + oy) in
    let (nx,ny) = newXY push in
    {a | x <- nx, y <- ny} 

demo : Signal Element
demo = color (rgb 255 255 255) . collage 400 400 <~ 
    (map (\a -> circle a.r 
             |> filled a.rgba
             |> move (a.x, a.y)
    ) <~ collideUnits)
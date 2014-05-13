module Collision where

import Random

type Unit = {x : Float, y : Float, r : Float}

collision : Signal [Unit]
collision = foldp (\_ xs -> map (\a -> moveUnit a (0,0) 1 (filter (touching a) xs)) xs) units (fps 10)

--genUnits : Signal [Unit]
--genUnits = zipWith (\x y -> {x = x * 400 - 200, y = y * 400 - 200, r = 32}) <~ Random.floatList (constant 10) ~ Random.floatList (constant 10)

units = [{ r = 32, x = 188.71561652049422, y = -153.0935812741518 },{ r = 32, x = -153.15972343087196, y = -9.749480430036783 },{ r = 32, x = 198.16306615248322, y = 55.05271311849356 },{ r = 32, x = -138.17938724532723, y = 177.7329869568348 },{ r = 32, x = -103.26284980401397, y = -105.50304148346186 },{ r = 32, x = -91.96685971692204, y = 77.50591281801462 },{ r = 32, x = -114.42862143740058, y = 131.34195627644658 },{ r = 32, x = 29.059351980686188, y = 62.94285096228123 },{ r = 32, x = 135.08485443890095, y = -61.13499440252781 },{ r = 32, x = 5.365708097815514, y = -5.062213074415922 }]

{-
collideUnits : [Unit] -> [Unit]
collideUnits xs =
    flip map xs <| 
        \a -> let inRange = filter (\b -> touching a b) xs in
            foldl (\o a' -> {a'| x <- a'.x + o.x, y <- a'.y + o.y }) a <|
                flip map xs <| 
                    \b -> 
                        let (xDif,yDif) = (a.x - b.x, a.y - b.y) in
                        let wDif = 1 / toFloat (length inRange) in
                        let rDif = (a.r + b.r) - (sqrt <| (xDif^2) + (yDif^2)) in
                        let angl = atan2 yDif xDif in
                        {x = 0.2, y = 0.2}
                        {x = cos angl * rDif * wDif, y= sin angl * rDif * wDif} -}

moveUnits : [Unit] -> [Unit]
moveUnits xs = flip map xs <| \u -> let ang = atan2 (0 - u.y) (0 - u.x) in 
    {u | x <- u.x + 2 * cos ang, y <- u.y + 2 * sin ang}

touching : Unit -> Unit -> Bool
touching a b = (a.x - b.x)^2 + (a.y - b.y)^2 <= (a.r + b.r)^2

main = collage 1400 1000 <~ (map (\a -> move (a.x, a.y) <| filled black <| circle a.r) <~ collision)

moveUnit :
    Unit -> -- Entity being moved
    (Float,Float) -> -- Desination
    Float -> -- Distance to move
    [Unit] -> -- Entities in range
    Unit -- New coordinates for entity
moveUnit a (dx,dy) dist inRange =
    let len = length inRange in
    let push = foldl 
            (\(nx,ny) (ox,oy) -> (nx+ox,ny+oy)) (0,0) <| map (\b -> 
                let (xDif,yDif) = (a.x - b.x, a.y - b.y) in
                let wDif = 1 / toFloat len in
                let rDif = (a.r + b.r) - (sqrt <| (xDif^2) + (yDif^2)) in
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
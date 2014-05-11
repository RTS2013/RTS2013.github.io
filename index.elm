import Text
import Window

main = background display <~ Window.dimensions

display = 
    flow right 
        [spacer 50 1
        , flow down 
            [ spacer 1 50
            , menu
            , content]
        ]

background element (w,h) = width w . height h <| color (rgb 175 200 100) element

menu = flow down <| map Text.leftAligned
    [ Text.link "index.html#topic" (toText "Topic")
    , Text.link "index.html#need-to-know" (toText "Need To Know")
    , Text.link "index.html#game-desc" (toText "Game Description")
    , Text.link "index.html#game-model" (toText "Game Model")
    ]

content = flow down <| map (\a -> flow down [a,backToTop])
    [ topic
    , needToKnow
    , gameDesc
    , gameModel
    ]

backToTop = link "index.html" <|
    Text.leftAligned <| 
    style smallLinkStyle <| 
    toText "Back to the top of the page &uarr;"

paragraphStyle = 
    { typeface = ["helvetica","arial","sans-serif"]
    , height = Just 18
    , color = black
    , bold = False
    , italic = False
    , line = Nothing
    }

smallLinkStyle = 
    { typeface = ["helvetica","arial","sans-serif"]
    , height = Just 12
    , color = complement (rgb 175 200 100)
    , bold = False
    , italic = False
    , line = Nothing
    }

topic = tag "topic" [markdown|
# Haskell and JavaScript Real-Time Strategy Game
|]

needToKnow = tag "need-to-know" [markdown|
# Need To Know
|]

gameDesc = tag "game-desc" [markdown|
# Game Description
|]

gameModel = tag "game-model" [markdown|
# Game Model
|]
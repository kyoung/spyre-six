module Filters exposing (..)


baseA =
    110.0


getBaseFreq : Int -> Float
getBaseFreq stepsFromA =
    baseA * 2 ^ (toFloat stepsFromA / 12)


majorKey =
    [ 0, 2, 4, 5, 7, 9, 11, 12 ]


createMajorKeyFilter : Float -> List Int
createMajorKeyFilter baseFreq =
    let
        baseList =
            List.map
                (\semi -> round (baseFreq * 2 ^ (toFloat semi / 12.0)))
                majorKey
    in
    List.concat
        (List.map
            (\oct -> List.map (\f -> f * oct) baseList)
            (List.range 1 5)
        )

module Commands exposing (..)

import Random
import Types exposing (Msg(..), Point)


makeCloud : Int -> List Point
makeCloud count =
    List.repeat count (Point 0 0 0)


makeSequence : (List Int -> Msg) -> Int -> Int -> Int -> Cmd Msg
makeSequence type_ min_ max_ count_ =
    Random.generate type_ <| Random.list count_ (Random.int min_ max_)

module Commands exposing (..)

import Constants exposing (..)
import Random
import Types exposing (Msg(..), Point)


makeCloud : Int -> List Point
makeCloud count =
    List.repeat count (Point 0 0 0)


makeFreqs : Int -> Int -> Int -> Cmd Msg
makeFreqs minF maxF count =
    Random.generate AddFreqs <| Random.list count (Random.int minF maxF)


makeTimbers : Int -> Cmd Msg
makeTimbers count =
    Random.generate AddTimbers <| Random.list count (Random.int minTimber maxTimber)


makeTimes : Int -> Int -> Int -> Cmd Msg
makeTimes minT maxT count =
    Random.generate AddTimes <| Random.list count (Random.int minT maxT)

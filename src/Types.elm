module Types exposing (..)


type alias Point =
    { frequency : Int
    , timber : Int
    , time : Int
    }


type alias Model =
    { cloud : List Point
    , cloudCount : Int
    , minTime : Int
    , maxTime : Int
    , minFreq : Int
    , maxFreq : Int
    }


type Msg
    = MakeCloud
    | AddFreqs (List Int)
    | AddTimbers (List Int)
    | AddTimes (List Int)
    | PlayCloud

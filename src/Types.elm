module Types exposing (..)


type alias Point =
    { frequency : Int
    , timber : Int
    , time : Int
    }


type alias Ranges =
    { minTime : Int
    , maxTime : Int
    , minFreq : Int
    , maxFreq : Int
    , minNote : Int
    , maxNote : Int
    , minTimber : Int
    , maxTimber : Int
    }


type alias Model =
    { cloud : List Point
    , cloudCount : Int
    , ranges : Ranges
    }


type Msg
    = AddNotes (List Int)
    | AddFreqs (List Int)
    | AddTimbers (List Int)
    | AddTimes (List Int)
    | PlayCloud

module Types exposing (..)


type alias Point =
    { frequency : Int
    , timber : Int
    , time : Int
    }


type alias Ranges =
    { minTime : Int
    , maxTime : Int
    , minRhythm : Int
    , maxRhythm : Int
    , minFreq : Int
    , maxFreq : Int
    , minNote : Int
    , maxNote : Int
    , minTimber : Int
    , maxTimber : Int
    }


type alias Model =
    { cloud : List Point
    , freqFilters : List FreqFilter
    , cloudCount : Int
    , ranges : Ranges
    }


type alias FreqFilter =
    { frequencies : List Int
    , margin : Int
    , applyFrom : Int
    , applyTo : Int
    }


type Msg
    = AddNotes (List Int)
    | AddTimbers (List Int)
    | AddRhythm (List Int)
    | PlayCloud

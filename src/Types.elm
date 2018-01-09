module Types exposing (..)


type alias Point =
    { frequency : Int
    , timber : Int
    , time : Int
    , rhythm : Int
    , velocity : Int
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


type alias TimeSignature =
    { noteValue : Int
    , beats : Int
    }


type Wave
    = Sine
    | Triangle
    | Square


type alias ADSR =
    { attack : Int
    , decay : Int
    , sustain : Int
    , release : Int
    }


type alias Voice =
    { waveform : Wave
    , adsr : ADSR
    , gain : Int
    }


type alias Register =
    { voices : List Voice
    , lowerTimber : Int
    , upperTimber : Int
    , name : String
    }


type alias CloudSeed =
    { key : Int
    , tsig : TimeSignature
    , count : Int
    , ranges : Ranges
    }


type alias Cloud =
    { cloud : List Point
    , seed : CloudSeed
    , registers : List Register
    }


type alias NeoModel =
    { clouds : List Cloud
    , sequence : List Int
    }


type Msg
    = AddNotes (List Int)
    | AddTimbers (List Int)
    | AddRhythm (List Int)
    | PlayCloud

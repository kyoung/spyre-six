module Types exposing (..)


type alias Point =
    { frequency : Int
    , note : Int
    , timber : Int
    , time : Int
    , rhythm : Int
    , velocity : Int
    }


type alias Ranges =
    { minNote : Int
    , maxNote : Int
    , minTimber : Int
    , maxTimber : Int
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
    , sustain : Float
    , release : Int
    }


type alias Voice =
    { waveform : Wave
    , adsr : ADSR
    , gain : Float
    }


type alias Register =
    { voices : List Voice
    , lowerTimber : Int
    , upperTimber : Int
    , name : String
    }


type alias CloudSeed =
    { key : String
    , tsig : TimeSignature
    , count : Int
    , ranges : Ranges
    , bars : Int
    , tempo : Int
    , cloudId : Int
    }


type alias Cloud =
    { points : List Point
    , seed : CloudSeed
    , registers : List Register
    , id : Int
    }


type alias CloudResponse =
    { points : List Point, cloudId : Int }


type alias Model =
    { clouds : List Cloud
    , sequence : List Int
    , loop : Bool
    }


type Msg
    = GotCloud CloudResponse
    | PlayCloud

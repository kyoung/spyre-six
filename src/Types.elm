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
    | Sawtooth


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
    , index : Int
    }


type FilterType
    = LowPass
    | HighPass
    | BandPass
    | Notch


type alias Filter =
    { frequency : Float
    , q : Float
    , filterType : FilterType
    }


type alias Register =
    { voices : List Voice
    , lowerTimber : Int
    , upperTimber : Int
    , name : String
    , filter : Filter
    }


type alias CloudSeed =
    { key : String
    , tsig : TimeSignature
    , count : Int
    , ranges : Ranges
    , bars : Int
    , tempo : Int
    , cloudId : Int
    , scale : String
    , percussiveBias : Int
    }


type alias Cloud =
    { points : List Point
    , metronome : List Point
    , seed : CloudSeed
    , registers : List Register
    , id : Int
    }


type alias CloudResponse =
    { points : List Point, metronome : List Point, cloudId : Int }


type alias Model =
    { clouds : List Cloud
    , sequence : List Int
    , loop : Bool
    , metronome : Bool
    , editSequence : Bool
    , editCloud : Int
    }


type Msg
    = GotCloud CloudResponse
    | PlayCloud
    | AddCloud
    | DeleteCloud Int
    | DeleteRegister Int String
    | DeleteVoice Int String Int
    | EditSequence
    | SaveSequence String
    | EditCloud Int
    | ToggleMetronome
    | EditRegister Int String String String
    | EditPoints Int String
    | EditPercBias Int String
    | EditWave Int String Int String
    | EditADSR Int String Int String String
    | EditGain Int String Int String
    | EditKey Int String
    | EditTsig Int String
    | EditBars Int String
    | EditTempo Int String
    | EditScale Int String
    | EditFilter Int String String String
    | AddRegister Int
    | AddVoice Int String
    | Loop

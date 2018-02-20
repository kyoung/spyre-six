module ToJson exposing (..)

import Json.Encode exposing (Value, bool, encode, float, int, list, object, string)
import Types exposing (..)


modelToJSON : Model -> Value
modelToJSON model =
    object
        [ ( "clouds", list (List.map cloudToJSON model.clouds) )
        , ( "sequence", list (List.map int model.sequence) )
        , ( "loop", bool model.loop )
        ]


cloudToJSON : Cloud -> Value
cloudToJSON cloud =
    object
        [ ( "points", list (List.map pointToJSON cloud.points) )
        , ( "seed", cloudSeedToJSON cloud.seed )
        , ( "registers", list (List.map registerToJSON cloud.registers) )
        , ( "id", int cloud.id )
        ]


pointToJSON : Point -> Value
pointToJSON point =
    object
        [ ( "frequency", int point.frequency )
        , ( "note", int point.note )
        , ( "timber", int point.timber )
        , ( "time", int point.time )
        , ( "rhythm", int point.rhythm )
        , ( "velocity", int point.velocity )
        ]


registerToJSON : Register -> Value
registerToJSON register =
    object
        [ ( "voices", list (List.map voiceToJSON register.voices) )
        , ( "lowerTimber", int register.lowerTimber )
        , ( "upperTimber", int register.upperTimber )
        , ( "name", string register.name )
        , ( "filter", filterToJSON register.filter )
        ]


filterToJSON : Filter -> Value
filterToJSON filter =
    object
        [ ( "frequency", float filter.frequency )
        , ( "q", float filter.q )
        , ( "filterType", string (String.toLower (toString filter.filterType)) )
        ]


voiceToJSON : Voice -> Value
voiceToJSON voice =
    object
        [ ( "waveform", string (toString voice.waveform) )
        , ( "adsr", adsrToJSON voice.adsr )
        , ( "gain", float voice.gain )
        ]


adsrToJSON : ADSR -> Value
adsrToJSON adsr =
    object
        [ ( "attack", int adsr.attack )
        , ( "decay", int adsr.decay )
        , ( "sustain", float adsr.sustain )
        , ( "release", int adsr.release )
        ]


cloudSeedToJSON : CloudSeed -> Value
cloudSeedToJSON seed =
    object
        [ ( "key", string seed.key )
        , ( "tsig", tsigToJSON seed.tsig )
        , ( "count", int seed.count )
        , ( "ranges", rangesToJSON seed.ranges )
        , ( "bars", int seed.bars )
        , ( "cloudId", int seed.cloudId )
        , ( "tempo", int seed.tempo )
        , ( "scale", string seed.scale )
        ]


tsigToJSON : TimeSignature -> Value
tsigToJSON tsig =
    object
        [ ( "noteValue", int tsig.noteValue )
        , ( "beats", int tsig.beats )
        ]


rangesToJSON : Ranges -> Value
rangesToJSON ranges =
    object
        [ ( "minNote", int ranges.minNote )
        , ( "maxNote", int ranges.maxNote )
        , ( "minTimber", int ranges.minTimber )
        , ( "maxTimber", int ranges.maxTimber )
        ]

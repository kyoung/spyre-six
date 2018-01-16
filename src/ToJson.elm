module ToJson exposing (..)

import Json.Encode exposing (Value, encode, int, object)
import Types exposing (CloudSeed, Ranges, TimeSignature)


cloudSeedToJSON : CloudSeed -> String
cloudSeedToJSON seed =
    encode 0
        (object
            [ ( "key", int seed.key )
            , ( "tsig", tsigToJSON seed.tsig )
            , ( "count", int seed.count )
            , ( "ranges", rangesToJSON seed.ranges )
            , ( "bars", int seed.bars )
            , ( "cloudId", int seed.cloudId )
            ]
        )


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

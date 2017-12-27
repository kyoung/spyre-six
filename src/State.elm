module State exposing (..)

import Commands exposing (makeCloud, makeSequence)
import Ports exposing (drawCloud, playCloud)
import Random
import Types exposing (Model, Msg(..), Point)


init : ( Model, Cmd Msg )
init =
    ( { cloud = makeCloud 5000
      , cloudCount = 5000
      , ranges =
            { minTime = 1
            , maxTime = 16000
            , minFreq = 27
            , maxFreq = 4200
            , minNote = 210
            , maxNote = 1080
            , minTimber = 10
            , maxTimber = 5000
            }
      }
    , makeSequence AddNotes 210 1080 5000
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update action model =
    let
        oldRanges =
            model.ranges

        newRanges =
            { oldRanges
                | minFreq = noteToFreq oldRanges.minNote
                , maxFreq = noteToFreq oldRanges.maxNote
            }
    in
    case action of
        AddNotes notes ->
            ( { model
                | cloud = addFreqs model.cloud (List.map noteToFreq notes)
                , ranges = newRanges
              }
            , makeSequence
                AddTimbers
                model.ranges.minTimber
                model.ranges.maxTimber
                model.cloudCount
            )

        AddFreqs freqs ->
            ( { model | cloud = addFreqs model.cloud freqs }
            , makeSequence
                AddTimbers
                model.ranges.minTimber
                model.ranges.maxTimber
                model.cloudCount
            )

        AddTimbers timbers ->
            ( { model | cloud = addTimbers model.cloud timbers }
            , makeSequence
                AddTimes
                model.ranges.minTime
                model.ranges.maxTime
                model.cloudCount
            )

        AddTimes times ->
            ( { model | cloud = addTimes model.cloud times }
            , drawCloud { model | cloud = addTimes model.cloud times }
            )

        PlayCloud ->
            ( model, playCloud "play" )


addFreqs : List Point -> List Int -> List Point
addFreqs cloud freqs =
    List.map2 addFreq cloud freqs


addFreq : Point -> Int -> Point
addFreq point freq =
    { point | frequency = freq }


noteToFreq : Int -> Int
noteToFreq midiNote =
    round (2 ^ ((toFloat midiNote - 690) / 120) * 440)


addTimbers : List Point -> List Int -> List Point
addTimbers cloud timbers =
    List.map2 addTimber cloud timbers


addTimber : Point -> Int -> Point
addTimber point timber =
    { point | timber = timber }


addTimes : List Point -> List Int -> List Point
addTimes cloud times =
    List.map2 addTime cloud times


addTime : Point -> Int -> Point
addTime point time =
    { point | time = time }

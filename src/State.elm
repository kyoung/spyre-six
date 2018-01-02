module State exposing (..)

import Commands exposing (makeCloud, makeSequence)
import Filters exposing (baseA, createMajorKeyFilter)
import Ports exposing (drawCloud, playCloud)
import Random
import Types exposing (FreqFilter, Model, Msg(..), Point)


init : ( Model, Cmd Msg )
init =
    ( { cloud = makeCloud 1000
      , cloudCount = 1000
      , ranges =
            { minTime = 1
            , maxTime = 16000
            , minRhythm = 1
            , maxRhythm = 64
            , minFreq = 27
            , maxFreq = 4200
            , minNote = 210
            , maxNote = 1080
            , minTimber = 10
            , maxTimber = 5000
            }
      , freqFilters =
            [ { frequencies = createMajorKeyFilter baseA
              , applyFrom = 0
              , applyTo = 4200
              , margin = 50
              }
            ]
      }
    , makeSequence AddNotes 210 1080 1000
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
                , minTime = beatToTime oldRanges.minRhythm
                , maxTime = beatToTime oldRanges.maxRhythm
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

        AddTimbers timbers ->
            ( { model | cloud = addTimbers model.cloud timbers }
            , makeSequence
                AddRhythm
                model.ranges.minRhythm
                model.ranges.maxRhythm
                model.cloudCount
            )

        AddRhythm beats ->
            ( { model
                | cloud =
                    applyFilters
                        model.freqFilters
                        (List.map tampPads (addRhythms model.cloud beats))
                , ranges = newRanges
              }
            , drawCloud
                { model
                    | cloud =
                        applyFilters
                            model.freqFilters
                            (List.map tampPads (addRhythms model.cloud beats))
                    , ranges = newRanges
                }
            )

        PlayCloud ->
            ( model, playCloud "play" )


applyFilters : List FreqFilter -> List Point -> List Point
applyFilters filters cloud =
    List.foldl applyFilter cloud filters


applyFilter : FreqFilter -> List Point -> List Point
applyFilter filter_ cloud =
    List.filter (\p -> List.member p.frequency filter_.frequencies) cloud


addFreqs : List Point -> List Int -> List Point
addFreqs cloud freqs =
    List.map2 addFreq cloud freqs


addFreq : Point -> Int -> Point
addFreq point freq =
    { point | frequency = freq }


noteToFreq : Int -> Int
noteToFreq midiNote =
    round (2 ^ ((toFloat midiNote - 690) / 120) * 440)


beatToTime : Int -> Int
beatToTime beatVal =
    -- assume a 4/4, 120bpm
    -- each beat maps to a 16th note in that range...
    let
        -- quarter notes
        bpm =
            120.0

        -- 16th notes, AKA bpm multiplier
        bpmModifier =
            4.0
    in
    round (toFloat beatVal / (bpm / 60.0 / 1000.0 * bpmModifier))


beatToVelocity : Int -> Int
beatToVelocity beatVal =
    -- assume a 4/4, 120bpm
    -- 100 at each note, ie when beatVal modulo 16 == 0
    -- 80 at each beat, ie when beatVal modulo 4 == 0
    -- 50 at each demi, ie when beatVal modulo 2 == 0
    -- 30 else
    if beatVal % 16 == 0 then
        100
    else if beatVal % 4 == 0 then
        50
    else if beatVal % 2 == 0 then
        30
    else
        10


tampPads : Point -> Point
tampPads point =
    -- the pad points need to be muted a bit...
    -- >500ms == pad
    if point.timber > 500 then
        { point | velocity = 5 }
    else
        point


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


addRhythms : List Point -> List Int -> List Point
addRhythms cloud rhythms =
    List.map2 addRhythm cloud rhythms


addRhythm point rhythm =
    { point | rhythm = rhythm, time = beatToTime rhythm, velocity = beatToVelocity rhythm }

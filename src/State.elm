module State exposing (..)

import Filters exposing (baseA, createMajorKeyFilter)
import Json.Encode exposing (encode, object)
import Maybe
import Ports exposing (makeCloud, playCloud)
import Random
import ToJson exposing (cloudSeedToJSON, modelToJSON)
import Types
    exposing
        ( CloudSeed
        , Model
        , Msg(..)
        , Point
        , Register
        , TimeSignature
        , Voice
        , Wave(..)
        )


firstSeed : CloudSeed
firstSeed =
    { key = "Ab"
    , tsig = { noteValue = 4, beats = 4 }
    , count = 100
    , ranges = { minNote = 210, maxNote = 1080, minTimber = 10, maxTimber = 5000 }
    , cloudId = 0
    , bars = 4
    , tempo = 120
    }


firstVoice : Voice
firstVoice =
    { waveform = Sine
    , adsr = { attack = 100, decay = 200, sustain = 0.7, release = 500 }
    , gain = 1.0
    }


secondVoice : Voice
secondVoice =
    { waveform = Triangle
    , adsr = { attack = 100, decay = 200, sustain = 0.7, release = 500 }
    , gain = 0.7
    }


firstRegister : Register
firstRegister =
    { voices = [ firstVoice, secondVoice ]
    , lowerTimber = 10
    , upperTimber = 5000
    , name = "default"
    }


init : ( Model, Cmd Msg )
init =
    ( { clouds =
            [ { seed = firstSeed
              , points = []
              , registers = [ firstRegister ]
              , id = 0
              }
            ]
      , sequence = []
      , loop = True
      }
    , makeCloud (encode 0 (cloudSeedToJSON firstSeed))
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update action model =
    case action of
        GotCloud cloudResponse ->
            ( setCloudPoints model cloudResponse.cloudId cloudResponse.points, Cmd.none )

        PlayCloud ->
            ( model, playCloud (encode 0 (modelToJSON model)) )

        AddCloud ->
            let
                maxCloudId =
                    Maybe.withDefault
                        0
                        (List.maximum
                            (List.map (\c -> c.id) model.clouds)
                        )

                newId =
                    maxCloudId + 1
            in
            ( addCloud model newId
            , makeCloud (encode 0 (cloudSeedToJSON { firstSeed | cloudId = newId }))
            )

        DeleteCloud cloudId ->
            ( deleteCloud model cloudId, Cmd.none )


deleteCloud : Model -> Int -> Model
deleteCloud model cid =
    { model
        | sequence = List.filter (\s -> s /= cid) model.sequence
        , clouds = List.filter (\c -> c.id /= cid) model.clouds
    }


addCloud : Model -> Int -> Model
addCloud model cid =
    let
        updatedClouds clouds =
            List.append
                clouds
                [ { seed = firstSeed
                  , points = []
                  , registers = [ firstRegister ]
                  , id = cid
                  }
                ]
    in
    { model | clouds = updatedClouds model.clouds }


setCloudPoints : Model -> Int -> List Point -> Model
setCloudPoints model cloudId points =
    let
        updateCloud c =
            if c.id == cloudId then
                { c | points = points }
            else
                c
    in
    { model
        | clouds = List.map updateCloud model.clouds
        , sequence = List.append model.sequence [ cloudId ]
    }



--
--
-- applyFilters : List FreqFilter -> List Point -> List Point
-- applyFilters filters cloud =
--     List.foldl applyFilter cloud filters
--
--
-- applyFilter : FreqFilter -> List Point -> List Point
-- applyFilter filter_ cloud =
--     List.filter (\p -> List.member p.frequency filter_.frequencies) cloud
--
--
-- addFreqs : List Point -> List Int -> List Point
-- addFreqs cloud freqs =
--     List.map2 addFreq cloud freqs
--
--
-- addFreq : Point -> Int -> Point
-- addFreq point freq =
--     { point | frequency = freq }
--
--
-- noteToFreq : Int -> Int
-- noteToFreq midiNote =
--     round (2 ^ ((toFloat midiNote - 690) / 120) * 440)
--
--
-- beatToTime : Int -> Int
-- beatToTime beatVal =
--     -- assume a 4/4, 120bpm
--     -- each beat maps to a 16th note in that range...
--     let
--         -- quarter notes
--         bpm =
--             120.0
--
--         -- 16th notes, AKA bpm multiplier
--         bpmModifier =
--             4.0
--     in
--     round (toFloat beatVal / (bpm / 60.0 / 1000.0 * bpmModifier))
--
--
-- beatToVelocity : Int -> Int
-- beatToVelocity beatVal =
--     -- assume a 4/4, 120bpm
--     -- 100 at each note, ie when beatVal modulo 16 == 0
--     -- 50 at each beat, ie when beatVal modulo 4 == 0
--     -- 30 at each demi, ie when beatVal modulo 2 == 0
--     -- 10 else
--     if beatVal % 16 == 0 then
--         100
--     else if beatVal % 4 == 0 then
--         50
--     else if beatVal % 2 == 0 then
--         30
--     else
--         10
--
--
-- tampPads : Point -> Point
-- tampPads point =
--     -- the pad points need to be muted a bit...
--     -- >500ms == pad
--     if point.timber > 500 then
--         { point | velocity = 30 }
--     else
--         point
--
--
-- addTimbers : List Point -> List Int -> List Point
-- addTimbers cloud timbers =
--     List.map2 addTimber cloud timbers
--
--
-- addTimber : Point -> Int -> Point
-- addTimber point timber =
--     { point | timber = timber }
--
--
-- addTimes : List Point -> List Int -> List Point
-- addTimes cloud times =
--     List.map2 addTime cloud times
--
--
-- addTime : Point -> Int -> Point
-- addTime point time =
--     { point | time = time }
--
--
-- addRhythms : List Point -> List Int -> List Point
-- addRhythms cloud rhythms =
--     List.map2 addRhythm cloud rhythms
--
--
-- addRhythm point rhythm =
--     { point | rhythm = rhythm, time = beatToTime rhythm, velocity = beatToVelocity rhythm }

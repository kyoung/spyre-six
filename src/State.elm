module State exposing (..)

import Commands exposing (makeCloud, makeFreqs, makeTimbers, makeTimes)
import Ports exposing (drawCloud, playCloud)
import Random
import Types exposing (Model, Msg(..), Point)


init : ( Model, Cmd Msg )
init =
    ( { cloud = makeCloud 1000
      , cloudCount = 1000
      , minTime = 1000
      , maxTime = 4000
      , minFreq = 27
      , maxFreq = 4200
      }
    , makeFreqs 27 4200 1000
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update action model =
    case action of
        MakeCloud ->
            ( { model | cloud = makeCloud model.cloudCount }
            , makeFreqs model.minFreq model.maxFreq model.cloudCount
            )

        AddFreqs freqs ->
            ( { model | cloud = addFreqs model.cloud freqs }
            , makeTimbers model.cloudCount
            )

        AddTimbers timbers ->
            ( { model | cloud = addTimbers model.cloud timbers }
            , makeTimes model.minTime model.maxTime model.cloudCount
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

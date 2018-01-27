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
      , editSequence = False
      , editCloud = -1
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

        EditCloud cloudId ->
            let
                new_edit_id =
                    if model.editCloud == cloudId then
                        -1
                    else
                        cloudId
            in
            ( { model | editCloud = new_edit_id }, Cmd.none )

        EditSequence ->
            ( { model | editSequence = not model.editSequence }, Cmd.none )

        SaveSequence new_sequence ->
            ( { model
                | sequence =
                    List.map
                        (\s -> Result.withDefault 0 (String.toInt s))
                        (String.split "" new_sequence)
              }
            , Cmd.none
            )

        EditPoints cloudId pointCount ->
            let
                newModel =
                    updateCloudPointCount model cloudId pointCount

                newSeed =
                    (Maybe.withDefault { seed = firstSeed, id = 0, points = [], registers = [] }
                        (List.head (List.filter (\c -> c.id == cloudId) newModel.clouds))
                    ).seed
            in
            ( newModel
            , makeCloud (encode 0 (cloudSeedToJSON newSeed))
            )

        EditKey cloudId newKey ->
            let
                updateSeed seed =
                    { seed | key = newKey }

                newModel =
                    { model
                        | clouds =
                            List.map
                                (\c ->
                                    if c.id == cloudId then
                                        { c | seed = updateSeed c.seed }
                                    else
                                        c
                                )
                                model.clouds
                    }

                newSeed =
                    (Maybe.withDefault { seed = firstSeed, id = 0, points = [], registers = [] }
                        (List.head (List.filter (\c -> c.id == cloudId) newModel.clouds))
                    ).seed
            in
            ( newModel, makeCloud (encode 0 (cloudSeedToJSON newSeed)) )

        EditTsig cloudId tsig ->
            let
                x =
                    String.split "/" tsig

                t =
                    { beats = Result.withDefault 4 (String.toInt (Maybe.withDefault "4" (List.head x)))
                    , noteValue = Result.withDefault 4 (String.toInt (Maybe.withDefault "4" (List.head (List.reverse x))))
                    }

                updateSeed seed =
                    { seed | tsig = t }

                newModel =
                    { model
                        | clouds =
                            List.map
                                (\c ->
                                    if c.id == cloudId then
                                        { c | seed = updateSeed c.seed }
                                    else
                                        c
                                )
                                model.clouds
                    }

                newSeed =
                    (Maybe.withDefault { seed = firstSeed, id = 0, points = [], registers = [] }
                        (List.head (List.filter (\c -> c.id == cloudId) newModel.clouds))
                    ).seed
            in
            ( newModel, makeCloud (encode 0 (cloudSeedToJSON newSeed)) )

        Loop ->
            ( { model | loop = not model.loop }, Cmd.none )


updateCloudPointCount : Model -> Int -> String -> Model
updateCloudPointCount model cloudId newPoints =
    let
        updateSeed seed =
            { seed | count = Result.withDefault 0 (String.toInt newPoints) }

        updateClouds clouds =
            List.map
                (\c ->
                    if c.id == cloudId then
                        { c | seed = updateSeed c.seed }
                    else
                        c
                )
                clouds
    in
    { model | clouds = updateClouds model.clouds }


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
                [ { seed = { firstSeed | cloudId = cid }
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
    { model | clouds = List.map updateCloud model.clouds }

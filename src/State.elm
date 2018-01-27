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
    , count = 20
    , ranges = { minNote = 210, maxNote = 1080, minTimber = 10, maxTimber = 5000 }
    , cloudId = 0
    , bars = 4
    , tempo = 120
    , scale = "major"
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
      , sequence = [ 0 ]
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
                pc =
                    Result.withDefault 100 (String.toInt pointCount)

                oldSeed =
                    getCloudSeed model cloudId

                newSeed =
                    { oldSeed | count = pc }

                newModel =
                    updateSeed model newSeed cloudId
            in
            ( newModel, makeCloud (encode 0 (cloudSeedToJSON newSeed)) )

        EditKey cloudId newKey ->
            let
                oldSeed =
                    getCloudSeed model cloudId

                newSeed =
                    { oldSeed | key = newKey }

                newModel =
                    updateSeed model newSeed cloudId
            in
            ( newModel, makeCloud (encode 0 (cloudSeedToJSON newSeed)) )

        EditBars cloudId bars ->
            let
                b =
                    Result.withDefault 4 (String.toInt bars)

                oldSeed =
                    getCloudSeed model cloudId

                newSeed =
                    { oldSeed | bars = b }

                newModel =
                    updateSeed model newSeed cloudId
            in
            ( newModel, makeCloud (encode 0 (cloudSeedToJSON newSeed)) )

        EditTempo cloudId tempo ->
            let
                t =
                    Result.withDefault 120 (String.toInt tempo)

                oldSeed =
                    getCloudSeed model cloudId

                newSeed =
                    { oldSeed | tempo = t }

                newModel =
                    updateSeed model newSeed cloudId
            in
            ( newModel, makeCloud (encode 0 (cloudSeedToJSON newSeed)) )

        EditScale cloudId newScale ->
            let
                oldSeed =
                    getCloudSeed model cloudId

                newSeed =
                    { oldSeed | scale = newScale }

                newModel =
                    updateSeed model newSeed cloudId
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

                oldSeed =
                    getCloudSeed model cloudId

                newSeed =
                    { oldSeed | tsig = t }

                newModel =
                    updateSeed model newSeed cloudId
            in
            ( newModel, makeCloud (encode 0 (cloudSeedToJSON newSeed)) )

        Loop ->
            ( { model | loop = not model.loop }, playCloud (encode 0 (modelToJSON model)) )


updateSeed : Model -> CloudSeed -> Int -> Model
updateSeed model newSeed cloudId =
    { model
        | clouds =
            List.map
                (\c ->
                    if c.id == cloudId then
                        { c | seed = newSeed }
                    else
                        c
                )
                model.clouds
    }


getCloudSeed : Model -> Int -> CloudSeed
getCloudSeed model cloudId =
    let
        c =
            Maybe.withDefault
                { seed = firstSeed, id = -1, registers = [], points = [] }
                (List.head (List.filter (\c -> c.id == cloudId) model.clouds))
    in
    c.seed


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

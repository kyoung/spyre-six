module State exposing (..)

import Filters exposing (baseA, createMajorKeyFilter)
import Json.Encode exposing (encode, object)
import Maybe
import Ports exposing (makeCloud, playCloud, updateCloud)
import Random
import ToJson exposing (cloudSeedToJSON, modelToJSON)
import Types
    exposing
        ( CloudSeed
        , Filter
        , FilterType(..)
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
    , scale = "major"
    , percussiveBias = 4
    }


firstVoice : Voice
firstVoice =
    { waveform = Sine
    , adsr = { attack = 10, decay = 10, sustain = 0, release = 1 }
    , gain = 1
    , index = 0
    }


secondVoice : Voice
secondVoice =
    { waveform = Sine
    , adsr = { attack = 100, decay = 200, sustain = 0.7, release = 500 }
    , gain = 0.2
    , index = 1
    }


thirdVoice : Voice
thirdVoice =
    { waveform = Sine
    , adsr = { attack = 3000, decay = 800, sustain = 0.7, release = 3000 }
    , gain = 0.1
    , index = 2
    }


fourthVoice : Voice
fourthVoice =
    { waveform = Sine
    , adsr = { attack = 2500, decay = 1000, sustain = 0.7, release = 2000 }
    , gain = 0.15
    , index = 3
    }


firstRegister : Register
firstRegister =
    { voices = [ firstVoice ]
    , lowerTimber = 1
    , upperTimber = 100
    , name = "0"
    , filter = { frequency = 880, q = 0, filterType = LowPass }
    }


secondRegister : Register
secondRegister =
    { voices = [ secondVoice ]
    , lowerTimber = 100
    , upperTimber = 2000
    , name = "1"
    , filter = { frequency = 0, q = 0, filterType = HighPass }
    }


thirdRegister : Register
thirdRegister =
    { voices = [ thirdVoice, fourthVoice ]
    , lowerTimber = 2000
    , upperTimber = 5000
    , name = "2"
    , filter = { frequency = 440, q = 0, filterType = LowPass }
    }


init : ( Model, Cmd Msg )
init =
    ( { clouds =
            [ { seed = firstSeed
              , points = []
              , metronome = []
              , registers = [ firstRegister, secondRegister, thirdRegister ]
              , id = 0
              }
            ]
      , sequence = [ 0 ]
      , loop = False
      , metronome = False
      , editSequence = False
      , editCloud = -1
      , displayManPage = True
      }
    , makeCloud (encode 0 (cloudSeedToJSON firstSeed))
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update action model =
    case action of
        GotCloud cloudResponse ->
            let
                newModel =
                    setCloudPoints model cloudResponse.cloudId cloudResponse.points cloudResponse.metronome
            in
            ( newModel, updateCloud (encode 0 (modelToJSON newModel)) )

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
            let
                newModel =
                    deleteCloud model cloudId
            in
            ( newModel, updateCloud (encode 0 (modelToJSON newModel)) )

        DeleteRegister cloudId regName ->
            let
                newModel =
                    deleteRegister model cloudId regName
            in
            ( newModel, updateCloud (encode 0 (modelToJSON newModel)) )

        DeleteVoice cloudId regName voiceIdx ->
            let
                newModel =
                    deleteVoice model cloudId regName voiceIdx
            in
            ( newModel, updateCloud (encode 0 (modelToJSON newModel)) )

        EditCloud cloudId ->
            let
                new_edit_id =
                    if model.editCloud == cloudId then
                        -1
                    else
                        cloudId
            in
            ( { model | editCloud = new_edit_id }, Cmd.none )

        ToggleMetronome ->
            ( { model | metronome = not model.metronome }, Cmd.none )

        EditSequence ->
            ( { model | editSequence = not model.editSequence }, Cmd.none )

        SaveSequence new_sequence ->
            let
                validSeqIDs =
                    List.map (\c -> c.id) model.clouds

                newSeq =
                    List.map
                        (\s -> Result.withDefault 0 (String.toInt s))
                        (String.split "" new_sequence)

                cleanSeq =
                    List.filter (\s -> List.member s validSeqIDs) newSeq
            in
            ( { model | sequence = cleanSeq }, Cmd.none )

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

        EditPercBias cloudId bias ->
            let
                b =
                    Result.withDefault 0 (String.toInt bias)

                oldSeed =
                    getCloudSeed model cloudId

                newSeed =
                    { oldSeed | percussiveBias = b }

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

        EditRegister cloudId register upperOrLower timberValue ->
            let
                val =
                    Result.withDefault 0 (String.toInt timberValue)

                newModel =
                    updateRegister model cloudId register upperOrLower val
            in
            ( newModel, updateCloud (encode 0 (modelToJSON newModel)) )

        EditWave cloudId register voiceIdx nuWave ->
            let
                wave =
                    case nuWave of
                        "Sine" ->
                            Sine

                        "Sawtooth" ->
                            Sawtooth

                        "Square" ->
                            Square

                        "Triangle" ->
                            Triangle

                        _ ->
                            Sine

                newModel =
                    updateWave model cloudId register voiceIdx wave
            in
            ( newModel, updateCloud (encode 0 (modelToJSON newModel)) )

        EditADSR cloudId register voiceIdx adsrVal valString ->
            let
                val =
                    Result.withDefault 0 (String.toFloat valString)

                newModel =
                    updateADSR model cloudId register voiceIdx adsrVal val
            in
            ( newModel, updateCloud (encode 0 (modelToJSON newModel)) )

        EditGain cloudId register voiceId gainVal ->
            let
                gain =
                    Result.withDefault 0 (String.toFloat gainVal)

                newModel =
                    updateGain model cloudId register voiceId gain
            in
            ( newModel, updateCloud (encode 0 (modelToJSON newModel)) )

        EditFilter cloudId register filterParam valString ->
            let
                val =
                    Result.withDefault -1.0 (String.toFloat valString)

                newModel =
                    updateFilter model cloudId register filterParam val
            in
            ( newModel, updateCloud (encode 0 (modelToJSON newModel)) )

        AddRegister cloudId ->
            let
                newModel =
                    addRegister model cloudId
            in
            ( newModel, updateCloud (encode 0 (modelToJSON newModel)) )

        AddVoice cloudId register ->
            let
                newModel =
                    addVoice model cloudId register
            in
            ( newModel, updateCloud (encode 0 (modelToJSON newModel)) )

        Loop ->
            let
                newModel =
                    { model | loop = not model.loop }
            in
            ( newModel, updateCloud (encode 0 (modelToJSON newModel)) )

        ToggleManPage ->
            ( { model | displayManPage = not model.displayManPage }, Cmd.none )


addVoice : Model -> Int -> String -> Model
addVoice model cloudId registerName =
    let
        nextIdx register =
            Maybe.withDefault 0
                (List.head
                    (List.reverse
                        (List.sort
                            (List.map (\v -> v.index) register.voices)
                        )
                    )
                )
                + 1

        updateRegister register =
            if register.name == registerName then
                { register
                    | voices =
                        List.append
                            register.voices
                            [ { firstVoice | index = nextIdx register } ]
                }
            else
                register

        updateClouds cloud =
            if cloud.id == cloudId then
                { cloud | registers = List.map updateRegister cloud.registers }
            else
                cloud
    in
    { model | clouds = List.map updateClouds model.clouds }


addRegister : Model -> Int -> Model
addRegister model cloudId =
    let
        nextName registers =
            let
                v =
                    List.length registers
            in
            toString v

        updateClouds cloud =
            if cloud.id == cloudId then
                { cloud
                    | registers =
                        List.append cloud.registers
                            [ { firstRegister
                                | name = nextName cloud.registers
                              }
                            ]
                }
            else
                cloud
    in
    { model | clouds = List.map updateClouds model.clouds }


updateFilter : Model -> Int -> String -> String -> Float -> Model
updateFilter model cloudId registerName filterParam paramValue =
    let
        updateFilter filter_ =
            case filterParam of
                "frequency" ->
                    { filter_ | frequency = paramValue }

                "q" ->
                    { filter_ | q = paramValue }

                "type" ->
                    case floor paramValue of
                        0 ->
                            { filter_ | filterType = LowPass }

                        1 ->
                            { filter_ | filterType = HighPass }

                        2 ->
                            { filter_ | filterType = BandPass }

                        3 ->
                            { filter_ | filterType = Notch }

                        _ ->
                            filter_

                _ ->
                    filter_

        updateRegisters register =
            if register.name == registerName then
                { register | filter = updateFilter register.filter }
            else
                register

        updateCloud cloud =
            if cloud.id == cloudId then
                { cloud | registers = List.map updateRegisters cloud.registers }
            else
                cloud
    in
    { model | clouds = List.map updateCloud model.clouds }


updateGain : Model -> Int -> String -> Int -> Float -> Model
updateGain model cloudId registerName voiceId gain =
    let
        updateVoices voice =
            if voice.index == voiceId then
                { voice | gain = gain }
            else
                voice

        updateRegisters register =
            if register.name == registerName then
                { register | voices = List.map updateVoices register.voices }
            else
                register

        updateClouds cloud =
            if cloud.id == cloudId then
                { cloud | registers = List.map updateRegisters cloud.registers }
            else
                cloud
    in
    { model | clouds = List.map updateClouds model.clouds }


updateADSR : Model -> Int -> String -> Int -> String -> Float -> Model
updateADSR model cloudId registerName voiceId adsrVal val =
    let
        updateADSR adsr =
            case adsrVal of
                "attack" ->
                    { adsr | attack = floor val }

                "release" ->
                    { adsr | release = floor val }

                "decay" ->
                    { adsr | decay = floor val }

                "sustain" ->
                    { adsr | sustain = val }

                _ ->
                    adsr

        updateVoice voice =
            if voice.index == voiceId then
                { voice | adsr = updateADSR voice.adsr }
            else
                voice

        updateRegister register =
            if register.name == registerName then
                { register | voices = List.map updateVoice register.voices }
            else
                register

        updateClouds cloud =
            if cloud.id == cloudId then
                { cloud | registers = List.map updateRegister cloud.registers }
            else
                cloud
    in
    { model | clouds = List.map updateClouds model.clouds }


updateWave : Model -> Int -> String -> Int -> Wave -> Model
updateWave model cloudId registerName voiceId wave =
    let
        updateVoice voice =
            if voice.index == voiceId then
                { voice | waveform = wave }
            else
                voice

        updateRegister register =
            if register.name == registerName then
                { register | voices = List.map updateVoice register.voices }
            else
                register

        updateClouds cloud =
            if cloud.id == cloudId then
                { cloud | registers = List.map updateRegister cloud.registers }
            else
                cloud
    in
    { model | clouds = List.map updateClouds model.clouds }


updateRegister : Model -> Int -> String -> String -> Int -> Model
updateRegister model cloudId registerName upperOrLower timberValue =
    let
        updateRegister register =
            if register.name == registerName then
                if upperOrLower == "upper" then
                    { register | upperTimber = timberValue }
                else
                    { register | lowerTimber = timberValue }
            else
                register

        updateClouds cloud =
            if cloud.id == cloudId then
                { cloud | registers = List.map updateRegister cloud.registers }
            else
                cloud
    in
    { model | clouds = List.map updateClouds model.clouds }


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
                { seed = firstSeed, id = -1, registers = [], points = [], metronome = [] }
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


deleteRegister : Model -> Int -> String -> Model
deleteRegister model cloudId regName =
    let
        updateCloud cloud =
            if cloud.id == cloudId then
                { cloud
                    | registers =
                        List.filter (\r -> r.name /= regName) cloud.registers
                }
            else
                cloud
    in
    { model
        | clouds = List.map updateCloud model.clouds
    }


deleteVoice : Model -> Int -> String -> Int -> Model
deleteVoice model cloudId registerName voiceIdx =
    let
        updateRegister register =
            if register.name == registerName then
                { register | voices = List.filter (\v -> v.index /= voiceIdx) register.voices }
            else
                register

        updateCloud cloud =
            if cloud.id == cloudId then
                { cloud | registers = List.map updateRegister cloud.registers }
            else
                cloud
    in
    { model | clouds = List.map updateCloud model.clouds }


addCloud : Model -> Int -> Model
addCloud model cid =
    let
        updatedClouds clouds =
            List.append
                clouds
                [ { seed = { firstSeed | cloudId = cid }
                  , points = []
                  , registers = [ firstRegister, secondRegister, thirdRegister ]
                  , id = cid
                  , metronome = []
                  }
                ]
    in
    { model | clouds = updatedClouds model.clouds }


setCloudPoints : Model -> Int -> List Point -> List Point -> Model
setCloudPoints model cloudId points metronome =
    let
        updateCloud c =
            if c.id == cloudId then
                { c | points = points, metronome = metronome }
            else
                c
    in
    { model | clouds = List.map updateCloud model.clouds }

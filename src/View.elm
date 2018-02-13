module View exposing (..)

import Html exposing (Html, button, div, h2, hr, input, option, p, select, span, text)
import Html.Attributes exposing (..)
import Html.Events exposing (on, onClick, onInput)
import Json.Decode as Json
import Types
    exposing
        ( ADSR
        , Cloud
        , CloudSeed
        , Model
        , Msg(..)
        , Register
        , Voice
        , Wave
        )


onChange : (String -> msg) -> Html.Attribute msg
onChange handler =
    on "change" <| Json.map handler <| Json.at [ "target", "value" ] Json.string


root : Model -> Html Msg
root model =
    div []
        [ h2 [ class "spyre" ] [ text "Spyre Six" ]
        , playBar model.loop model.editSequence model.sequence
        , cloudsDisplay model
        ]


playBar : Bool -> Bool -> List Int -> Html Msg
playBar looping in_edit sequence =
    let
        loopText =
            if looping then
                "Break Loop"
            else
                "Loop"
    in
    div [ class "bubble" ]
        [ span [ class "bubbleTitle" ] [ text "Playback" ]
        , div [ class "buttonTray" ]
            [ button [ onClick PlayCloud ] [ text "Play" ]
            , button [ class "buttonPad", onClick Loop ] [ text loopText ]
            , drawSequence sequence in_edit
            ]
        ]


drawSequence : List Int -> Bool -> Html Msg
drawSequence sequence in_edit =
    if in_edit then
        span [ class "informational" ]
            [ span [ class "description" ] [ text "Sequence" ]
            , input [ placeholder (List.foldr (++) "" (List.map toString sequence)), onInput SaveSequence ] []
            , span [ class "seqEdit", onClick EditSequence ] [ text "/" ]
            ]
    else
        span [ class "informational" ]
            (List.append
                (emphasisCombo
                    [ "Sequence", List.foldr (++) "" (List.map toString sequence) ]
                    1
                )
                [ span [ class "seqEdit", onClick EditSequence ] [ text "/" ] ]
            )


cloudsDisplay : Model -> Html Msg
cloudsDisplay model =
    div [ class "clouds" ]
        (List.append
            (List.map (cloudControls model.editCloud) model.clouds)
            [ addCloud ]
        )


addCloud : Html Msg
addCloud =
    div [ class "addCloud", class "bubble", onClick AddCloud ]
        [ text "add Cloud" ]


cloudControls : Int -> Cloud -> Html Msg
cloudControls editCloud cloud =
    div [ class "bubble", class "cloudControl" ]
        [ span [ class "bubbleTitle" ] [ text ("Cloud " ++ toString cloud.id) ]
        , div [ class "delCloud", onClick (DeleteCloud cloud.id) ] [ text "x" ]
        , div [ class "editCloud", onClick (EditCloud cloud.id) ] [ text "/" ]
        , if cloud.id == editCloud then
            drawEditCloudSeed cloud.seed
          else
            drawCloudSeed cloud.seed
        , if cloud.id == editCloud then
            div [ class "editRegisters" ] (List.map (drawEditRegister cloud.id) cloud.registers)
          else
            div [ class "registers" ] (List.map drawRegister cloud.registers)
        ]


drawEditCloudSeed : CloudSeed -> Html Msg
drawEditCloudSeed seed =
    div []
        [ div [ class "informational" ]
            [ div [ class "editSpread" ]
                [ span [] [ text "Points" ]
                , input [ placeholder (toString seed.count), onInput (EditPoints seed.cloudId) ] []
                ]
            , div [ class "editSpread" ]
                [ span [] [ text "Key" ]
                , select [ onChange (EditKey seed.cloudId) ]
                    [ option [ value "Ab" ] [ text "Ab" ]
                    , option [ value "A" ] [ text "A" ]
                    , option [ value "A#" ] [ text "A#" ]
                    , option [ value "Bb" ] [ text "Bb" ]
                    , option [ value "B" ] [ text "B" ]
                    , option [ value "C" ] [ text "C" ]
                    , option [ value "C#" ] [ text "C#" ]
                    , option [ value "Db" ] [ text "Db" ]
                    , option [ value "D" ] [ text "D" ]
                    , option [ value "D#" ] [ text "D#" ]
                    , option [ value "Eb" ] [ text "Eb" ]
                    , option [ value "E" ] [ text "E" ]
                    , option [ value "F" ] [ text "F" ]
                    , option [ value "F#" ] [ text "F#" ]
                    , option [ value "Gb" ] [ text "Gb" ]
                    , option [ value "G" ] [ text "G" ]
                    , option [ value "G#" ] [ text "G#" ]
                    ]
                ]
            , div [ class "editSpread" ]
                [ span [] [ text "Time Signature" ]
                , input
                    [ placeholder
                        (toString seed.tsig.beats ++ "/" ++ toString seed.tsig.noteValue)
                    , onInput (EditTsig seed.cloudId)
                    ]
                    []
                ]
            , div [ class "editSpread" ]
                [ span [] [ text "Bars" ]
                , input
                    [ placeholder
                        (toString seed.bars)
                    , onInput (EditBars seed.cloudId)
                    ]
                    []
                ]
            , div [ class "editSpread" ]
                [ span [] [ text "Tempo" ]
                , input
                    [ placeholder
                        (toString seed.tempo)
                    , onInput (EditTempo seed.cloudId)
                    ]
                    []
                ]
            , div [ class "editSpread" ]
                [ span [] [ text "Scale" ]
                , select [ onChange (EditScale seed.cloudId) ]
                    [ option [ value "major" ] [ text "major" ]
                    , option [ value "minor" ] [ text "minor" ]
                    , option [ value "jazz minor" ] [ text "jazz minor" ]
                    ]
                ]
            ]
        ]


drawCloudSeed : CloudSeed -> Html Msg
drawCloudSeed seed =
    div []
        [ div [ class "informational" ] (emphasisCombo [ "Points", toString seed.count ] 1)
        , div [ class "informational" ] (emphasisCombo [ "Key", toString seed.key ] 1)
        , div [ class "informational" ]
            (emphasisCombo
                [ "Signature"
                , toString seed.tsig.beats ++ "/" ++ toString seed.tsig.noteValue
                ]
                1
            )
        , div [ class "informational" ] (emphasisCombo [ "Bars", toString seed.bars ] 1)
        , div [ class "informational" ] (emphasisCombo [ "Tempo", toString seed.tempo ] 1)
        , div [ class "informational" ] (emphasisCombo [ "Scale", toString seed.scale ] 1)
        ]


drawRegister : Register -> Html Msg
drawRegister register =
    div [ class "bubble", class "register" ]
        [ span [ class "bubbleTitle" ] [ text (register.name ++ " voices") ]
        , div []
            [ div [ class "informational" ] [ text ("lower timber " ++ toString register.lowerTimber) ]
            , div [ class "informational" ] [ text ("upper timber " ++ toString register.upperTimber) ]
            , hr [] []
            ]
        , div [ class "voiceBox" ] (List.map drawVoice register.voices)
        ]


drawEditRegister : Int -> Register -> Html Msg
drawEditRegister cloudID register =
    div [ class "bubble", class "register" ]
        [ span [ class "bubbleTitle" ] [ text (register.name ++ " voices") ]
        , div [ class "informational" ]
            [ div [ class "editSpread" ]
                [ span []
                    [ text "lower timber" ]
                , input
                    [ placeholder (toString register.lowerTimber)
                    , onInput (EditRegister cloudID register.name "lower")
                    ]
                    []
                ]
            , div [ class "editSpread" ]
                [ span []
                    [ text "upper timber" ]
                , input
                    [ placeholder (toString register.upperTimber)
                    , onInput (EditRegister cloudID register.name "upper")
                    ]
                    []
                ]
            , hr [] []
            , div [] []
            ]
        , div [ class "voiceBox" ] (List.indexedMap (drawEditVoice cloudID register.name) register.voices)
        ]


drawEditVoice : Int -> String -> Int -> Voice -> Html Msg
drawEditVoice cloudId registerName voiceId voice =
    div [ class "voice" ]
        [ div [ class "informational" ]
            [ span [] [ text "Waveform" ]
            , select [ onChange (EditWave cloudId registerName voiceId) ]
                [ option [ value "Sine" ] [ text "Sine" ]
                , option [ value "Sawtooth" ] [ text "Sawtooth" ]
                , option [ value "Square" ] [ text "Square" ]
                , option [ value "Triangle" ] [ text "Triangle" ]
                ]
            ]
        , drawEditADSR cloudId registerName voiceId voice.adsr
        , drawEditGain cloudId registerName voicdId voice.gain
        ]


drawVoice : Voice -> Html Msg
drawVoice voice =
    div [ class "voice" ]
        [ div [ class "informational" ] (emphasisCombo [ "Waveform", toString voice.waveform ] 1)
        , drawADSR voice.adsr
        , drawGain voice.gain
        ]


drawEditADSR : Int -> String -> Int -> ADSR -> Html Msg
drawEditADSR cloudId registerName voiceId adsr =
    div [ class "adsr" ]
        [ div [ class "informational" ]
            [ div [ class "editSpread" ]
                [ span []
                    [ text "Attack" ]
                , input
                    [ placeholder (toString adsr.attack)
                    , onInput (EditADSR cloudId registerName voiceId "attack")
                    ]
                    []
                ]
            , div [ class "editSpread" ]
                [ span []
                    [ text "Decay" ]
                , input
                    [ placeholder (toString adsr.decay)
                    , onInput (EditADSR cloudId registerName voiceId "decay")
                    ]
                    []
                ]
            , div [ class "editSpread" ]
                [ span []
                    [ text "Sustain" ]
                , input
                    [ placeholder (toString adsr.sustain)
                    , onInput (EditADSR cloudId registerName voiceId "sustain")
                    ]
                    []
                ]
            , div [ class "editSpread" ]
                [ span []
                    [ text "Release" ]
                , input
                    [ placeholder (toString adsr.release)
                    , onInput (EditADSR cloudId registerName voiceId "release")
                    ]
                    []
                ]
            ]
        ]


drawADSR : ADSR -> Html Msg
drawADSR adsr =
    div [ class "adsr" ]
        [ div [ class "informational" ] (emphasisCombo [ "Attack", toString adsr.attack, "ms" ] 1)
        , div [ class "informational" ] (emphasisCombo [ "Decay", toString adsr.decay, "ms" ] 1)
        , div [ class "informational" ] (emphasisCombo [ "Sustain", toString (adsr.sustain * 100), "%" ] 1)
        , div [ class "informational" ] (emphasisCombo [ "Release", toString adsr.release, "ms" ] 1)
        ]


drawEditGain : Int -> String -> Int -> Float -> Html Msg
drawEditGain cloudId registerName voiceId gainVal =
    div [ class "gain" ]
        [ div [ class "informational" ]
            [ div [ class "editSpread" ]
                [ span []
                    [ text "Gain" ]
                , input
                    [ placeholder (toString gainVal)
                    , onInput (EditGain cloudId registerName voiceId)
                    ]
                    []
                ]
            ]
        ]


drawGain : Float -> Html Msg
drawGain gain =
    div [ class "gain" ]
        [ div [ class "informational" ]
            (emphasisCombo [ "Gain", toString (gain * 100), "%" ] 1)
        ]


emphasisItem : Int -> ( Int, String ) -> Html Msg
emphasisItem keyIdx item =
    if Tuple.first item == keyIdx then
        span [ class "value" ] [ text (Tuple.second item) ]
    else
        span [ class "description" ] [ text (Tuple.second item) ]


emphasisCombo : List String -> Int -> List (Html Msg)
emphasisCombo texts emphIdx =
    List.map (emphasisItem emphIdx) (List.indexedMap (,) texts)

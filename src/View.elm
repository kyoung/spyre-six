module View exposing (..)

import Html exposing (Html, button, div, h2, hr, input, p, span, text)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
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
                "Stop"
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
            (List.map cloudControls model.clouds)
            [ addCloud ]
        )


addCloud : Html Msg
addCloud =
    div [ class "addCloud", class "bubble", onClick AddCloud ]
        [ text "add Cloud" ]


cloudControls : Cloud -> Html Msg
cloudControls cloud =
    div [ class "bubble", class "cloudControl" ]
        [ span [ class "bubbleTitle" ] [ text ("Cloud " ++ toString cloud.id) ]
        , div [ class "delCloud", onClick (DeleteCloud cloud.id) ] [ text "x" ]
        , div [ class "editCloud" ] [ text "/" ]
        , drawCloudSeed cloud.seed
        , div [ class "registers" ] (List.map drawRegister cloud.registers)
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


drawVoice : Voice -> Html Msg
drawVoice voice =
    div [ class "voice" ]
        [ div [ class "informational" ] (emphasisCombo [ "Waveform", toString voice.waveform ] 1)
        , drawADSR voice.adsr
        , drawGain voice.gain
        ]


drawADSR : ADSR -> Html Msg
drawADSR adsr =
    div [ class "adsr" ]
        [ div [ class "informational" ] (emphasisCombo [ "Attack", toString adsr.attack, "ms" ] 1)
        , div [ class "informational" ] (emphasisCombo [ "Decay", toString adsr.decay, "ms" ] 1)
        , div [ class "informational" ] (emphasisCombo [ "Sustain", toString (adsr.sustain * 100), "%" ] 1)
        , div [ class "informational" ] (emphasisCombo [ "Release", toString adsr.release, "ms" ] 1)
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

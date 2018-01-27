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
        , div [ class "registers" ] (List.map drawRegister cloud.registers)
        ]


drawEditCloudSeed : CloudSeed -> Html Msg
drawEditCloudSeed seed =
    div []
        [ div [ class "informational" ]
            [ div []
                [ span [] [ text "Points" ]
                , input [ placeholder (toString seed.count), onInput (EditPoints seed.cloudId) ] []
                ]
            , div []
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
            , div []
                [ span [] [ text "Time Signature" ]
                , input
                    [ placeholder
                        (toString seed.tsig.beats ++ "/" ++ toString seed.tsig.noteValue)
                    , onInput (EditTsig seed.cloudId)
                    ]
                    []
                ]
            , div []
                [ span [] [ text "Bars" ] ]
            , div []
                [ span [] [ text "Tempo" ] ]
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

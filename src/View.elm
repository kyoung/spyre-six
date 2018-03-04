module View exposing (..)

import Html exposing (Html, a, button, div, h2, hr, input, option, p, select, span, text)
import Html.Attributes exposing (..)
import Html.Events exposing (on, onClick, onInput)
import Json.Decode as Json
import ManPages exposing (mainDoc)
import Types
    exposing
        ( ADSR
        , Cloud
        , CloudSeed
        , Filter
        , FilterType(..)
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
        [ div [ class "spyre" ]
            [ h2 [] [ text "Spyre v6" ]
            , span [ class "gitlink" ]
                [ text "experimental music generation--github "
                , a [ href "https://github.com/kyoung/spyre-six" ] [ text "spyre-six" ]
                ]
            ]
        , playBar model.loop model.editSequence model.sequence model.metronome
        , cloudsDisplay model
        ]


playBar : Bool -> Bool -> List Int -> Bool -> Html Msg
playBar looping in_edit sequence metronome_active =
    div [ class "bubble" ]
        [ span [ class "bubbleTitle" ] [ text "Playback" ]
        , div [ class "buttonTray" ]
            [ div [ onClick PlayCloud, class "buttonPad" ] [ text "Play" ]
            , div
                [ class "buttonPad"
                , onClick Loop
                , class
                    (if looping then
                        "toggle-on"
                     else
                        "toggle-off"
                    )
                ]
                [ text "Loop" ]
            , div
                [ onClick ToggleMetronome
                , class
                    (if metronome_active then
                        "toggle-on"
                     else
                        "toggle-off"
                    )
                , class "buttonPad"
                ]
                [ text "Metronome" ]
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
            [ addCloud
            , mainDoc model.displayManPage
            ]
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
            div [ class "registers" ] (List.map (drawRegister cloud.id) cloud.registers)
        , div
            [ onClick (AddRegister cloud.id)
            , class "bubble"
            , class "addRegister"
            ]
            [ div [] [ text "add register" ] ]
        ]


drawEditCloudSeed : CloudSeed -> Html Msg
drawEditCloudSeed seed =
    let
        strOption selectedVal key =
            option [ value key, selected (selectedVal == key) ] [ text key ]

        strOptionSet selectedVal options =
            List.map (strOption selectedVal) options
    in
    div []
        [ div [ class "informational" ]
            [ div [ class "editSpread" ]
                [ span [] [ text "Points" ]
                , input [ placeholder (toString seed.count), onInput (EditPoints seed.cloudId) ] []
                ]
            , div [ class "editSpread" ]
                [ span [] [ text "Key" ]
                , select [ onChange (EditKey seed.cloudId) ]
                    (strOptionSet seed.key
                        [ "Ab"
                        , "A"
                        , "A#"
                        , "Bb"
                        , "B"
                        , "C"
                        , "C#"
                        , "Db"
                        , "D"
                        , "D#"
                        , "Eb"
                        , "E"
                        , "F"
                        , "F#"
                        , "Gb"
                        , "G"
                        , "G#"
                        ]
                    )
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
                    (strOptionSet seed.scale [ "major", "minor", "jazz minor" ])
                ]
            , div [ class "editSpread" ]
                [ span [] [ text "Percussive Bias" ]
                , select [ onChange (EditPercBias seed.cloudId) ]
                    (strOptionSet (toString seed.percussiveBias)
                        [ "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10" ]
                    )
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
        , div [ class "informational" ] (emphasisCombo [ "Percussive Bias", toString seed.percussiveBias ] 1)
        ]


drawRegister : Int -> Register -> Html Msg
drawRegister cloudId register =
    div [ class "bubble", class "register" ]
        [ span [ class "bubbleTitle" ] [ text ("register " ++ register.name ++ " voices") ]
        , div []
            [ div [ class "informational" ] [ text ("lower timber " ++ toString register.lowerTimber) ]
            , div [ class "informational" ] [ text ("upper timber " ++ toString register.upperTimber) ]
            , hr [] []
            ]
        , div [ class "voiceBox" ] (List.map drawVoice register.voices)
        , drawFilter register.filter
        , div
            [ class "buttonPad"
            , class "addVoice"
            , onClick (AddVoice cloudId register.name)
            ]
            [ text "add voice" ]
        ]


drawEditRegister : Int -> Register -> Html Msg
drawEditRegister cloudID register =
    div [ class "bubble", class "register" ]
        [ span [ class "bubbleTitle" ] [ text ("register " ++ register.name ++ " voices") ]
        , div
            [ class "deleteRegister"
            , class "buttonPad"
            , onClick (DeleteRegister cloudID register.name)
            ]
            [ text "delete register" ]
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
        , div [ class "voiceBox" ] (List.map (drawEditVoice cloudID register.name) register.voices)
        , drawEditFilter cloudID register.name register.filter
        , div
            [ class "buttonPad"
            , class "addVoice"
            , onClick (AddVoice cloudID register.name)
            ]
            [ text "add voice" ]
        ]


drawEditFilter : Int -> String -> Filter -> Html Msg
drawEditFilter cloudID registerName filter =
    div [ class "informational", class "filter" ]
        [ div [ class "editSpread" ]
            [ span []
                [ text "Frequency" ]
            , input
                [ placeholder (toString filter.frequency)
                , onInput (EditFilter cloudID registerName "frequency")
                ]
                []
            ]
        , div [ class "editSpread" ]
            [ span []
                [ text "Q" ]
            , input
                [ placeholder (toString filter.q)
                , onInput (EditFilter cloudID registerName "q")
                ]
                []
            ]
        , div [ class "editSpread" ]
            [ span []
                [ text "Type" ]
            , select [ onChange (EditFilter cloudID registerName "type") ]
                [ option [ value "0", selected (filter.filterType == LowPass) ] [ text "LowPass" ]
                , option [ value "1", selected (filter.filterType == HighPass) ] [ text "HighPass" ]
                , option [ value "2", selected (filter.filterType == BandPass) ] [ text "BandPass" ]
                , option [ value "3", selected (filter.filterType == Notch) ] [ text "Notch" ]
                ]
            ]
        ]


drawFilter : Filter -> Html Msg
drawFilter filter =
    div [ class "filter" ]
        [ div [ class "informational" ] (emphasisCombo [ "Frequency", toString filter.frequency ] 1)
        , div [ class "informational" ] (emphasisCombo [ "Q", toString filter.q ] 1)
        , div [ class "informational" ] (emphasisCombo [ "Type", toString filter.filterType ] 1)
        ]


drawEditVoice : Int -> String -> Voice -> Html Msg
drawEditVoice cloudId registerName voice =
    div [ class "voice" ]
        [ div [ class "informational" ]
            [ span [] [ text "Waveform" ]
            , select [ onChange (EditWave cloudId registerName voice.index) ]
                [ option [ value "Sine" ] [ text "Sine" ]
                , option [ value "Sawtooth" ] [ text "Sawtooth" ]
                , option [ value "Square" ] [ text "Square" ]
                , option [ value "Triangle" ] [ text "Triangle" ]
                ]
            ]
        , drawEditADSR cloudId registerName voice.index voice.adsr
        , drawEditGain cloudId registerName voice.index voice.gain
        , div
            [ onClick (DeleteVoice cloudId registerName voice.index)
            , class "buttonPad"
            , class "deleteVoice"
            ]
            [ text "delete voice" ]
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

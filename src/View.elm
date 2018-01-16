module View exposing (..)

import Html exposing (Html, div, h2, hr, p, span, text)
import Html.Attributes exposing (..)
import Types exposing (Cloud, Model, Msg, Register)


root : Model -> Html Msg
root model =
    div []
        [ h2 [] [ text "Spyre Six" ]
        , playBar model.loop
        , cloudsDisplay model
        ]


playBar : Bool -> Html Msg
playBar looping =
    div [ class "bubble" ]
        [ span [ class "bubbleTitle" ] [ text "Playback" ]
        , div [] [ text "some buttons go here" ]
        ]


cloudsDisplay : Model -> Html Msg
cloudsDisplay model =
    div [ class "clouds" ]
        (List.map cloudControls model.clouds)


cloudControls : Cloud -> Html Msg
cloudControls cloud =
    div [ class "bubble", class "cloudControl" ]
        [ span [ class "bubbleTitle" ] [ text ("Cloud " ++ toString cloud.id) ]
        , div [ class "registers" ] (List.map drawRegister cloud.registers)
        ]


drawRegister : Register -> Html Msg
drawRegister register =
    div [ class "bubble", class "register" ]
        [ span [ class "bubbleTitle" ] [ text register.name ]
        , div []
            [ div [] [ text ("lower timber: " ++ toString register.lowerTimber) ]
            , div [] [ text ("upper timber: " ++ toString register.upperTimber) ]
            , hr [] []
            ]
        ]



-- stats : Model -> Html Msg
-- stats model =
--     div []
--         [ text (toString model.cloudCount ++ " points") ]
--
--
-- calc_cx : Int -> Int -> Point -> String
-- calc_cx min_ max_ point =
--     toString
--         (toFloat
--             (point.time - min_)
--             / toFloat (max_ - min_)
--             * 1000
--         )
--
--
-- calc_cy : Int -> Int -> Point -> String
-- calc_cy min_ max_ point =
--     toString
--         (400
--             - toFloat
--                 (point.frequency - min_)
--             / toFloat (max_ - min_)
--             * 400
--         )
--
--
-- cloudDrawing : Model -> Html Msg
-- cloudDrawing model =
--     Svg.svg [ style "width: 1000px; height: 400px" ]
--         (List.map
--             (\note ->
--                 Svg.circle
--                     [ cx
--                         (calc_cx
--                             model.ranges.minTime
--                             model.ranges.maxTime
--                             note
--                         )
--                     , cy
--                         (calc_cy
--                             model.ranges.minFreq
--                             model.ranges.maxFreq
--                             note
--                         )
--                     , r "2"
--                     ]
--                     []
--             )
--             model.cloud
--         )

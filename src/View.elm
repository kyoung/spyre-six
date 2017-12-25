module View exposing (..)

import Html exposing (Html, div, h2, p, span, text)
import Svg
import Svg.Attributes exposing (..)
import Types exposing (Model, Msg, Point)


root : Model -> Html Msg
root model =
    div []
        [ h2 [] [ text "Spyre Six" ]
        , stats model
        , cloudDrawing model
        ]


stats : Model -> Html Msg
stats model =
    div []
        [ text (toString model.cloudCount ++ " points") ]


calc_cx : Model -> Point -> String
calc_cx model point =
    toString
        (toFloat
            (point.time - model.minTime)
            / toFloat (model.maxTime - model.minTime)
            * 500
        )


calc_cy : Model -> Point -> String
calc_cy model point =
    toString
        (toFloat
            (point.frequency - model.minFreq)
            / toFloat (model.maxFreq - model.minFreq)
            * 200
        )


cloudDrawing : Model -> Html Msg
cloudDrawing model =
    Svg.svg [ style "width: 500px; height: 200px" ]
        (List.map
            (\note ->
                Svg.circle
                    [ cx (calc_cx model note)
                    , cy (calc_cy model note)
                    , r "2"
                    ]
                    []
            )
            model.cloud
        )

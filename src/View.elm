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


calc_cx : Int -> Int -> Point -> String
calc_cx min_ max_ point =
    toString
        (toFloat
            (point.time - min_)
            / toFloat (max_ - min_)
            * 1000
        )


calc_cy : Int -> Int -> Point -> String
calc_cy min_ max_ point =
    toString
        (400
            - toFloat
                (point.frequency - min_)
            / toFloat (max_ - min_)
            * 400
        )


cloudDrawing : Model -> Html Msg
cloudDrawing model =
    Svg.svg [ style "width: 1000px; height: 400px" ]
        (List.map
            (\note ->
                Svg.circle
                    [ cx
                        (calc_cx
                            model.ranges.minTime
                            model.ranges.maxTime
                            note
                        )
                    , cy
                        (calc_cy
                            model.ranges.minFreq
                            model.ranges.maxFreq
                            note
                        )
                    , r "2"
                    ]
                    []
            )
            model.cloud
        )

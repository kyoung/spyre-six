module View exposing (..)

import Html exposing (Html, div, h2, p, span, text)
import Svg
import Types exposing (Model, Msg)


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


cloudDrawing : Model -> Html Msg
cloudDrawing model =
    Svg.svg []
        []

module Main exposing (..)

import Html exposing (program)
import Ports exposing (gotCloud)
import State exposing (init, update)
import Types exposing (Model, Msg(..))
import View exposing (root)


subscriptions : Model -> Sub Msg
subscriptions model =
    gotCloud GotCloud


main : Program Never Model Msg
main =
    program
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = root
        }

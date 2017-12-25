port module Ports exposing (..)

import Types exposing (Model)


--port for sending out cloud data for D3 to graph


port drawCloud : Model -> Cmd msg


port playCloud : String -> Cmd msg

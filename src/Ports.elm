port module Ports exposing (..)

import Types exposing (CloudResponse)


port playCloud : String -> Cmd msg


port makeCloud : String -> Cmd msg


port updateCloud : String -> Cmd msg


port gotCloud : (CloudResponse -> msg) -> Sub msg

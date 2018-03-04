module ManPages exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Types exposing (Msg(..))


docText =
    [ "SPYRE(6)"
    , "NAME - Spyre"
    , "DESCRIPTION"
    , """
Spyre is a tool to generate and sequence random music. The basic building block is a "cloud" which consists of
a group of points assigned coordinates in a "music space" of rhythm (time), frequency (note), timber (percussiveness),
and velocity (volume). The randomness and bias of this distribution is set by the parameters of the cloud.
"""
    , "Points - how many points are in the cloud? This sets up the density of the sound."
    , "Key/Scale - bias the frequency to only select frequencies from the selected key and scale."
    , """Signature/Bars - velocity of notes is biased based where in the rhythmic structure a point is placed; the
signature determines this underlying grid."""
    , """Percussive Bias - no bias will distribute the points evenly, resulting in a pad-heavy sound, while a high
bias will yield sounds that are more sharp."""
    , """
The specific sound a point will then map to is determined by the registers configured for that cloud. Each register
has a timer range, such that points in that range will play that timber--the effect is that you are able to isolate a
different sound for your percussive tones than you are for your lead and pad tones.
"""
    , """
Each register has many voices and a filter. The voices are oscillators used to play the notes given. Each voice
allows you to set the waveform, an attack/decay/sustain/release envelope, and a gain.
"""
    , """
You may compose larger sounds by creating multiple clouds, and then sequencing them together in the play bar, by
entering the cloud Id in the order you'd like to hear it. EG. A sequence of `00110022001200` will play cloud 0 twice,
cloud 1 twice, cloud 0 twice more, and so on.
"""
    , "BUGS"
    , "Lots at the moment... a browser refresh will reset everything for the time being."
    , "If you discover a bug and feel like being helpful, please open an issues on github."
    , "AUTHOR - Kyle Young"
    , "COPYWRITE - MIT - have at it"
    ]


mainDoc : Bool -> Html Msg
mainDoc display =
    let
        classes =
            if display then
                [ class "mainDocumentation", class "bubble" ]
            else
                []
    in
    div classes
        (if display then
            List.append [ div [ class "closeMan", onClick CloseManPage ] [ text "x" ] ]
                (List.map
                    (\block -> p [] [ text block ])
                    docText
                )
         else
            []
        )

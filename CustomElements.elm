module CustomElements where

import Html exposing (..)
import Html.Attributes exposing (..)
import List exposing (append)

container : List Html.Html -> Html
container elements =
  div
    [ class "container" ]
    elements

box : List Html.Html -> Html
box elements =
  div
    [ class "box" ]
    elements

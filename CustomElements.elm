module CustomElements where

import Html exposing (..)
import Html.Attributes exposing (..)
import List exposing (append)

container : List Html.Attribute -> List Html.Html -> Html
container attributes elements =
  div
    (append [ class "container" ] attributes)
    elements

box : List Html.Attribute -> List Html.Html -> Html
box attributes elements =
  div
   (append [ class "box" ] attributes)
   elements

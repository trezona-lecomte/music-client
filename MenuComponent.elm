module MenuComponent where

import Html exposing (..)
import Effects exposing (..)


-- MODEL

type alias Model =
  {
  }

init : (Model, Effects Action)
init =
  ( Model
  , Effects.none
  )


-- UPDATE

type Action
  = NoOp


-- VIEW

view : Signal.Address Action -> Model -> Html
view address model =
  div [] []

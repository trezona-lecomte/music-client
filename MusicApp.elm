module MusicApp where

import Html exposing (..)
import Html.Attributes exposing (..)
import Effects exposing (..)
import SearchComponent as Search
import MenuComponent as Menu


-- MODEL

type alias Model =
  { search : (Search.Model, Effects Search.Action)
  , menu : (Menu.Model, Effects Menu.Action)
  }


init : (Model, Effects Action)
init =
  ( Model Search.init Menu.init
  , Effects.none
  )


-- UPDATE

type Action
  = UpdateSearch Model
  | UpdateMenu Model



-- VIEW ---------------------------------------------------------------------

view : Model -> Html
view model =
  div
  [ class "" ]
  [
  ]

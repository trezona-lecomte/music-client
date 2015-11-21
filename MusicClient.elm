module MusicClient where

import Html exposing (..)
import Html.Attributes exposing (..)
import Effects exposing (Effects)
import Html.Events exposing (onClick)
import Http
import Task exposing (..)
import Signal exposing (..)
import Debug

import Events exposing (onChange, onEnter)
import CustomElements exposing (container, box)
import Album


-- MODEL

type alias Model =
  { query : String
  , category : String
  , albums : List Album.Album
  , height : String
  }


init : (Model, Effects Action)
init =
  ( Model "" "album" [] "100vh"
  , Effects.none
  )


-- UPDATE

type Action
  = NoOp
  | UpdateQuery String
  | SubmitQuery
  | ReceiveAlbums (Maybe (List Album.Album))


update : Action -> Model -> (Model, Effects Action)
update action model =
  case action of
    UpdateQuery newQuery ->
      ( { model | query = newQuery }
      , Effects.none
      )

    SubmitQuery ->
      ( { model | height = "25vh" }
      , search model.query
      )

    ReceiveAlbums maybeAlbums ->
      ( { model | albums = (Maybe.withDefault [] maybeAlbums) }
      , Effects.none
      )

    NoOp ->
      (model, Effects.none)


-- EFFECTS

(=>) = (,)


search : String -> Effects Action
search query =
  Http.get Album.albumListDecoder (searchUrl query)
    |> Task.toMaybe
    |> Task.map ReceiveAlbums
    |> Effects.task

searchUrl : String -> String
searchUrl query =
  Http.url "https://api.spotify.com/v1/search"
    [ "q" => query
    , "type" => "album"
    ]


-- VIEW ---------------------------------------------------------------------

view : Signal.Address Action -> Model -> Html
view address model =
  div
    [ class "" ]
    [ searchForm address model
    , Album.albumList model.albums
    ]

searchForm : Signal.Address Action -> Model -> Html
searchForm address model =
  div
    [ class "search-container height-transitioned"
    , style [ ("height", model.height)
            ]
    ]
    [
      div
        [ class "search-form" ]
        [ div
          [ class "box large-text-input" ]
            [ input
            [ type' "text"
            , class ""
            , placeholder "Search for an album..."
            , value model.query
            , onChange address UpdateQuery
            , onEnter address SubmitQuery
            ]
            []
          ]
        , div [ class "box medium-button"]
          [ button
            [ class "hollow button"
            , onClick address SubmitQuery
            ]
            [ text "Search"
            ]
          ]
        ]
    ]

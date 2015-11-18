module MusicClient where

import Html exposing (..)
import Html.Attributes exposing (..)
import Effects exposing (Effects)
import Html.Events exposing (onClick)
import Http
import Json.Decode as Json exposing ((:=))
import Task
import Signal exposing (..)
import Debug

import Bootstrap.Html exposing (..)
import Events exposing (onChange, onEnter)
import ColorScheme


-- MODEL

type alias Model =
  { query : String
  , albums : List Album
  }


type alias Album =
  { name : String
  }


init : (Model, Effects Action)
init =
  ( Model "" []
  , Effects.none
  )


-- UPDATE

type Action
  = NoOp
  | UpdateQuery String
  | SubmitQuery
  | ReceiveAlbums (Maybe (List Album))


update : Action -> Model -> (Model, Effects Action)
update action model =
  case action of
    UpdateQuery newQuery ->
      ( { model | query <- newQuery }
      , Effects.none
      ) |> Debug.watch "UpdateQuery"

    SubmitQuery ->
      ( model
      , search model.query
      ) |> Debug.watch "SubmitQuery"

    ReceiveAlbums maybeAlbums ->
      ( { model | albums <- (Maybe.withDefault [] maybeAlbums) }
      , Effects.none
      ) |> Debug.watch "ReceiveAlbums"


-- VIEW

view : Signal.Address Action -> Model -> Html
view address model =
  div
    [style [("margin", "20px 0")]]
    [ bootstrap
    , containerFluid_
        [ searchForm address model
        , resultsList address model
        ]
    ]

searchForm address model =
  div
    [ class "input-group"
    ]
    [ input
        [ type' "text"
        , class "form-control"
        , placeholder "Search for..."
        , value model.query
        , onChange address UpdateQuery
        , onEnter address SubmitQuery
        ]
        []
    -- , div
    --     [ class "btn-group"
    --     ]
    --     [ button
    --         [ class "btn btn-default dropdown-toggle"
    --         , attribute "data-toggle" "dropdown"
    --         , attribute "aria-haspopup" "true"
    --         , attribute "aria-expanded" "false"
    --         ]
    --         [
    --          text "Album"
    --         , span [ class "caret" ] [ ]
    --         ]
    --     , ul
    --         [ class "dropdown-menu"
    --         ]
    --         [
    --           li [] [ a [ href "#" ] [ text "Artist" ] ]
    --         , li [] [ a [ href "#" ] [ text "Genre" ] ]
    --         , li [] [ a [ href "#" ] [ text "Song" ] ]
    --         , li
    --             [ attribute "role" "separator"
    --             , class "divider" ]
    --           [ ]
    --         , li [] [ a [ href "#" ] [ text "Everything" ] ]
    --         ]
    --     ]
    , span
        [ class "input-group-btn"
        ]
        [ (btnDefault_ { btnParam | label <- Just "Search" } address SubmitQuery )
        ]
    ]

resultsList address model =
  let
    toEntry answer =
      div
        [class "col-xs-2 col-md-3"]
        [resultView answer]
  in
    row_ (List.map toEntry model.albums)


resultView : Album -> Html
resultView answer =
  div [class "panel panel-info"]
      [ div
          [class "panel-heading"]
          [text "Album"]
      , div
          [ class "panel-body"
          , style [("height", "10rem")]
          ]
          [text answer.name]
      ]

bootstrap =
  node "link"
    [ href "/bootstrap-3.3.5-dist/css/bootstrap.min.css"
    , rel "stylesheet"
    ]
    []


-- EFFECTS

(=>) = (,)


search : String -> Effects Action
search query =
  Http.get decodeAlbums (searchUrl query)
    |> Task.toMaybe
    |> Task.map ReceiveAlbums
    |> Effects.task

searchUrl : String -> String
searchUrl query =
  Http.url "https://api.spotify.com/v1/search"
    [ "q" => query
    , "type" => "album"
    ]

decodeAlbums : Json.Decoder (List Album)
decodeAlbums =
  let
    albumName =
      Json.map Album ("name" := Json.string)
  in
    (Json.at ["albums", "items"] (Json.list albumName))

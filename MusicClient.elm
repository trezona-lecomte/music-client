module MusicClient where

import Html exposing (..)
import String exposing (toLower)
import Html.Attributes exposing (..)
import Effects exposing (Effects)
import Html.Events exposing (onClick)
import Http
import Json.Decode as Json exposing ((:=))
import Task exposing (..)
import Signal exposing (..)
import Debug

import Events exposing (onChange, onEnter)
import Album


-- MODEL

type alias Model =
  { query : String
  , category : String
  , albums : List Album.Album
  }


init : (Model, Effects Action)
init =
  ( Model "" "album" []
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
      ( model
      , search model.query
      ) |> Debug.log "SubmitQuery"

    ReceiveAlbums maybeAlbums ->
      ( { model | albums = (Maybe.withDefault [] maybeAlbums) }
      , Effects.none
      ) |> Debug.log "ReceiveAlbums"

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
    [ class "wrap container-fud" ]
    [ flexboxgridCss
    , customCss
    , div
        [ class "container-fluid" ]
        [ div [ class "col-md-1" ] []
        , div [ class "col-md-10" ]
              [ searchForm address model ]
        , div [ class "col-md-1" ] []
        ]
    , div
        [ class "container-fluid" ]
        [ div [ class "col-md-2 col-sm-2" ] []
        , div [ class "col-md-9 col-sm-10" ]
              [ resultList address model ]
        , div [ class "col-md-1 col-sm-0" ] []
        ]
    ]

searchForm address model =
  div
    [ class "input-group row"
    , id "search-form"
    ]
    [ input
        [ type' "text"
        , class "form-control"
        , id "search-text-input"
        , placeholder "Search for..."
        , value model.query
        , onChange address UpdateQuery
        , onEnter address SubmitQuery
        ]
        []
    , div
      [ class "input-group-btn" ]
      [ button
          [ class "btn btn-default form-control"
          , id "search-button"
          , onClick address SubmitQuery
          ]
          [ text "Search"
          ]
      ]
    ]

resultList address model =
  let
    toEntry item =
      li
        [ class "list-group-item col-md-3 col-sm-4 item-panel" ]
        [ Album.view item ]
  in
    ul
    [ class "list-group row"
    , id "result-list"
    ]
    (List.map toEntry model.albums)

row =
  div [class "row"]

flexboxgridCss =
  node "link"
    [ href "css/flexboxgrid.css"
    , rel "stylesheet"
    ]
    []

customCss =
  node "link"
    [ href "css/custom.css"
    , rel "stylesheet"
    ]
    []



--------------------------------------------------------------------------------

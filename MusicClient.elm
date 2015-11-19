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
      ( { model | query = newQuery }
      , Effects.none
      ) |> Debug.watch "UpdateQuery"

    SubmitQuery ->
      ( model
      , search model.query
      ) |> Debug.watch "SubmitQuery"

    ReceiveAlbums maybeAlbums ->
      ( { model | albums = (Maybe.withDefault [] maybeAlbums) }
      , Effects.none
      ) |> Debug.watch "ReceiveAlbums"

    NoOp ->
      (model, Effects.none)


-- VIEW

view : Signal.Address Action -> Model -> Html
view address model =
  div
    [style [("margin", "20px 0")]]
    [ div
        [ class "container-fluid" ]
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
    , select
        [ name "search-type"
        , class "form-control"
        ]
        [ option [ value "Everything" ] [ text "Everything" ]
        , option [ value "Album" ] [ text "Album" ]
        , option [ value "Artist" ] [ text "Artist" ]
        , option [ value "Song" ] [ text "Song" ]
        ]
    , span
        [ class "input-group-btn"
        ]
        [ button
            [ class "btn btn-default"
            , onClick address SubmitQuery
            ]
            [ text "Search" ]
        ]
    ]

resultsList address model =
  let
    toEntry album =
      li
        [ class "list-group-item col-md-4 col-sm-6" ]
        [ resultView album ]
  in
    ul
    [ class "list-group row" ]
    (List.map toEntry model.albums)


resultView : Album -> Html
resultView album =
  div [class "media panel"]
      [ div
          [ class "media-left"]
          [ a [ href "https://play.spotify.com/album/3EkYAh7JiJNSUxzhVLJqnL?play=true&utm_source=open.spotify.com&utm_medium=open"
              ]
              [ img [ class "media-object"
                    , src "http://st.cdjapan.co.jp/pictures/s/03/21/HSE-60064.jpg?v=1"
                    ] []
              ]
          ]
      , div
          [ class "media-body" ]
          [ h4 [ class "media-heading" ]
               [ text album.name ]
          ]
      ]

row =
  div [class "row"]


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

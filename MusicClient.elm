module MusicClient where

import String
import Array exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Effects exposing (Effects)
import Html.Events exposing (onClick)
import Http
import Json.Decode as Json exposing ((:=))
import Task exposing (..)
import Signal exposing (..)
import Debug

import Events exposing (onChange, onEnter)
import ColorScheme


-- MODEL

type alias Model =
  { query : String
  , category : String
  , items : List Item
  }


type alias Item =
  { name : String
  , url : String
  , category : String
  , images : List Image
  }

type alias Image =
  { url : String
  , width : Int
  , height : Int
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
  | UpdateCategory String
  | SubmitQuery
  | ReceiveItems (Maybe (List Item))


update : Action -> Model -> (Model, Effects Action)
update action model =
  case action of
    UpdateQuery newQuery ->
      ( { model | query = newQuery }
      , Effects.none
      )

    UpdateCategory newCategory ->
      ( { model | category = (String.toLower newCategory) }
      , Effects.none
      )

    SubmitQuery ->
      ( model
      , search model.query model.category
      ) |> Debug.log "SubmitQuery"

    ReceiveItems maybeItems ->
      ( { model | items = (Maybe.withDefault [] maybeItems) }
      , Effects.none
      ) |> Debug.log "ReceiveItems"

    NoOp ->
      (model, Effects.none)


-- EFFECTS

(=>) = (,)


search : String -> String -> Effects Action
search query category =
  Http.get (itemList category) (searchUrl query category)
    |> Task.toMaybe
    |> Task.map ReceiveItems
    |> Effects.task

searchUrl : String -> String -> String
searchUrl query category=
  Http.url "https://api.spotify.com/v1/search"
    [ "q" => query
    , "type" => category
    ]

itemList : String -> Json.Decoder (List Item)
itemList category =
  let
    collectionName = category ++ "s"
  in
    Json.at [collectionName, "items"] <| Json.list <|
      Json.object4 Item
        ("name" := Json.string)
        ("href" := Json.string)
        ("type" := Json.string)
        ("images" := imageList)

imageList : Json.Decoder (List Image)
imageList =
  Json.list <|
    Json.object3 Image
      ("url" := Json.string)
      ("width" := Json.int)
      ("height" := Json.int)


-- VIEW ---------------------------------------------------------------------

view : Signal.Address Action -> Model -> Html
view address model =
  div
    [style [("margin", "20px 0")]]
    [ div
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
      [ select
          [ name "search-type"
          , class "form-control"
          , id "search-type-dropdown"
          , onChange address UpdateCategory
          ]
          [ option [ value "Album" ] [ text "Album" ]
          , option [ value "Artist" ] [ text "Artist" ]
          , option [ value "Track" ] [ text "Track" ]
          ]
      ]
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
        [ itemPanel item ]
  in
    ul
    [ class "list-group row"
    , id "result-list"
    ]
    (List.map toEntry model.items)


imageUrl : Item -> String
imageUrl item =
  let
    smallestImage =
      Maybe.withDefault (Image "" 0 0) (List.head (List.reverse item.images))
  in
    smallestImage.url

itemPanel : Item -> Html
itemPanel item =
  div [class "media panel"]
      [ div
        [ class "media-left"]
        [ a [ href item.url
            ]
            [ img [ class "media-object"
                  , src (imageUrl item)
                  ] []
            ]
        ]
      , div
        [ class "media-body" ]
        [ h4 [ class "media-heading" ]
             [ text item.name ]
        ]
      ]

row =
  div [class "row"]


--------------------------------------------------------------------------------

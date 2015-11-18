module MusicClient where

import Html exposing (..)
import Html.Attributes exposing (..)
import Effects exposing (Effects)
import Html.Events exposing (onClick)
import Events exposing (onChange, onEnter)
import Http
import Json.Decode as Json exposing ((:=))
import Task
import Signal exposing (..)
import ColorScheme
import Flex
import Debug


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


tile : Html -> Float -> String -> Html
tile element grow color =
  let
      backgroundStyles =
        ("background-color", color)
        :: Flex.grow grow
  in
      div
        [ style backgroundStyles ]
        [ element ]

view : Signal.Address Action -> Model -> Html
view address model =
  let
      topSection    = tile (text "top section") 1 ColorScheme.greyBlue
      bottomSection = tile (text "bottom section") 1 ColorScheme.blue
      leftSection   = tile (text "left section") 1 ColorScheme.lightGrey
      rightSection  = tile (text "right section") 1 ColorScheme.mediumGrey
      centerSection = tile (searchPane address model) 4 ColorScheme.green

      styleList =
        Flex.direction Flex.Horizontal
        ++ Flex.grow 8
        ++ Flex.display

      mainSection =
        div
          [ style styleList ]
          [ leftSection
          , centerSection
          , rightSection
          ]

      mainStyleList =
        [ ("width", "100vw")
        , ("height", "100vh")
        ]
        ++ Flex.display
        ++ Flex.direction Flex.Vertical

  in
      div
        [ style mainStyleList ]
        [ topSection
        , mainSection
        , bottomSection
        ]

searchPane : Signal.Address Action -> Model -> Html
searchPane address model =
  div
    []
    [ searchForm address model
    , resultList address model
    ]

searchForm : Signal.Address Action -> Model -> Html
searchForm address model =
  div
    [ class "flex-form"
    ]
    [ input
        [ type' "text"
        , value model.query
        , onChange address UpdateQuery
        , onEnter address SubmitQuery
        , style
            [
            ]
        ]
        []
    , select
        [ name "search-type"
        , style
            [
            ]
        ]
        [ option [ value "Album" ] [ text "Album" ]
        , option [ value "Artist" ] [ text "Artist" ]
        , option [ value "Song" ] [ text "Song" ]
        ]
    , button
        [ type' "submit"
        , value "Search"
        , onClick address SubmitQuery
        , style
            [
            ]
        ]
        []
    ]

resultList : Signal.Address Action -> Model -> Html
resultList address model =
  let
    toResult album =
      div
        [ class "item" ]
        [ resultView album ]
  in
    div
      [ ]
      (List.map toResult model.albums)

resultView : Album -> Html
resultView album =
  div [ class "result" ]
      [ div
          [class "result-heading"]
          [text "Result"]
      , div
          [ class "result-body"
          , style [("height", "10rem")]
          ]
          [text album.name]
      ]


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

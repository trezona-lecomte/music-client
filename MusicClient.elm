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

view : Signal.Address Action -> Model -> Html
view address model =
  div [ class "wrapper"
      , style
        [ ("display", "flex")
        , ("flex-direction", "column")
        -- , ("justify-content", "space-between")
        , ("flex-wrap", "nowrap")
        -- , ("justify-content", "flex-start")
        -- , ("align-items", "stretch")
        -- , ("align-content", "stretch")
        , ("width", "100vw")
        , ("height", "100%")
        , ("background-image", "linear-gradient(180deg, #D4B06A 0%, #152A55 100%)")
        ]
      ]
      [ div
          [ class "container"
          , id "top-section"
          , style
            [ ("display", "flex")

            -- , ("flex", "1")
            -- , ("align-self", "flex-start")
            , ("flex-basis", "40vh")
            -- , ("justify-content", "center")
            -- , ("align-items", "center")
            , ("border", "5px solid mistyrose")
            ]
          ]
        [ ]
      , div
        [ class "container"
        , id "top-section"
        , style
          [ ("display", "100%")
            -- , ("flex", "1")
            -- , ("align-self", "flex-start")
          , ("flex-basis", "10vh")
          -- , ("justify-content", "center")
          -- , ("align-items", "center")
          , ("border", "5px solid mistyrose")
          ]
        ]
        [ searchForm address model
        ]
    , div
        [ class "container"
        , id "top-section"
        , style
          [ ("display", "fle")
           , ("flex", "1 1 auto")
          -- , ("flex-wrap", "nowrap")
            -- , ("align-self", "flex-end")
          , ("flex-basis", "40vh")
          , ("border", "5px solid goldenrod")
          -- , ("justify-content", "center")
          -- , ("align-items", "center")
          ]
        ]
        [ resultList address model
        ]
    ]

    -- <form  class="flex-form">

    --   <input type="search" placeholder="Where do you want to go?">

    --   <label for="from">From</label>
    --   <input type="date" name="from">

    --   <label for="from">To</label>
    --   <input type="date" name="to">

    --   <select name="" id="">
    --     <option value="1">1 Guest</option>
    --     <option value="2">2 Guest</option>
    --     <option value="3">3 Guest</option>
    --     <option value="4">4 Guest</option>
    --     <option value="5">5 Guest</option>
    --   </select>

    --   <input type="submit" value="Search">

    -- </form>


searchForm : Signal.Address Action -> Model -> Html
searchForm address model =
  div
    [ class "flex-form"
    , style
      [ ("display", "flex")
      , ("flex-direction", "row")
      , ("flex-basis", "500px")
      , ("z-index", "10")
      , ("border", "20px solid rgba(0,0,0,0.3)")
      , ("border-radius", "5px")
      ]
    ]
    [ input
        [ type' "text"
        , value model.query
        , onChange address UpdateQuery
        , onEnter address SubmitQuery
        , style
            [ ("flex", "3 1 200px") ]
        ]
        []
    , select
        [ name "search-type"
        , style
            [ ("flex", "1 1 50px") ]
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
            [ ("flex", "2 1 50px")
            , ("background", "#061639")
            , ("border", "1px solid #061639")
            , ("color", "white")
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

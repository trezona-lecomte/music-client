module Album where

import Html exposing (..)
import Html.Attributes exposing (..)
import Json.Decode as Json exposing ((:=))

import Image exposing (Image, imageListDecoder)

-- MODEL

type alias Album =
  { name : String
  , url : String
  , images : List Image
  }

init : Album
init =
  Album "" "" []


-- UPDATE
-- EFFECTS

albumListDecoder : Json.Decoder (List Album)
albumListDecoder =
  Json.at ["albums", "items"] <|
    Json.list <|
      Json.object3 Album
            ("name" := Json.string)
            ("href" := Json.string)
            ("images" := imageListDecoder)


-- VIEW

albumList : List Album -> Html
albumList albums =
  div
    [ ]
    [ ul
      [ class "list-group row"
      , id "result-list"
      ]
      (List.map listItem albums)
    ]

listItem : Album -> Html
listItem model =
  div
    [ class "media panel" ]
    [ div
        [ class "media-left"]
        [ a
            [ href model.url ]
            [ img
                [ class "media-object"
                , src (smallestImageUrl model)
                ]
                []
            ]
        ]
    , div
        [ class "media-body" ]
        [ h4
            [ class "media-heading" ]
            [ text model.name ]
        ]
    ]

smallestImageUrl : Album -> String
smallestImageUrl model =
  let
    smallestImage =
      Maybe.withDefault (Image "" 0 0) (List.head (List.reverse model.images))
  in
    smallestImage.url

module Album where

import Html exposing (..)
import Html.Attributes exposing (..)
import Json.Decode as Json exposing ((:=))

import Image exposing (Image, imageListDecoder)
import CustomElements exposing (container, box)

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
            ("external_urls" := externalUrlDecoder)
            ("images" := imageListDecoder)

externalUrlDecoder : Json.Decoder String
externalUrlDecoder =
  Json.at ["spotify"] <| Json.string

-- VIEW

albumList : List Album -> Html
albumList albums =
  div
    [ class "container"
    ]
    [ ul
      [ class "container album-list"
      ]
      (List.map listItem albums)
    ]

listItem : Album -> Html
listItem model =
  div
    [ class "box media-object callout primary album-list-item hvr-hollow"
    ]
    [ a
      [ href model.url ]
      [ div
        [ class "media-object-section"]
        [ img
          [ class "thumbnail"
          , src (smallestImageUrl model)
          ]
          []
        ]
      , div
        [ class "media-object-section middle" ]
        [ p
          [ class "" ]
          [ text model.name ]
        ]
      ]
    ]

smallestImageUrl : Album -> String
smallestImageUrl model =
  let
    smallestImage =
      Maybe.withDefault (Image "" 0 0) (List.head (List.reverse model.images))
  in
    smallestImage.url

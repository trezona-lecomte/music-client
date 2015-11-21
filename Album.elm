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
      [ class ""
      , id "album-list"
      ]
      (List.map listItem albums)
    ]

listItem : Album -> Html
listItem model =
  div
    [ class "" ]
    [ div
        [ class ""]
        [ a
            [ href model.url ]
            [ img
                [ class ""
                , src (smallestImageUrl model)
                ]
                []
            ]
        ]
    , div
        [ class "" ]
        [ h4
            [ class "" ]
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

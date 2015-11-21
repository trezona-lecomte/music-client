module Image where

import Json.Decode as Json exposing ((:=))

-- MODEL

type alias Image =
  { url : String
  , width : Int
  , height : Int
}

init : Image
init =
  Image "" 0 0


-- EFFECTS

imageListDecoder : Json.Decoder (List Image)
imageListDecoder =
  Json.list <|
    Json.object3 Image
      ("url" := Json.string)
      ("width" := Json.int)
      ("height" := Json.int)

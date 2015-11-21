module Main where

import Effects exposing (Never)
import StartApp
import Task

import MusicClient as Client


app =
  StartApp.start
    { init = Client.init
    , update = Client.update
    , view = Client.view
    , inputs = []
    }


main =
  app.html


port tasks : Signal (Task.Task Never ())
port tasks =
  app.tasks

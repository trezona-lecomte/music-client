module Main where

import Effects exposing (Never)
import StartApp
import Task

import MusicApp as MusicApp


app =
  StartApp.start
    { init = MusicApp.init
    , update = MusicApp.update
    , view = MusicApp.view
    , inputs = []
    }


main =
  app.html


port tasks : Signal (Task.Task Never ())
port tasks =
  app.tasks

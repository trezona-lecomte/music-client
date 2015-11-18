import Effects exposing (Never)
import MusicClient
import StartApp
import Task


app =
  StartApp.start
    { init = MusicClient.Initial
    , update = MusicClient.update
    , view = MusicClient.view
    , inputs = []
    }


main =
  app.html


port tasks : Signal (Task.Task Never ())
port tasks =
  app.tasks

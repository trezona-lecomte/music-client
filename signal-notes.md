# Elm Signals

## Mapping over signals

    map : (a -> result) -> Signal a -> Signal result


## Combining Signals

We can map over a signal like so:

    Signal.map view Mouse.x

But what if we wanted view to update whenever two signals change?

    Signal.map2 view Mouse.x Window.width


## Filtering Signals

    sampleOn : Signal a -> Signal b -> Signal b

For example, what if we want to show the mouse position only when the
mouse is clicked??

    clickPosition : Signal (Int, Int)
    clickPosition =
      Signal.sampleOn Mouse.click Mouse.position


## Maintaining State

Folding:

    foldl : (a -> b -> b) -> b -> List a -> b

This just reduces a list from the left, used as follows:

    foldl (\number sum -> sum + number) 0 [1, 2, 3]
    > 6 : number

We can also fold values of a signal:

    foldp
      :  (a -> state -> state)
      -> state
      -> Signal a
      -> Signal state

The only difference here is that instead of a list, it takes a signal
and returns the folded signal:

    state =
      Signal.foldp (\key count -> count + 1) 0 Keyboard.presses

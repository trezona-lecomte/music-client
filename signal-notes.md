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


## Merging Signals

See the spaceship example code. Essentially you'll have more than 1
signal of Action, so these will need to be merged. These should be
merged at the stage of the foldp:

    input : Signal Action
    input =
      Signal.merge direction fire

    model : Signal Model
    model =
      Signal.foldp update initialShop input

*We merge multiple input signals (unified by the Action type). We then*
*feed this merged signal of actions into one foldp to transform the*
*model. This transformation results in a signal of Model which is*
*essentially our state.*

You want your signals to live at the edge of your app.

# Translating this to an HTML app

Unlike in a game, we don't have built-in signals for html
elements. This is where mailboxes come in.

## Mailboxes

A mailbox is a place where we can send message. It has an Address and
a Signal. When a message is sent to the address, the corresponding
Signal is updated with a new value (so that the signal represents all
the messages that have been sent to that address). A mailbox is simply
an assocation between an address and a signal.

    type alias Mailbox a =
      { address : Address a
      , signal : Signal a
      }

It's a basic pub/sub system. Publishers sent messages to the Address,
and subscribers react to the Signal.

Example:

    view : Signal.Address String -> String -> Html
    view address greeting =
      div
        []
        [ button
            [ on "click" targetValue (\value -> Signal.message inbox.address "Hello") ]
            [ text "Click to say Hello" ]
        , button
            [ onClick address "Salut!") ]
            [ text "Click to say Salut" ]
        , p [ ] [ text greeting ]
        ]

    inbox : Signal.Mailbox String
    inbox =
      Signal.mailbox "Waiting..."

    messages : Signal String
    messages =
      inbox.signal

    main : Signal Html
    main =
      Signal.map (view inbox.address) messages

## Maintaining State in an HTML app

    inbox : Signal.Mailbox Action
    inbox =
      Signal.mailbox NoOp     -- NoOp is handy cos a Signal always needs a value

    actions : Signal Action
    actions =
      inbox.signal

    model : Signal Model
    model =
      Signal.foldp update initialModel actions

    main : Signal Html
    main =
      Signal.map (view inbox.address) model

This is equivalent to:

    main : Signal Html
    main =
      StartApp.start { model = initialModel, view = view, update = update }


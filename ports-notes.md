# Elm Ports

Ports are either incoming or outgoing. They're declared with the
`port` keyword:

    port comments : Signal String

We can treat this the same as any other Signal. To send signal to this
port from js we could do:

    var elmApp = Elm.embed(Elm.Thumbs, elmDiv, { comments: "" });
    elmApp.ports.comments.send(form.comment.value);

Incoming ports don't need a definition, but outgoing ports do.

    port modelChanges : Signal Model
    port modelChanges =
      model

To subscribe to the above port in js we could do:

    elmApp.ports.modelChanges.subscribe(function(model) {
      console.log(model);
    });



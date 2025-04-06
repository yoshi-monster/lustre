// IMPORTS ---------------------------------------------------------------------

import gleam/list
import gleam/option.{None, Some}
import gleam/result
import gleam/string
import lustre
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import lustre/event

// MAIN ------------------------------------------------------------------------

pub fn main() {
  let app = lustre.simple(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)

  Nil
}

// MODEL -----------------------------------------------------------------------

type Model {
  // As an alternative to controlled inputs, Lustre also supports non-controlled
  // forms. Instead of us having to manage the state and appropriate messages
  // for each input, we use the platform and let the browser handle these things
  // for us.
  //
  // Here, we do not need to store the input values in the model at all, only
  // keeping the username once the user is logged in!
  NoLoginTriedYet
  LoginFailed
  LoggedIn(username: String)
}

fn init(_) -> Model {
  NoLoginTriedYet
}

type Msg {
  // Instead of receiving messages while the user edits the values, we only
  // receive a single message with all the data once the form is submitted.
  UserSubmittedForm(List(#(String, String)))
}

// UPDATE ----------------------------------------------------------------------

fn update(_model: Model, msg: Msg) -> Model {
  case msg {
    UserSubmittedForm(data) -> {
      // Lustre sends us the form data as a list of tuples, which we can then
      // process, decode, or send off to our backend.
      // 
      // Here we use the `list.key_find` function to get our form values, but
      // depending on your needs it might also make sense to use a library like
      // `formal` to decode the list into a Gleam custom type!
      let username = data |> list.key_find("username") |> result.unwrap("")
      let password = data |> list.key_find("password") |> result.unwrap("")

      case username == string.lowercase(username) && password == "strawberry" {
        True -> LoggedIn(username:)
        False -> LoginFailed
      }
    }
  }
}

// VIEW ------------------------------------------------------------------------

fn view(model: Model) -> Element(Msg) {
  html.div(
    [attribute.class("p-32 mx-auto w-full max-w-2xl space-y-4")],
    case model {
      NoLoginTriedYet -> [view_login_form(None)]
      LoginFailed -> [view_login_form(Some("Invalid username or password!"))]
      LoggedIn(username:) -> [
        html.h1([attribute.class("text-2xl font-medium")], [
          html.text("Welcome, "),
          html.span([attribute.class("text-purple-600 font-bold")], [
            html.text(username),
          ]),
          html.text("!"),
        ]),
        html.p([], [html.text("I hope you're having a lovely day!")]),
      ]
    },
  )
}

fn view_login_form(error_message: option.Option(String)) -> Element(Msg) {
  html.form(
    [
      attribute.class("p-8 w-full border rounded-2xl shadow-lg space-y-4"),
      // The message provided to the built-in `on_submit` handler receives the
      // `FormData` associated with the form as a List of (name, value) tuples.
      // 
      // The event handler also calls `preventDefault()` on the form, such that
      // Lustre can handle the submission instead off being sent off to the server.
      event.on_submit(UserSubmittedForm),
    ],
    [
      html.h1([attribute.class("text-2xl font-medium text-purple-600")], [
        html.text("Sign in"),
      ]),
      html.div([], [
        html.label(
          [
            attribute.for("username"),
            attribute.class("text-xs font-bold text-slate-600"),
          ],
          [html.text("Username:")],
        ),
        html.input([
          attribute.type_("text"),
          attribute.class("block mt-1 w-full px-3 py-1 border rounded-lg "),
          attribute.class("focus:shadow focus:outline focus:outline-purple-600"),
          // we use the `id` in the associated `for` attribute on the label
          attribute.id("username"),
          // the `name` attribute is used as the first element of the tuple
          // we receive for this input.
          attribute.name("username"),
          // Associating a value with this element does _not_ make the element
          // controlled without an event listener, allowing us to set a default.
          attribute.value("lucy"),
          attribute.autocomplete("username"),
        ]),
      ]),
      html.div([], [
        html.label(
          [
            attribute.for("password"),
            attribute.class("text-xs font-bold text-slate-600"),
          ],
          [html.text("Password:")],
        ),
        html.input([
          attribute.class("block mt-1 w-full px-3 py-1 border rounded-lg"),
          attribute.class("focus:shadow focus:outline focus:outline-purple-600"),
          attribute.id("password"),
          attribute.name("password"),
          attribute.type_("password"),
          attribute.autocomplete("current-password"),
          attribute.autofocus(True),
        ]),
      ]),
      case error_message {
        Some(error_message) ->
          html.p([attribute.class("text-xs text-red-500")], [
            html.text(error_message),
          ])
        None -> element.none()
      },
      html.div([attribute.class("flex justify-end")], [
        html.button(
          [
            // buttons inside of forms submit the form by default.
            // attribute.type_("submit"),
            attribute.class("text-white text-sm font-bold"),
            attribute.class("px-4 py-2 bg-purple-600 rounded-lg"),
            attribute.class("hover:bg-purple-800"),
            attribute.class(
              "focus:outline-2 focus:outline-offset-2 focus:outline-purple-800",
            ),
          ],
          [html.text("Login")],
        ),
      ]),
    ],
  )
}

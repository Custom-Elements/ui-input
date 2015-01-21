#ui-input
This is a text input element, with a couple additional bits of awesome:

* `multiline` support, no need to worry about `<input>` vs `<textarea>`
* `esc` clears the input.


    moment = require 'moment'
    require 'ui-styles/animations'

    Polymer 'ui-input',

##Events
###change
Fired when the `value` changes. This is a tad debounced.

##Attributes and Change Handlers
###multiline
Set this to true to create a multiline, self resizing input.
###value
This will contain the user's typed text, and will be updated live with each
keypress.
Some values will need to be parsed and typed.

      valueChanged: (oldValue, newValue)->
        placeholder = @shadowRoot.querySelector('placeholder')
        if not @hasAttribute 'focused'
          @focusOut()
        else if @value
          placeholder.fadeOut()
        @fireChange()

###placeholder
Text to prompt the user before they start to input.

###disabled
When flagged, the field won't take a focus.

###type
An HTML5 input type, defaults to `text`.

### autocapitalize
none (default) or sentences, words, characters to control capitalizations on mobile

### autocorrect
off (default) or off to disable corrections

### autocomplete
off (default) or off to disable completion

##Methods
###scrubValue
Make `value` conform to the expectations of HTML input controls.

      scrubValue:
        toDOM: (value) ->
          if @type is 'date' and value
            moment(value).utc().format("YYYY-MM-DD")
          else
            value
        toModel: (value) ->
          if @type is 'date' and value
            moment(value).utc().format("YYYY-MM-DD")
          else
            value

##Event Handlers

# lets focus (ha) on focusin focusout instead of blur.. also we fireChange as our change
to the outside world

When leaving, show the preview if present, this works together with focusIn

      focusOut: (evt) ->
        preview = @querySelector('preview')
        placeholder = @shadowRoot.querySelector('placeholder')
        input = @$.input
        @removeAttribute 'focused'
        if preview
          input.fadeOut =>
            @$.input.setAttribute 'invisible', ''
            @$.input.removeAttribute 'hidden'
            if preview and @value
              preview.fadeIn()
              placeholder.fadeOut()
            else
              preview.fadeOut()
              placeholder.fadeIn()
        else
          if not @value
            input.fadeOut =>
              @$.input.setAttribute 'invisible', ''
              @$.input.removeAttribute 'hidden'
              placeholder.fadeIn()

This gets a bit complicated to have an animation showing the
actual input control, hiding a preview -- but only if there is a preview.

OK -- so this is a bit tricky, in that the INPUT is never actuall hidden,
or it ceases to be a tab stop. So we just make it invisible and count on flexbox
to crush it

      focusIn: (evt) ->
        if @hasAttribute 'disabled'
          return
        if not @hasAttribute 'focused'
          @setAttribute 'focused', ''

          preview = @querySelector('preview')
          placeholder = @shadowRoot.querySelector('placeholder')
          input = @$.input

          placeholder.fadeOut ->
            if preview
              placeholder.fadeOut ->
                preview.fadeOut ->
                  input.removeAttribute 'invisible'
                  input.fadeIn
            else
              placeholder.fadeOut ->
                input.removeAttribute 'invisible'
                input.fadeIn

          input.focus()

      keydown: (evt) ->
        @value = null if evt.keyCode is 27

      fireChange: ->
        @job 'change', ->
          @fire 'change', @value
        , 300

##Polymer Lifecycle

      created: ->
        @type = 'text'
        @autocomplete = "off"
        @autocorrect = "off"
        @autocapitalize = "none"

      ready: ->

      attached: ->
        if @hasAttribute 'multiline'
          @multiline = true
        else
          @multiline = false
        @querySelector('preview')?.fadeOut()
        @focusOut()

      domReady: ->

      detached: ->

      publish:
        value:
          reflect: true

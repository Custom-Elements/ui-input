#ui-input
This is a text input element, with a couple additional bits of awesome:

* `multiline` support, no need to worry about `<input>` vs `<textarea>`
* `esc` clears the input.


    moment = require 'moment'
    _ = require 'lodash-node'
    require 'ui-styles/animations'

    Polymer 'ui-input',

##Events
###change
Fired when the `value` changes.

##Attributes and Change Handlers
###multiline
Set this to true to create a multiline, self resizing input.
###value
This will contain the user's typed text, and will be updated live with each
keypress.
Some values will need to be parsed and typed.

Placeholders will be hidden if there is a value. No need for animation, as
we will already be animated to the editor when this happens.

      valueChanged: (oldValue, newValue)->
        if @value
          @shadowRoot.querySelector('placeholder').setAttribute 'hidden', ''
        else
          @shadowRoot.querySelector('placeholder').removeAttribute 'hidden'
        @fireChange()

###placeholder
Text to prompt the user before they start to input.
###disabled
When flagged, the field won't take a focus.

      disabledChanged: ->
        if @hasAttribute 'disabled'
          @$.input.setAttribute 'disabled', ''
        else
          @$.input.removeAttribute 'disbabled'

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

###resize
Resize to the content, eliminating pesky scrolling. This only works when
`multiline="true"`.

      resize: ->
        textarea = @shadowRoot.querySelector 'textarea'
        setTimeout ->
          textarea.style.height = 'auto'
          textarea.style.height = "#{textarea.scrollHeight+2}px"

##Event Handlers
Blur, focus, and change apparently don't bubble by default. So, this input
will normalized that behavior and merrily bubble them.

      bubble: (evt) ->
        if evt
          @fire evt.type, null, this, false

When leaving, show the preview if present, this works together with inputFocus
so... keep them close together in the file. The input will stay visible if
there is content and no other preview specified. But if there is no value
then we'll show the placeholder.

      blur: (evt) ->
        previewAndPlaceholder = @shadowRoot.querySelector('preview-and-placeholder')
        preview = @shadowRoot.querySelector('preview')
        input = @$.input
        if preview or not @value
          input.fadeOut =>
            @$.input.setAttribute 'invisible', ''
            previewAndPlaceholder.removeAttribute 'hidden'
            @removeAttribute 'focused'
            previewAndPlaceholder.fadeIn =>
              @bubble evt

This gets a bit complicated to have an animation showing the
actual input control, hiding a preview -- but only if there is a preview.

OK -- so this is a bit tricky, in that the INPUT is never actuall hidden,
or it ceases to be a tab stop. So we just make it invisible and count on flexbox
to crush it

      inputFocus: (evt) ->
        if @hasAttribute 'disabled'
          return
        previewAndPlaceholder = @shadowRoot.querySelector('preview-and-placeholder')
        input = @$.input
        if not @hasAttribute 'focused'
          previewAndPlaceholder.fadeOut =>
            previewAndPlaceholder.setAttribute 'hidden', ''
            input.removeAttribute 'invisible'
            input.fadeIn =>
              @resize() if @multiline?
              @setAttribute 'focused', ''
              @bubble evt
              input.focus()

      focus: ->
        @$.input.focus()

      change: (evt) ->
        @resize() if @multiline?
        @bubble evt

      keyup: (evt) ->
        @value = evt.target.value

      keydown: (evt) ->
        @resize() if @multiline?
        if evt.keyCode is 27
          @value = null

      cut: (evt) ->
        @resize() if @multiline?

      paste: (evt) ->
        @resize() if @multiline?

      drop: (evt) ->
        @resize() if @multiline?

##Polymer Lifecycle

      created: ->
        @type = 'text'
        @autocomplete = "off"
        @autocorrect = "off"
        @autocapitalize = "none"
        @fireChange = _.debounce =>
          @fire 'change', @value
        , 300

      ready: ->

      attached: ->
        @blur()

      domReady: ->

      detached: ->

      publish:
        value:
          reflect: true

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
        if @value
          placeholder.fadeOut()
        else if not @hasAttribute 'focused'
          placeholder.fadeIn()
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

      blur: (evt) ->
        preview = @querySelector('preview')
        placeholder = @shadowRoot.querySelector('placeholder')
        input = @$.input
        @removeAttribute 'focused'
        if preview
          input.fadeOut =>
            @$.input.setAttribute 'invisible', ''
            @$.input.removeAttribute 'hidden'
            if preview and @value
              preview.fadeIn =>
                @bubble evt
            else
              placeholder.fadeIn()
        else
          if not @value
            input.fadeOut =>
              @$.input.setAttribute 'invisible', ''
              @$.input.removeAttribute 'hidden'
              placeholder.fadeIn()
        @$.input.blur()


This gets a bit complicated to have an animation showing the
actual input control, hiding a preview -- but only if there is a preview.

OK -- so this is a bit tricky, in that the INPUT is never actuall hidden,
or it ceases to be a tab stop. So we just make it invisible and count on flexbox
to crush it

      inputFocus: (evt) ->
        if @hasAttribute 'disabled'
          return
        if not @hasAttribute 'focused'
          @setAttribute 'focused', ''
          preview = @querySelector('preview')
          placeholder = @shadowRoot.querySelector('placeholder')
          input = @$.input
          done = =>
            @resize() if @multiline?
            @bubble evt
            input.scrollIntoView(false)
            input.focus()
          placeholder.fadeOut ->
            if preview
              placeholder.fadeOut ->
                preview.fadeOut ->
                  input.removeAttribute 'invisible'
                  input.fadeIn ->
                    done()
            else
              placeholder.fadeOut ->
                input.removeAttribute 'invisible'
                input.fadeIn ->
                  done()

      focus: ->
        @$.input.focus()

      change: (evt) ->
        evt.stopPropagation()
        @resize() if @multiline?

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
        @querySelector('preview')?.fadeOut()
        @blur()

      domReady: ->

      detached: ->

      publish:
        value:
          reflect: true

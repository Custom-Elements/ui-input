#ui-input
This is a text input element, with a couple additional bits of awesome:

* `multiline` support, no need to worry about `<input>` vs `<textarea>`
* `esc` clears the input.

    Polymer 'ui-input',

##Events
Blur, focus, and change apparently don't bubble by default. So, this input
will normalized that behavior and merrily bubble them.

      bubble: (evt) ->
        @fire evt.type, null, this, false

      blur: (evt) ->
        @$.field.classList.remove 'focused'
        @bubble evt

      inputFocus: (evt) ->
        @$.field.classList.add 'focused'
        @bubble evt

      focus: ->
        @$.input.focus()

      change: (evt) ->
        @resize() if @multiline?
        @value = evt.target.value
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

##Attributes and Change Handlers
###multiline
Set this to true to create a multiline, self resizing input.
###value
This will contain the user's typed text, and will be updated live with each
keypress.

      valueChanged: ->
        console.log @value

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
###resize
Resize to the content, eliminating pesky scrolling. This only works when
`multiline="true"`.

      resize: ->
        textarea = @shadowRoot.querySelector 'textarea'
        setTimeout ->
          textarea.style.height = 'auto'
          textarea.style.height = "#{textarea.scrollHeight}px"

##Event Handlers

##Polymer Lifecycle

      created: ->
        @type = 'text'
        @autocomplete = "off"
        @autocorrect = "off"
        @autocapitalize = "none"

      publish:
        value:
          reflect: true

      ready: ->

      attached: ->

      domReady: ->

      detached: ->

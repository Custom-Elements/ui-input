#ui-input
This is a text input element, with a couple additional bits of awesome:

* `multiline` support, no need to worry about `<input>` vs `<textarea>`
* `esc` clears the input.

    moment = require 'moment'

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

      valueChanged: (oldValue, newValue)->
        if not oldValue or oldValue?.getTime?() isnt newValue?.getTime?()
          if @type is 'date'
            @value = moment(@value).utc().toDate()
        @fire 'change', @value

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

      scrubValue: (value) ->
        if @type is 'date'
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
so... keep them close together in the file.

      blur: (evt) ->
        preview = @querySelector('preview')
        if preview
          anim = @$.input.animate [
            {opacity: 1, transform: 'translateX(0)', offset: 0}
            {opacity: 0, transform: 'translateX(2%)', offset: 1}
          ], duration: 200, easing: "0.2s cubic-bezier(0.4, 0.0, 1, 1)"
          anim.onfinish = =>
            @$.input.setAttribute 'invisible', ''
            preview.removeAttribute 'hidden'
            @removeAttribute 'focused'
            anim = preview.animate [
              {opacity: 0, transform: 'translateX(2%)', offset: 0}
              {opacity: 1, transform: 'translateX(0)', offset: 1}
            ], duration: 200, easing: "0.2s cubic-bezier(0.4, 0.0, 1, 1)"
            anim.onfinish = =>
              @bubble evt
        else
          @removeAttribute 'focused'
          @bubble evt

This gets a bit complicated to have an animation showing the
actual input control, hiding a preview -- but only if there is a preview.

OK -- so this is a bit tricky, in that the INPUT is never actuall hidden,
or it ceases to be a tab stop. So we just make it invisible and count on flexbox
to crush it

      inputFocus: (evt) ->
        preview = @querySelector('preview')
        if preview and not @hasAttribute 'focused'
          anim = preview.animate [
            {opacity: 1, transform: 'translateX(0)', offset: 0}
            {opacity: 0, transform: 'translateX(2%)', offset: 1}
          ], duration: 200, easing: "0.2s cubic-bezier(0.4, 0.0, 1, 1)"
          anim.onfinish = =>
            preview.setAttribute 'hidden', ''
            @$.input.removeAttribute 'invisible'
            @setAttribute 'focused', ''
            anim = @$.input.animate [
              {opacity: 0, transform: 'translateX(2%)', offset: 0}
              {opacity: 1, transform: 'translateX(0)', offset: 1}
            ], duration: 200, easing: "0.2s cubic-bezier(0.4, 0.0, 1, 1)"
            anim.onfinish = =>
              @$.input.focus()
              @bubble evt
        else
          @setAttribute 'focused', ''
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

##Polymer Lifecycle

      created: ->
        @type = 'text'
        @autocomplete = "off"
        @autocorrect = "off"
        @autocapitalize = "none"

      ready: ->

      attached: ->
        @blur()

      domReady: ->

      detached: ->

      publish:
        value:
          reflect: true

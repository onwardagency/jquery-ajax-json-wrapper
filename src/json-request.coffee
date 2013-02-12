###
# simple wrapper around jquery.ajax()
# designed to handle a custom JSON response format from server,
# formatted like so:
# {
#   redirect: "/some/url/string" | null
#   status:   "ok" | "form-error" | "invalid-session" | "unprocessable-entity"
#   data:     { #json data obj }
#   html:     "<!-- escaped html string -->"
#   flash:    { ["notice" | "alert"] : "message to show" }
# }
###
$ = window.jQuery
$.jsonRequest = (url, options) ->
  # handle single argument of type Object
  if typeof url == 'object'
    options = url
    url     = options.url

  default_options =
    type:       'GET'
    dataType:   'json'
    modalFlash: false

  options ?= {}
  # Certain options are not optional
  options.url = url
  # options.dataType = 'json'

  options = $.extend default_options, options

  jsonResponse = null

  # Setup Callbacks from options arg
  cbSuccess = options.success or (jsonResponse) ->
    debug.info "jsonRequest success:", jsonResponse

  cbError = options.error or (jsonResponse, jqXHR, textStatus) ->
    debug.warn "jsonRequest error: + #{textStatus}", jsonResponse, jqXHR

  cbComplete = options.complete or (jsonResponse) ->
    # debug.info "jsonRequest complete:", jsonResponse

  # Wrap callbacks in custom response handling code
  options.success = (data, textStatus, jqXHR) ->
    jsonResponse = parseResponse jqXHR
    cbSuccess jsonResponse

  options.error = (jqXHR, textStatus) ->
    jsonResponse = parseResponse jqXHR
    jsonr_render_flash_messages {error: "Error: #{textStatus}"}
    cbError jsonResponse, jqXHR, textStatus

  options.complete = (jqXHR, textStatus) ->
    if jsonResponse?
      if jsonResponse.flash?
        jsonr_render_flash_messages jsonResponse.flash, options.modalFlash
      cbComplete jsonResponse

  # turn any server response into usable json
  parseResponse = (jqXHR) ->
    jsonResponse = {}
    content_type = jqXHR.getResponseHeader('content-type')
    if content_type.match /json/
      try
        jsonResponse = $.parseJSON jqXHR.responseText
        _performRedirect jsonResponse
      catch error
        debug.error "non-standard json response received"
    else if content_type.match(/javascript/)
      jsonResponse = jqXHR.responseText
    else if content_type.match(/html/)
      jsonResponse =
        html: jqXHR.responseText
    else
      debug.error "non-standard xhr response received of type: #{content_type}"
    jsonResponse


  _performRedirect = (jsonResponse) ->
    redirect = jsonResponse.redirect
    if redirect?.length
      window.jsonr_redirect redirect
      true
    else
      false

  # Actually make the request
  # debug.debug 'making jsonRequest', options
  $.ajax options

# custom helper to a perform URL redirect
window.jsonr_redirect ?= (url) ->
  window.location.href = url

###
 Custom method to display notifications to the user.
 Can be called in browser with a hash of flash messages.
 The modal option will raise a modal alert (not done by default)
 for example:
   var flash_json = { "success": "Successfully updated records" }
   jsonr_render_flash_messages(flash_json);
###
window.jsonr_render_flash_messages ?= (flash_json, modal = false) ->
  $flash_messages = if $('#flash_messages').length then $('#flash_messages') else '<div id="flash_messages"/>'
  $flash_messages.html("")   # reset flash messages
  if typeof flash_json is 'string'
    flash_json = [ flash_json ]
  for key of flash_json
    switch key
      when 'notice', 'success' then klass = 'success'
      else klass = 'error'
    if modal and klass == 'error'
      alert flash_json[key]
    else
      $flash_messages.append "<div class='alert alert-#{klass}'><i></i>#{flash_json[key]}</div>"



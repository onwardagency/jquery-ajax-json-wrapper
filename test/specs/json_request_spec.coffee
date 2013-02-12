# load the script(s) to test:
#= require lib/json-request
#= require ./fixtures/json_responses

describe "jQuery.jsonRequest", ->
  # quasi-globals
  request = onSuccess = onFailure = onComplete = jsonResponse = requestUrl = modalFlash = null

  beforeEach ->
    # loadFixtures 'calculator_page'
    spyOn window, 'jsonr_redirect'
    spyOn window, 'jsonr_render_flash_messages'

    jasmine.Ajax.useMock()  #load fixtures first, as they require functioning ajax

    onSuccess  = jasmine.createSpy 'onSuccess'
    onFailure  = jasmine.createSpy 'onFailure'
    onComplete = jasmine.createSpy 'onComplete'
    requestUrl = '/admin/preorders/1/edit'
    modalFlash = false

  describe "options, settings, arguments, inputs", ->

    describe "with a url string as the first and only argument", ->
      beforeEach ->
        $.jsonRequest requestUrl
        request = mostRecentAjaxRequest()

      it "should perform an ajax 'GET'", ->
        expect(request.method).toEqual 'GET'

      it "should request the url provided", ->
        expect(request.url).toEqual requestUrl

      it "accepts json content-type by default", ->
        expect(request.requestHeaders['Accept']).toMatch /json/

    describe "with a settings object as the first and only argument", ->
      requestUrl = '/admin/preorders/1/edit'

      it "should perform an ajax 'GET' request on the url provided", ->
        $.jsonRequest
          url: requestUrl
        request = mostRecentAjaxRequest()
        expect(request.method).toEqual 'GET'
        expect(request.url).toEqual requestUrl

      it "should honor the method 'type' option", ->
        $.jsonRequest
          url: requestUrl
          type: 'POST'
        request = mostRecentAjaxRequest()
        expect(request.method).toEqual 'POST'
        expect(request.url).toEqual requestUrl

      it "accepts json content-type by default", ->
        $.jsonRequest
          url: requestUrl
        request = mostRecentAjaxRequest()
        expect(request.requestHeaders['Accept']).toMatch /json/

      it "honors the 'dataType' option to set the Accept header", ->
        $.jsonRequest
          url: requestUrl
          dataType: 'script'
        request = mostRecentAjaxRequest()
        expect(request.requestHeaders['Accept']).not.toMatch /json/

      it "should be able to POST some form data", ->
        settings =
          type: 'post'
          url:  '/admin/profiles/294/update_profile'
          data: 'utf8=%E2%9C%93&_method=put&authenticity_token=P4k997MAUXOcmz5bfXTN8xCj6DPXS1El5L348yQmZ8M%3D&user%5Bfirstname%5D=Jenny&user%5Blastname%5D=Calcara&user%5Bemail%5D=jenny.calcara%40loomislabs.com'
        $.jsonRequest settings
        request = mostRecentAjaxRequest()
        # debug.debug request
        expect(request.method).toEqual settings.type.toUpperCase()
        expect(request.url).toEqual settings.url
        expect(request.params).toEqual settings.data

    describe "with a url string and settings as two arguments", ->
      requestUrl = '/admin/preorders/1/edit'

      it "should perform an ajax request of given type on the url provided", ->
        $.jsonRequest requestUrl,
          type: 'POST'
          url: '/another/url'
        request = mostRecentAjaxRequest()
        expect(request.method).toEqual 'POST'
        expect(request.url).toEqual requestUrl

      xit "should ignore arguments and always request the same data type", ->
        $.jsonRequest requestUrl,
          dataType: 'script'
        request = mostRecentAjaxRequest()
        expect(request.requestHeaders['Accept']).toContain 'application/json'


  describe "responses", ->

    beforeEach ->
      $.jsonRequest '/admin/preorders/1/edit',
        success: onSuccess
        error:   onFailure
        complete:onComplete
        modalFlash: modalFlash
      request = mostRecentAjaxRequest()

    afterEach ->
      # successArgs = onSuccess.mostRecentCall.args[0]
      # debug.debug "successArgs", successArgs
      # failureArgs = onFailure.mostRecentCall.args[0]
      # debug.debug "failureArgs", failureArgs

    it "should be defined", ->
      expect($.jsonRequest).toBeDefined()

    describe "on success", ->
      beforeEach ->
        request.response(Mocks.general.success)
        jsonResponse = JSON.parse request.responseText

      it "should execute given success callback", ->
        expect(onSuccess).toHaveBeenCalled()

      it "shouldn't execute any error callback", ->
        expect(onFailure).not.toHaveBeenCalled()

      it "shouldn't attempt to redirect", ->
        expect(jsonr_redirect).not.toHaveBeenCalled()

      it "should execute callback assigned to options.complete", ->
        expect(onComplete).toHaveBeenCalled()

      # leaving this as a possible feature for later -- would also be needed for onSuccess and onError
      xit "should be able to fire an array of onComplete callbacks", ->
        onCompleteAgain = jasmine.createSpy 'onCompleteAgain'
        $.jsonRequest
          url: requestUrl
          complete: [onCompleteAgain, onCompleteAgain, onCompleteAgain]
        request = mostRecentAjaxRequest()
        request.response Mocks.general.success
        expect(onCompleteAgain.callCount).toEqual 3


    describe "on success with flash", ->
      beforeEach ->
        request.response(Mocks.general.success_flash)

      it "should render flash message(s) when present", ->
        jsonResponse = JSON.parse request.responseText
        expect(jsonr_render_flash_messages).toHaveBeenCalledWith jsonResponse.flash, modalFlash


    describe "on success with redirect", ->
      beforeEach ->
        request.response(Mocks.general.success_redirect)
        jsonResponse = JSON.parse request.responseText

      it "should follow redirect url in response when present", ->
        expect(jsonr_redirect).toHaveBeenCalledWith jsonResponse.redirect

      it "shouldn't execute any error callback", ->
        expect(onFailure).not.toHaveBeenCalled()


    describe "on error", ->
      beforeEach ->
        request.response(Mocks.general.error)
        jsonResponse = JSON.parse request.responseText

      it "should execute given error callback", ->
        expect(onFailure).toHaveBeenCalled()

      it "should flash an error message", ->
        expect(jsonr_render_flash_messages).toHaveBeenCalled()

      it "shouldn't execute given success callback", ->
        expect(onSuccess).not.toHaveBeenCalled()

      it "should exec a callback provided to options.complete", ->
        expect(onComplete).toHaveBeenCalled()

      it "shouldn't attempt to redirect", ->
        expect(jsonr_redirect).not.toHaveBeenCalled()


    describe "on error with flash", ->
      beforeEach ->
        request.response(Mocks.general.error_flash)

      it "should render flash message(s) when present", ->
        jsonResponse = JSON.parse request.responseText
        expect(window.jsonr_render_flash_messages).toHaveBeenCalledWith jsonResponse.flash, modalFlash


    describe "on error with redirect", ->
      beforeEach ->
        request.response(Mocks.general.error_redirect)
        jsonResponse = JSON.parse request.responseText

      it "should follow redirect url in response", ->
        expect(jsonr_redirect).toHaveBeenCalledWith jsonResponse.redirect

      it "shouldn't execute success callback", ->
        expect(onSuccess).not.toHaveBeenCalled()


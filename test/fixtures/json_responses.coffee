@Mocks =
  general:
    success:
      status: 200
      responseText: '{ "status":"ok", "redirect":null, "data":"", "html":"", "flash":{} }'
    success_flash:
      status: 200
      responseText: '{ "status":"ok", "redirect":null, "data":"", "html":"", "flash":{"notice":"Action was successful."} }'
    success_redirect:
      status: 200
      responseText: '{ "status":"ok", "redirect":"/login", "data":"", "html":"", "flash":{"alert":"Please login first."} }'
    error:
      status: 400
      responseText: '{ "status":"error", "redirect":null, "data":"", "html":"", "flash":{} }'
    error_flash:
      status: 400
      responseText: '{ "status":"error", "redirect":null, "data":"", "html":"", "flash":{"alert":"An unknown error occurred."} }'
    error_redirect:
      status: 401
      responseText: '{ "status":"invalid-session", "redirect":"/login", "data":"", "html":"", "flash":{"alert":"Please login first."} }'

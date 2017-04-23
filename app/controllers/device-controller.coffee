debug = require('debug')('meshblu-authenticator-email-password:device-controller')
_ = require 'lodash'
validator = require 'validator'
url = require 'url'

class DeviceController
  constructor: ({@meshbluHttp, @deviceModel}) ->

  prepare: (request, response, next) =>
    {email,password,firstName,lastName} = request.body
    return response.status(422).send 'Password required' if _.isEmpty(password)
    return response.status(422).send 'Invalid email' unless validator.isEmail(email)

    query = {}
    email = email.toLowerCase()
    query[@deviceModel.authenticatorUuid + '.id'] = email

    request.email = email
    request.password = password
    request.deviceQuery = query
    request.firstName = firstName
    request.lastName = lastName

    next()

  create: (request, response) =>
    {deviceQuery, email, password, firstName, lastName} = request
    debug 'device query', deviceQuery

    @deviceModel.create
      query: deviceQuery
      data:
        type: 'account:user'
        id: email
        lastLogin: ''
        profile:
          image: ''
          firstName: firstName
          lastName: lastName
      user_id: email
      secret: password
    , @reply(request.body.callbackUrl, response, created : true)

  update: (request, response) =>
    {deviceQuery, email, password} = request
    {uuid} = request.body
    debug 'device query', deviceQuery
    return response.status(422).send 'Uuid required' if _.isEmpty(uuid)

    @deviceModel.addAuth
      query: deviceQuery
      uuid: uuid
      user_id: email
      secret: password
    , @reply(request.body.callbackUrl, response, created : false)

  reply: (callbackUrl, response, created) =>
    (error, device) =>
      if error?
        debug 'got an error', error.message
        if error.message == 'device already exists'
          return response.status(401).json error: "Unable to create user"

        if error.message == @ERROR_DEVICE_NOT_FOUND
          return response.status(401).json error: "Unable to find user"

        return response.status(500).json error: error.message

      if created
        messageReceived = {subscriberUuid: device.uuid, emitterUuid: device.uuid, type: 'message.received'}
        broadcastReceived = {subscriberUuid: device.uuid, emitterUuid: device.uuid, type: 'broadcast.received'}
        @meshbluHttp.createSubscription messageReceived, (error) =>
          if error?
            @meshbluHttp.unregister device.uuid (error) => {}
            return response.sendError error if error?
          @meshbluHttp.createSubscription broadcastReceived, (error) =>
            if error?
              @meshbluHttp.unregister device.uuid (error) => {}
              return response.sendError error if error?

      @meshbluHttp.generateAndStoreToken device.uuid, (error, device) =>
        return response.status(201).send(device: device) unless callbackUrl?

        uriParams = url.parse callbackUrl, true
        delete uriParams.search
        uriParams.query ?= {}
        uriParams.query.uuid = device.uuid
        uriParams.query.token = device.token
        uri = decodeURIComponent url.format(uriParams)
        response.status(201).location(uri).send(device: device, callbackUrl: uri)

module.exports = DeviceController

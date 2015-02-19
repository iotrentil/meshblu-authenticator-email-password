PinController = require './pin-controller'
debug = require('debug')('meshblu-pin-authenticator:device-controller')

class DeviceController
  constructor: (uuid, meshblu) ->
    @pinController = new PinController uuid, meshblu: meshblu

  create: (request, response) =>
    {device, pin} = request.body
    device ?= {}
    device.ipAddress ?= request.headers['x-forwarded-for'] ? request.connection.remoteAddress
    @pinController.createDevice pin, device, (error, uuid) =>
      return response.status(500).send error: error.message if error?
      response.status(201).send uuid: uuid

module.exports = DeviceController

_c  = chrome
_rt = _c.runtime
_ls = localStorage

_const =
  isExtensionOn : 'isExtensionOn'
  get           : 'get'
  put           : 'put'

init = ()->
  persist.isExtensionOn true if typeof query.isExtensionOn() is "undefined"

query = (name)->
  result = _ls[name]
  console.debug "query(#{name}) -> #{result}"
  result

persist = (name, value)->
  _ls[name] = value
  true

_rt.onMessage.addListener (r, sender, sendResponse)->
  method = r.method
  name = r.name
  value = r.value
  console.debug "#{method} / #{name} / #{value}"
  switch method
    when _const.get
      sendResponse query name
    when _const.put
      sendResponse persist name, value
    else
      throw "Unrecognized message method >#{method}<."
  if r.refreshContentScript
    console.debug "Refresh content Script"
    _rt.sendMessage (method:'refresh'), ()->
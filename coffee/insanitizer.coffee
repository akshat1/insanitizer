
#shorthands
_ls = localStorage
_kob = ko.observable
_c = chrome
_rt = _c.runtime

query = (name, cb)->
  _rt.sendMessage (
    method : 'get'
    name   : name
    refreshContentScript : true
    ), (res)->cb JSON.parse res

persist = (name, value, cb)->
  _rt.sendMessage (
    method : 'put'
    name   : name
    value  : value
    refreshContentScript : true
    ), (res)->cb JSON.parse res

#observables are suffixed with a 'B'
somethingToSaveB = _kob false
isExtensionOnB = _kob false
isProcessingB = _kob false

isExtensionOnB.subscribe (bool)->
  somethingToSaveB true

saveSettings = ()->
  persist 'isExtensionOn', isExtensionOnB(), ()->
    somethingToSaveB false
    isProcessingB false

getSettings = ()->
  query 'isExtensionOn', (isExtensionOn)->
    console.debug "isExtensionOn? #{isExtensionOn}"
    isExtensionOnB isExtensionOn
    isProcessingB false
    somethingToSaveB false

vm =
  isExtensionOnB : isExtensionOnB
  saveC          : saveSettings
  canSaveB       : somethingToSaveB
  isProcessingB  : isProcessingB

# Apply bindings once the popup is loaded
document.addEventListener 'DOMContentLoaded', ()->
  getSettings()
  window.top._vm = vm
  console.dir "Apply bindings!"
  ko.applyBindings vm
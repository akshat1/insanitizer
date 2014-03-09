#maximum tree depth to traverse
_MAX_DEPTH = 20

#shorthands
_c = chrome
_rt = _c.runtime
_ls = localStorage

query = (name, cb)->
  _rt.sendMessage (
    method : 'get'
    name   : name
    ), (res)->cb JSON.parse res

persist = (name, value, cb)->
  _rt.sendMessage (
    method : 'put'
    name   : name
    value  : value
    ), (res)->cb JSON.parse res

_NT =
  ELEMENT_NODE                : 1
  ATTRIBUTE_NODE              : 2
  TEXT_NODE                   : 3
  CDATA_SECTION_NODE          : 4
  ENTITY_REFERENCE_NODE       : 5
  ENTITY_NODE                 : 6
  PROCESSING_INSTRUCTION_NODE : 7
  COMMENT_NODE                : 8
  DOCUMENT_NODE               : 9
  DOCUMENT_TYPE_NODE          : 10
  DOCUMENT_FRAGMENT_NODE      : 11
  NOTATION_NODE               : 12

modifiedNodes  = []
replacementMap = null

execWhenFree = window.requestAnimationFrame || window.mozRequestAnimationFrame || window.webkitRequestAnimationFrame || window.setTimeout;

formRegexes = (inObject)->
  outObject = {}
  for substitute, expDetails of inObject
    outObject[substitute] = new RegExp expDetails[0], expDetails[1]
  outObject


restoreOriginal = ()->
  for elem in modifiedNodes
    elem.nodeValue = elem._originalText
  modifiedNodes = []

processElement = (elem, depth)->

  execFunc = ()->
    if (elem.nodeType is _NT.TEXT_NODE)
      originalText = nodeVal = elem.nodeValue
      return unless nodeVal.trim().length > 0
      for replacement, pattern of replacementMap
        nodeVal = nodeVal.replace pattern, replacement
      elem.nodeValue = nodeVal
      elem._originalText = originalText
      modifiedNodes.push elem
    else
      unless elem.tagName in ["SCRIPT", "LINK"]
        children = elem.childNodes
        for child in children
          processElement child, depth++

  execWhenFree execFunc, 1

getReplacementMap = (method, url, cb, eb=->)->
  xhr = new XMLHttpRequest()
  xhr.onload = (evt)->
    resp = evt.currentTarget?.response
    cb JSON.parse resp if resp
  xhr.onerror = eb
  xhr.open method, url, true
  xhr.send()

refresh = ()->
  query 'isExtensionOn', (isExtensionOn)->
    console.debug "isExtensionOn? #{isExtensionOn} | #{typeof isExtensionOn}"
    #console.debug "isExtensionOn? #{isExtensionOn}"
    if window?.document?.body
      if isExtensionOn
        console.debug "Get replacements"
        getReplacementMap 'GET', "http://akshatmedia.com/replacementMap.json", ((rMap)->
          console.debug "Got Replacements map!"
          rMap = formRegexes rMap
          console.dir "rMap"
          replacementMap = rMap
          window.top._repl = replacementMap
          modifiedNodes = []
          processElement window.document.body, 0),
          (err)->
            console.error err
      else
        restoreOriginal()

_rt.onMessage.addListener (r, sender, sendResponse)->
  console.debug "content-script received message : #{r.method}"
  switch r.method
    when 'refresh'
      refresh()
  sendResponse?()

refresh()

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
  ELEMENT_NODE : 1
  ATTRIBUTE_NODE : 2
  TEXT_NODE : 3
  CDATA_SECTION_NODE : 4
  ENTITY_REFERENCE_NODE : 5
  ENTITY_NODE : 6
  PROCESSING_INSTRUCTION_NODE : 7
  COMMENT_NODE : 8
  DOCUMENT_NODE : 9
  DOCUMENT_TYPE_NODE : 10
  DOCUMENT_FRAGMENT_NODE : 11
  NOTATION_NODE : 12

#TODO : Put this in a file? Let folks specify their own replacements
#We 'could' put this in background for now, but regexes don't stringify
#we would have to store them as strings and convert them to regexes once
#they are received.
replacementMap =
  "regatta"            : /^navy/gi
  "these dudes I know" : /^witness/ig
  "kinda probably"     : /^allegdely/ig
  "tumblr post"        : /^(new study)/ig
  "avenge"             : /^(rebuild|recover)/ig
  "spaaace"            : /^space/ig
  "virtual boy"        : /^(google glass)/ig
  "pokedex"            : /^smartphone/ig
  "atomic"             : /^electric/ig
  "elf-lord"           : /^(senator|lawmaker)/ig
  "cat"                : /^car/ig
  "eating contest"     : /^election/ig
  "river spirits"      : /^(congressional leaders)/ig
  "homestar runner"    : /^(homeland security)/ig
  "chieftain"          : /^(leader|chairman)/ig
  "tantrum"            : /^sanction/ig
  "stage whisper"      : /^statement/ig
  "coterie"            : /^committee/ig
  "magical"            : /^technical/ig
  "magic"              : /^(technology|science|tech)/ig
  "grand council"      : /^(administration|government)/ig
  "grand pooh-bah"     : /^(president|prime minister)/ig
  "fairy council"      : /^(senate|senatorial)/ig
  "noodling"           : /^consulting/ig
  "noodle"             : /^consult/ig
  "magic paper"        : /^visa/ig
  "inter-planetory "   : /^foreign /ig
  "incantation"        : /^(legislation|bill)/ig
  "moolah game"        : /^economy/ig
  "inspecting"         : /^eating/ig
  "binging on"         : /^drinking/ig
  "stroll"             : /^(incursion|invasion)/ig
  "hint at"            : /^recommend/ig
  "coitus"             : /^conjunction/ig
  "bros"               : /^allies/ig
  "bro"                : /^ally/g
  "IOU"                : /^(loan guarantee|guarantee|loan)/ig
  "groupies"           : /^members/ig
  "groupy"             : /^member/ig
  "soapbox"            : /^facebook/ig
  "is guilty and everyone knows it" : /^(could not be reached for comment)/ig

execWhenFree = window.requestAnimationFrame || window.mozRequestAnimationFrame || window.webkitRequestAnimationFrame || window.setTimeout;

modifiedNodes = []

restoreOriginal = ()->
  for elem in modifiedNodes
    elem.nodeValue = elem._originalText
  modifiedNodes = []

processElement = (elem, depth)->
  #if(depth > _MAX_DEPTH)
  #  return

  execFunc = ()->
    if (elem.nodeType is _NT.TEXT_NODE)
      originalText = nodeVal = elem.nodeValue
      return unless nodeVal.trim().length > 0
      for replacement, pattern of replacementMap
        nodeVal = nodeVal.replace pattern, replacement
      elem.nodeValue = nodeVal
      elem._originalText = originalText
      elem.title = originalText
      modifiedNodes.push elem
    else
      unless elem.tagName in ["SCRIPT", "LINK"]
        children = elem.childNodes
        for child in children
          processElement child, depth++

  execWhenFree execFunc, 1

refresh = ()->
  query 'isExtensionOn', (isExtensionOn)->
    console.debug "isExtensionOn? #{isExtensionOn} | #{typeof isExtensionOn}"
    #console.debug "isExtensionOn? #{isExtensionOn}"
    if window?.document?.body
      if isExtensionOn
        window.top._repl = replacementMap
        modifiedNodes = []
        processElement window.document.body, 0
      else
        restoreOriginal()

_rt.onMessage.addListener (r, sender, sendResponse)->
  console.debug "content-script received message : #{r.method}"
  switch r.method
    when 'refresh'
      refresh()
  sendResponse?()

refresh()

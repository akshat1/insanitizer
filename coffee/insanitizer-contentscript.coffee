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
  "regatta"            : /\bnavy/gi
  "these dudes I know" : /\bwitness/ig
  "kinda probably"     : /\ballegdely/ig
  "tumblr post"        : /\b(new study)/ig
  "avenge"             : /\b(rebuild|recover)/ig
  "spaaace"            : /\bspace/ig
  "virtual boy"        : /\b(google glass)/ig
  "pokedex"            : /\bsmartphone/ig
  "atomic"             : /\belectric/ig
  "elf-lord"           : /\bsenator|lawmaker/ig
  "cat"                : /\bcar/ig
  "eating contest"     : /\belection/ig
  "river spirits"      : /\b(congressional leaders)/ig
  "homestar runner"    : /\b(homeland security)/ig
  "chieftain"          : /\b(leader|chairman)/ig
  "tantrum"            : /\bsanction/ig
  "stage whisper"      : /\bstatement/ig
  "coterie"            : /committee/ig
  "magical"            : /\btechnical/ig
  "magic"              : /\b(technology|science|tech)/ig
  "grand council"      : /\b(administration|government)/ig
  "grand pooh-bah"     : /\b(president|prime minister)/ig
  "fairy council"      : /\b(senate|senatorial)/ig
  "noodling"           : /\bconsulting/ig
  "noodle"             : /\bconsult/ig
  "magic paper"        : /\bvisa/ig
  "inter-planetory "   : /\bforeign\b/ig
  "incantation"        : /\blegislation/ig
  "moolah game"        : /\beconomy/ig
  "inspecting"         : /\beating/ig
  "binging on"         : /\bdrinking/ig
  "stroll"             : /\b(incursion|invasion)/ig
  "hint at"            : /\brecommend/ig
  "coitus"             : /\bconjunction/ig
  "bros"               : /\ballies/ig
  "bro"                : /\bally/ig
  "IOU"                : /\b(loan guarantee|guarantee|loan)/ig
  "groupies"           : /\bmembers/ig
  "groupy"             : /\bmember/ig
  "soapbox"            : /\bfacebook/ig
  "town"                            : /\b(country|territorry|nation)/ig
  "gambler"                         : /\binvestor\b/ig
  "gamble"                          : /\binvest\b/ig
  "tattler"                         : /\breporter\b/ig
  "is guilty and everyone knows it" : /\b(could not be reached for comment)/ig
  "fingering"                       : /\bcorruption\b/ig
  "natural gas"                     : /\bearth's flatulance/ig
  "aroused"                         : /\bdisappointed\b/ig

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

#maximum tree depth to traverse
_MAX_DEPTH = 20

isExtensionOn = true

#TODO : Put this in a file? Let folks specify their own replacements

replacementMap =
  "these dudes I know"              : /witness/ig
  "kinda probably"                  : /allegdely/ig
  "tumblr post"                     : /new study/ig
  "avenge"                          : /rebuild|recover/ig
  "spaaace"                         : /space/ig
  "virtual boy"                     : /google glass/ig
  "pokedex"                         : /smartphone/ig
  "atomic"                          : /electric/ig
  "elf-lord"                        : /senator|lawmaker/ig
  "cat"                             : /car/ig
  "eating contest"                  : /election/ig
  "river spirits"                   : /congressional leaders/ig
  "homestar runner"                 : /homeland security/ig
  "is guilty and everyone knows it" : /could not be reached for comment/ig
  "chieftain"                       : /leader|chairman/ig
  "tantrum"                         : /sanction/ig
  "stage whisper"                   : /statement/ig
  "coterie"                         : /committee/ig
  "magical"                         : /technical/ig
  "magic"                           : /technology|science|tech/ig
  "grand council"                   : /administration|government/ig
  "grand pooh-bah"                  : /president|prime minister/ig
  "fairy council"                   : /senate|senatorial/ig
  "noodling"                        : /consulting/ig
  "noodle"                          : /consult/ig
  "magic paper"                     : /visa/ig
  "inter-planetory "                : /foreign /ig
  "incantation"                     : /legislation|bill/ig
  "moolah game"                     : /economy/ig
  "inspecting"                      : /eating/ig
  "binging on"                      : /drinking/ig
  "stroll"                          : /incursion|invasion/ig
  "hint at"                         : /recommend/ig
  "coitus"                          : /conjunction/ig
  "bros"                            : /allies/ig
  "bro"                             : /ally/g
  "IOU"                             : /loan guarantee|guarantee|loan/ig
  "groupies"                        : /members/ig
  "groupy"                          : /member/ig

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

execWhenFree = window.requestAnimationFrame || window.mozRequestAnimationFrame || window.webkitRequestAnimationFrame || window.setTimeout;

processElement = (elem, depth)->
  if(depth > _MAX_DEPTH)
    return

  execWhenFree (()->
    if (elem.nodeType is _NT.TEXT_NODE)
      nodeVal = elem.nodeValue
      for replacement of replacementMap
        #pattern is replacementMap[replacement]
        nodeVal = nodeVal.replace replacementMap[replacement], replacement
      elem.nodeValue = nodeVal
    else
      children = elem.childNodes
      for child in children
        processElement child, depth++
    ), 1

#Never written a chrome extension and don't want it crapping out on people.
console.log "Here we go"
if isExtensionOn and window?.document?.documentElement
  console.log "Start processing!"
  processElement window.document.documentElement

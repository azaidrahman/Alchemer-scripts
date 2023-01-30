function getLang () {
  return document.getElementsByTagName('html')[0].lang
}

const setCheckedByQid = (qid, _checkOptionIds) => {
     
  // convert param to an array if it was a single value
  let checkOptionIds = Array.isArray(_checkOptionIds) ? _checkOptionIds : [_checkOptionIds]
  
  // ensure array is all integers
  checkOptionIds = checkOptionIds.map(id => parseInt(id))
  
  // go through all options and check or uncheck them
  getElemByQid(qid, "box").querySelectorAll('.sg-question-options input')
    .forEach(inputElem => 
      inputElem.checked = checkOptionIds.includes(parseInt(inputElem.value)))
}

/***
   * Test boolean value, alert() and throw Error if it's false
   *
   * bool (t/f) value to test 
   * msg (string) message to alert and throw in new Error
   */
const assert = (bool, msg) => {
  msg = "Javascript Assert Error: " + msg 
  if (!bool) {
    alert(msg)
    console.error(msg)
    const err = new Error(msg)
    console.error(err)
    throw err
    }
}

/***
 * Get an element based on its Question ID 
 *
 * qid {int/string} question ID 
 * section = "element" {string} the final section of the element id
 * return {element} looks for id's in the form: "sgE-1234567-12-123-element"
 */
const getElemByQid = (qid, section = "element") => {
  const id = "sgE-" + SGAPI.survey.surveyObject.id + "-" + SGAPI.survey.pageId + "-" + qid + "-" + section
  const elem = document.getElementById(id)
  assert(elem, "Javascript: can't find element with id = " + id)
  return elem
}

var t = 115
$SG(function(){
	let language = getLang()
  if(language.includes('en')){
    setCheckedByQid(t,10331)
  }else if(language.includes('zh')){
    setCheckedByQid(t,10333)
  }
});
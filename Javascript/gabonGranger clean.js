var BASE = "sgE-7174016";
var PAGE = "-60-";
var PROD

var journey = document.getElementById(BASE+PAGE+ 143 +"-element")
var finalPrice = document.getElementById(BASE+PAGE+ 144 +"-element")
var journeyText = ""

var questions = [
    [158,142,150,152,153,154,155]
]

var yesno = [
    [10389,10375,10377,10381,10383,10385,10387]
]

var PRICES = [
    ["14.10","28.20","42.30","56.40","70.50","84.60","98.70","112.80","126.90","141.00"]
]

var curr
var timesAnswered = 0

function getRandomIntInclusive(min, max) {
    min = Math.ceil(min);
    max = Math.floor(max);
    return Math.floor(Math.random() * (max - min + 1) + min); // The maximum is inclusive and the minimum is inclusive
  }
  

function init(version,prodType,n){
    // curr = getRandomIntInclusive(4,6)
    curr = 6;
    let currentQuesText = document.getElementById(version+n)
    let price = PRICES[prodType]
    currentQuesText.innerHTML = "RM " + price[curr-1];
    journeyText += "RM "+ price[curr-1] + ", "
    timesAnswered += 1
}
  
function setPrice(version,prodType,n,isYes){
    let nextQuesText = document.getElementById(version+(n+1))
    let price = PRICES[prodType]    
    curr = isYes ? curr + 1 : curr - 1
    timesAnswered += 1
    journeyText += price[curr-1] ?  "RM "+ price[curr-1] + ", " : ""
    if (n != 0)
    {
        let prevQuesYes = document.getElementById(BASE+PAGE+questions[prodType][n-1] + "-" + yesno[prodType][n-1])
        let prevQuesNo = document.getElementById(BASE+PAGE+questions[prodType][n-1] + "-" + (yesno[prodType][n-1]+1))

        if ( ((curr > 10) || (isYes && prevQuesNo.checked) || ((curr < 1) || !isYes && prevQuesYes.checked) ) || timesAnswered >= 7){
            // console.log("No:"+prevQuesNo.checked + "Yes:"+prevQuesYes.checked + "\nnext: " + curr + "")
            journey.value = journeyText.slice(0,-2)
            finalPrice.value = (curr > 0 || curr >10) ? price[curr-1].toString() : price[curr].toString()
            console.log(finalPrice)
            console.log(journey)
            
            
            selector = document.querySelector("#sg_NextButton") || document.querySelector("#sg_SubmitButton")
            selector.click();
        }
    }

    nextQuesText.innerHTML = "RM "+ price[curr-1];
}

$SG(function(){
    init("Pro_M2M",0,0)
    for (let i = 0; i < questions[0].length; i++){
        let yes = document.getElementById(BASE + PAGE + questions[0][i] + "-" + yesno[0][i])
        let no = document.getElementById(BASE + PAGE + questions[0][i] + "-" + (yesno[0][i]+1))
        yes.addEventListener("click", () => {setPrice("Pro_M2M",0,i,true);},false);
        no.addEventListener("click", () => {setPrice("Pro_M2M",0,i,false);},false);
    }

} );

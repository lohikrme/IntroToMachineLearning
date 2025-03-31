
/*
console.log("Hello world")

const animals = {
    "Monkey": "Banana", 
    "Pig": "Tryffel",
    "Rhino": "Grass"
}

for (let [key, value] of animals) {
	console.log(`key: {key}, value: {value}`)
}
*/

const dic1 = {"Monkey": "Banana", "Pork": "Tryffel", "Rhino": "Grass"}
const keysFromDic1 = Object.keys(dic1);
const dic2 = {};
keysFromDic1.forEach((key) => {
    dic2[dic1[key]] = key;
});
console.log({keysFromDic1, dic2})
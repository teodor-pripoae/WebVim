window.WebVim = {}
console.log("mata")
merge = (obj1, obj2)->
  obj3 = {}
  for key, value of obj1
    obj3[key] = value

  for key, value of obj2
    obj3[key] = value

  return obj3




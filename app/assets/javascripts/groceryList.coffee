document.addEventListener "turbolinks:load", ->
  if document.getElementById("grocery-list")
    new Vue
      el: "#grocery-list"
      data:
        ingredients: window.groceryList.ingredients || []

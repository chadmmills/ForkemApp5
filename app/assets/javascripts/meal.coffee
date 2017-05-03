document.addEventListener "turbolinks:load", ->
  if document.getElementById("mealForm")
    _newMealForm = new Vue(
      el: "#mealForm"
      data:
        activeTab: 'write'
        showParseableTextField: false
        generatedHTML: ""
        meal: window._currentMeal
        parseableIngredientText: ""
        showParsedSuccessMsg: false
      computed:
        visibleIngredients: ->
          @meal.ingredients.filter (i) -> not i._delete
      methods:
        addIngredient: () ->
          @meal.ingredients.push(
            {id: Date.now(), name: null, measurement_unit: null, _delete: false}
          )
        clearParsedIngredients: () ->
          @showParsedSuccessMsg = false
          @parseableIngredientText = ""
          @showParseableTextField = false
        parseText: () ->
          Axios.post("/parsed-ingredients", { text: @parseableIngredientText })
            .then (resp) =>
              @meal.ingredients = @meal.ingredients.concat(resp.data.ingredients)
              @showParsedSuccessMsg = true
              setTimeout @clearParsedIngredients, 500
        removeIngredient: (ingredient) ->
          ingredient._delete = true
        previewDescription: () ->
          @activeTab = 'preview'
          Axios.post("/utilities/markdown", { text: @meal.desc})
            .then (resp) => @generatedHTML = resp.data.html
        saveMeal: () ->
          console.log @meal
          console.log JSON.parse(JSON.stringify(@meal))
          Axios(
            method: @meal.httpMethod,
            url: @meal.url,
            data: { meal: JSON.parse(JSON.stringify(@meal))}
          )
            .then (resp) => Turbolinks.visit(@meal.success_url)
    )

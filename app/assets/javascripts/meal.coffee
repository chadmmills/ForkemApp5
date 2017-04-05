document.addEventListener "turbolinks:load", ->
  if document.getElementById("mealForm")
    _newMealForm = new Vue(
      el: "#mealForm"
      data:
        activeTab: 'write'
        generatedHTML: ""
        meal: window._currentMeal
      computed:
        visibleIngredients: ->
          @meal.ingredients.filter (i) -> not i._delete
      methods:
        removeIngredient: (ingredient) ->
          ingredient._delete = true
        addIngredient: () ->
          @meal.ingredients.push(
            {id: Date.now(), name: null, measurement_unit: null, _delete: false}
          )
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
            .then (resp) -> Turbolinks.visit("/")


    )

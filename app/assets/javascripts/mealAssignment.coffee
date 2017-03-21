
Vue.component 'weekday-meal',
  props: ["weekday", "mealAssigned", "removeAssignment"]
  template: """
    <div
      v-on:dragover="draggingOver"
      v-on:dragenter="draggingEnter"
      v-on:dragleave="draggingLeaving"
      v-on:drop="onDrop"
      class="weekday-content">
      <div v-bind:class="{ 'weekday-content-dragging-over': isDraggingOver }" >

        <h4 class="center mt1 mb0">{{ weekday.table.title }}</h4>
        <h6 class="center mt0 mb2">{{ weekday.table.date }}</h6>
        <div class="weekday-droppable-area">
         <span v-show="isLoading">Loading...</span>
        </div>
        <div v-if="meal" class="weekday-meal p1 relative">
          <span class="top-right box2 flex-center cursor" @click="removeAssignment(meal)">&times</span>
          <h3 class="center m0">{{ meal.name }}</h3>
          <h6>Notes</h6>
          <h6>Ingredients</h6>
        </div>
      </div>
    </div>
  """
  data: ->
    isDraggingOver: false
    isLoading: false
  computed:
    meal: -> @weekday.table.meal
  methods:
    draggingOver: (evt) ->
      evt.preventDefault()
    draggingEnter: (evt) ->
      evt.preventDefault()
      @isDraggingOver = true
    draggingLeaving: (evt) ->
      @isDraggingOver = false
    onDrop: (evt) ->
      evt.preventDefault()
      @isLoading = true
      Axios.post "/meal-assignments", {
        weekdate: @weekday.table.date
        meal_id: evt.dataTransfer.getData("text")
      }
      .then (resp) =>
        @isDraggingOver = false
        @isLoading = false
        #console.info(resp)
        @mealAssigned(resp.data.mealbook)

Vue.component 'weekday-meals',
  props: ["weekdays", "mealAssigned", "removeAssignment"]

  template: """
    <div class="weekday-meals px1 pb2 flex flex-1">
      <div v-for="(weekday, index) in weekdays" class="weekday px1">
        <weekday-meal :removeAssignment="removeAssignment" :mealAssigned="mealAssigned" :weekday="weekday"></weekday-meal>
      </div>
    </div>
  """

Vue.component 'meal-list-meal',
  props:
    meal: Object
  template: """
    <div draggable="true" v-on:dragstart="draggingStarted" class="meal-list-meal relative">
      <a v-bind:href="mealUrl" class="top-right box2 flex-center justify-around cursor">
        <div class="dot bg-grey circle"></div>
        <div class="dot bg-grey circle"></div>
        <div class="dot bg-grey circle"></div>
      </a>
      {{ meal.name }}
    </div>
  """
  data: ->
    draggingHasStarted: false
  computed:
    mealUrl: ->
      "/meals/#{@meal.id}"
  methods:
    draggingStarted: (evt) ->
      @draggingHasStarted = true
      evt.dataTransfer.setData("text", @meal.id)

document.addEventListener "turbolinks:load", ->
  if document.getElementById("mealbook")
    _mealbookPlanner = new Vue(
      el: '#mealbook'
      template: """
        <main class="main flex flex-auto">
          <div class='flex flex-column flex-auto'>
            <section class="flex-center ht4" data-turbolinks='false'>
              <a @click="renderPrevWeek" href="#prev">Previous</a>
              <h2 class='m0 px1'>{{ mealbook.current_date_short }}</h2>
              <a @click="renderNextWeek" href="#next">Next</a>
            </section>
            <section class='main-weekdays flex flex-auto items-strech'>
              <weekday-meals :weekdays="weekdays" :removeAssignment="destroyAssignment" :mealAssigned="updateWeek"></weekday-meals>
            </section>
          </div>
          <section class='main-meals' v-bind:class="{ 'main-meals__hidden': !showMealDrawer }">
            <div @click="showMealDrawer = !showMealDrawer" class="main-meals__toggle">&times</div>
            <div class='meal-list' id='mealbookMeals'>
              <h4 class="mt0 mb1">Meals</h4>
              <meal-list-meal v-bind:meal='meal' v-for='(meal, index) in meals'></meal-list-meal>
            </div>
          </section>
        </main>
      """
      data:
        mealbook: window._currentMealbook
        showMealDrawer: true
      computed:
        weekdays: () ->
          @mealbook.weekdays
        meals: ->
          @mealbook.meals
      methods:
        updateWeek: (newMealbook) ->
          @mealbook = newMealbook
        renderPrevWeek: () ->
          @renderWeek(@mealbook.prev_week)
        renderNextWeek: () ->
          @renderWeek(@mealbook.next_week)
        destroyAssignment: ({ assignment_id }) ->
          Axios.delete "meal-assignments/#{assignment_id}"
            .then (response) => @mealbook = response.data.mealbook
        renderWeek: (dateParam) ->
          Axios.get "/mealbooks/#{@mealbook.id}", params: { weekdate: dateParam }
            .then (response) =>
              @mealbook = response.data.mealbook
    )

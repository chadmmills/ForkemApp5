iosDragDropShim = { enableEnterLeave: true }

Vue.component 'weekday-meal',
  props: ["weekday", "mealAssigned", "removeAssignment"]
  template: """
    <div
      v-on:dragover="draggingOver"
      v-on:dragenter="draggingEnter"
      v-on:dragleave="draggingLeaving"
      v-on:drop="onDrop"
      class="weekday-content rounded flex-auto">
      <div v-bind:class="{ 'weekday-content-dragging-over': isDraggingOver }" >
        <div v-if="isToday" class="top-right box2 p1 c-green">
          <svg fill="currentColor" viewBox="0 0 20 20"><polygon points="10 15 4.122 18.09 5.245 11.545 .489 6.91 7.061 5.955 10 0 12.939 5.955 19.511 6.91 14.755 11.545 15.878 18.09"/></svg>
        </div>

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
    isToday: ->
      todaysDate = new Date()
      mealDate = new Date(@weekday.table.date)
      "#{todaysDate.getUTCDate()} - #{todaysDate.getUTCMonth()}" is
        "#{mealDate.getUTCDate()} - #{mealDate.getUTCMonth()}"
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
      <div v-for="(weekday, index) in weekdays" class="weekday px1 flex">
        <weekday-meal :removeAssignment="removeAssignment" :mealAssigned="mealAssigned" :weekday="weekday"></weekday-meal>
      </div>
    </div>
  """

Vue.component 'meal-list-meal',
  props:
    meal: Object
  template: """
    <div
      draggable="true"
      v-on:dragstart="draggingStarted"
      class="meal-list-meal relative">

      <span class="flex-1">{{ meal.name }}</span>
      <a v-bind:href="mealUrl" class="box2 c-gray">
        <svg fill="currentColor" viewBox="0 0 20 20"><path d="M10 12a2 2 0 1 1 0-4 2 2 0 0 1 0 4zm0-6a2 2 0 1 1 0-4 2 2 0 0 1 0 4zm0 12a2 2 0 1 1 0-4 2 2 0 0 1 0 4z"/></svg>
      </a>
    </div>
  """
  data: ->
    draggingHasStarted: false
  computed:
    mealUrl: ->
      "/meals/#{@meal.id}"
  methods:
    touchStarted: (event) ->
      event.preventDefault()
      @startX = event.targetTouches[0].pageX
      @startY = event.targetTouches[0].pageY
      console.log @startX, @startY
    touchMoving: (event) ->
      event.preventDefault()
      curX = event.targetTouches[0].pageX - @startX
      curY = event.targetTouches[0].pageY - @startY
      event.targetTouches[0].target.style.webkitTransform = 'translate(' + curX + 'px, ' + curY + 'px)';
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
              <a @click.prevent="renderPrevWeek" href="#prev" style="width: 20px; height: 20px;">
                <svg fill="currentColor" viewBox="0 0 20 20"><path d="M10 20a10 10 0 1 1 0-20 10 10 0 0 1 0 20zm8-10a8 8 0 1 0-16 0 8 8 0 0 0 16 0zM7.46 9.3L11 5.75l1.41 1.41L9.6 10l2.82 2.83L11 14.24 6.76 10l.7-.7z"/></svg>
              </a>
              <h2 class='m0 px1'>{{ mealbook.current_date_short }}</h2>
              <a @click.prevent="renderNextWeek" href="#next" style="width: 20px; height: 20px;">
                <svg fill="currentColor" viewBox="0 0 20 20"><path d="M10 0a10 10 0 1 1 0 20 10 10 0 0 1 0-20zM2 10a8 8 0 1 0 16 0 8 8 0 0 0-16 0zm10.54.7L9 14.25l-1.41-1.41L10.4 10 7.6 7.17 9 5.76 13.24 10l-.7.7z"/></svg>
              </a>
            </section>
            <section class='main-weekdays flex flex-auto items-strech'>
              <weekday-meals :weekdays="weekdays" :removeAssignment="destroyAssignment" :mealAssigned="updateWeek"></weekday-meals>
            </section>
          </div>
          <section class='main-meals' v-bind:class="{ 'main-meals__hidden': !showMealDrawer }">
            <div @click="showMealDrawer = !showMealDrawer" class="main-meals__toggle">&times</div>
            <div class='meal-list' id='mealbookMeals'>
              <h4 class="mt0 mb1">Meals</h4>
              <meal-list-meal v-bind:meal='meal' :key="meal.id" v-for='(meal, index) in meals'></meal-list-meal>
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
          Axios.delete "/meal-assignments/#{assignment_id}"
            .then (response) => @mealbook = response.data.mealbook
        renderWeek: (dateParam) ->
          Axios.get "/mealbooks/#{@mealbook.id}", params: { weekdate: dateParam }
            .then (response) =>
              @mealbook = response.data.mealbook
    )

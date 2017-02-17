
Vue.component 'weekday-meal',
  props:
    weekday: Object
  template: """
    <div class="weekday px2">
      <div
        ondragover="event.preventDefault()"
        v-on:dragenter="draggingEnter"
        v-on:dragleave="draggingLeaving"
        v-on:drop="onDrop"
        v-bind:class="{ 'weekday-content-dragging-over': isDraggingOver }"
        class="weekday-content"
      >
         <h4 class="center">{{ day }}</h4>
         <h6 class="center">{{ date }}</h6>
         <div class="weekday-droppable-area">
          <span v-show="isLoading">Loading...</div>
         </div>
      </div>
    </div>
  """
  data: ->
    isDraggingOver: false
    isLoading: false
    weekdayData: @weekday.table
  computed:
    day: ->
      @weekday.table.title
    date: ->
      @weekday.table.date
  methods:
    draggingEnter: (evt) ->
      @isDraggingOver = true
    draggingLeaving: (evt) ->
      @isDraggingOver = false
    onDrop: (evt) ->
      console.log(evt)
      evt.preventDefault()
      @isLoading = true



Vue.component 'meal-list-meal',
  template: """
    <div draggable="true" v-on:dragstart="draggingStarted = true" class="meal-list-meal">
      Meal Title
    </div>
  """
  data: ->
    draggingStarted: false

document.addEventListener "turbolinks:load", ->
  new Vue(
    el: '#mealbook'
    data: {
      mealbook: currentMealbook
    }
    computed:
      weekdays: () ->
        @mealbook.weekdays
    methods:
      renderPrevWeek: () ->
        @renderWeek(@mealbook.prev_week)
      renderNextWeek: () ->
        @renderWeek(@mealbook.next_week)
      renderWeek: (dateParam) ->
        Axios.get "/", params: { weekdate: dateParam }
          .then (response) =>
            @mealbook = response.data.mealbook
  )

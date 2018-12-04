
import Elm from './GroceryList'

(function(){
  const csrfToken = document.querySelectorAll('meta[name="csrf-token"]')[0].
    getAttribute("content")
  const listId = window.__listId
  const plannerId = window.__plannerId
  const initStartDate = window.__initStartDate
  const initEndDate = window.__initEndDate
  const target = document.getElementById('grocery-list')
  Elm.GroceryList.embed(target,
    {
      csrfToken,
      initEndDate,
      initStartDate,
      listId,
      plannerId
    }
  )
})()

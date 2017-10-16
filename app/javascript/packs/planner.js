// Run this example by adding <%= javascript_pack_tag "hello_elm" %> to the head of your layout
// file, like app/views/layouts/application.html.erb. It will render "Hello Elm!" within the page.

import Elm from './Planner'

document.addEventListener('turbolinks:load', () => {
  const csrfToken = document.querySelectorAll('meta[name="csrf-token"]')[0].
    getAttribute("content")

  const currentWeekDate = window.__currentWeekDate
  const mealbookId = window.__mealbookId
  const prevWeekDate = window.__prevWeekDate

  console.log(csrfToken)
  const target = document.createElement('div')

  document.body.appendChild(target)
  Elm.Planner.embed(target, {
    csrfToken,
    currentWeekDate,
    mealbookId,
    prevWeekDate,
  })
})

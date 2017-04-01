// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require turbolinks
//= require touch_dnd_shim
//= require axios
//= require vue
//= require meal
//= require mealAssignment

// NO //= require jquery //= require jquery_ujs
function getCSRFToken() {
  return document.querySelector("meta[name='csrf-token']").content
}

function parseMarkdown(markdownText) {
  const config = {
    headers: {
      "Accept": "application/vnd.github.v3+json",
    }
  }
  markdownParser = axios.create(config)
  return markdownParser.post("https://api.github.com/markdown", {
    text: markdownText
  })
}

document.addEventListener("turbolinks:load", function() {
  const config = {
    headers: {
      'X-CSRF-Token': getCSRFToken(),
      "Accept": "application/json",
      'X-Requested-With': 'XMLHttpRequest',
    }
  }
  window.Axios = window.Axios || axios.create(config)
});

document.addEventListener("turbolinks:before-render", function() {
  window._currentMealbook = null;
  window._currentMeal = null;
});

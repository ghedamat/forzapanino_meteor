Handlebars.registerHelper 'p_ingredients', (panino) ->
  res = (ing.name for ing in panino.ingredients)
  res = '<span class="label label-success">' + res.join('</span> <span class="label label-success">') + '</span>'
  new Handlebars.SafeString res

validate_user = ->
    if Meteor.user() is null
      $('#alert').html Template.alert({alertText: "you have to be logged in first"})
      return false
    true

class Routers.Main extends Backbone.Router

  routes:
    'paninos/:id': 'panino'
    'users' : 'users'
    'users/:id': 'user'
    'shops' : 'shops'
    'shops/:id': 'shop'
    '' : 'paninos'

  initialize: ->
    Backbone.history.start(pushstate: true)

  paninos: ->
    Session.set('page','home')
    Session.set('shop_id',null)

  users: ->
    Session.set('page','users')
    Session.set('shop_id',null)

  user: (id) ->
    Session.set('page','user')
    Session.set('user_id',id)

  shops: ->
    Session.set('page','shops')
    Session.set('shop_id',null)

  shop: (id) ->
    Session.set('page','shop')
    Session.set('shop_id',id)

  panino: (id)->
    Session.set('page','home')
    Session.set('shop_id',id)



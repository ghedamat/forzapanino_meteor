Routers = {}
Meteor.startup ->
  new Routers.Main()
  #Backbone.history.start(pushstate: true)



Paninos = new Meteor.Collection("paninos")
Ingredients = new Meteor.Collection("ingredients")
Shops = new Meteor.Collection("shops")

Handlebars.registerHelper 'render', (name) ->
  if Template[name]
    Template[name]()

#main
Session.set('page','home')
if _.last(window.location.href.split('/')).length isnt 0
  switch window.location.href.split('/')[3]
    when '#users'
      Session.set 'user_id', _.last(window.location.href.split('/'))
    when '#shops'
      Session.set 'shop_id', _.last(window.location.href.split('/'))
Template.main.page = () ->
    Session.get("page")


# home view
next = (new Date()).getTime() - (8*60*60*1000)

Template.paninos_list_with_shop.todays = Paninos.find({ "created_at": { $gt: next}},{sort: { "shop":1 , "name": 1 }})
Template.home.shops = Shops.find()
Template.today_resume.shops = Shops.find()

Template.home.shop = ->
  Session.get('shop_id')
Template.ingredients.ingredients = ->
  Ingredients.find({"shop._id" : Session.get('shop_id') }, {sort: { "shop":1 , "name": 1 } })
Template.shop_paninos.shop = ->
  Shops.findOne("_id" : Session.get('shop_id'))

#users view
Template.user.user = -> 
  Meteor.users.findOne(_id: Session.get('user_id'))
Template.users.users = Meteor.users.find()

#user
Template.paninos_list.todays = ->
  if Session.get('shop_id')
    Paninos.find({ "shop._id": Session.get('shop_id') , "created_at": { $gt: next}})
  else
    Paninos.find({ "user._id": Session.get('user_id')})


#shops
Template.shops.shops = Shops.find()

#shop
Template.shop.shop = =>
  Shops.findOne(_id: Session.get('shop_id'))
Template.shop.ingredients = =>
  Ingredients.find({"shop._id" : Session.get('shop_id') }, {sort: { "shop":1 , "name": 1 } })








Template.shops.events =
  'submit #new_shop': (events) ->
    events.preventDefault()
    if validate_user()
      name = $('#shop_name').val().trim()
      phone = $('#shop_phone').val().trim()
      shop = Shops.find({name: name})
      if name.length is 0
        $('#alert').html('type something!');
        $('#alert').show();
      else if shop.count() is 0
        $('#alert').hide();
        $('#alert').html('');
        Shops.insert({name: name, phone: phone})
      else
        $('#alert').html('shop already present');
        $('#alert').show();
    else
      $('#alert').html Template.alert({alertText: "you have to be logged in"})
  'click .destroy': ->
    if Meteor.user()
      conf = confirm("This will remove a shop and all his ingredients!")
      if conf
        Shops.remove(this)

    else
      $('#alert').html Template.alert({alertText: "you have to be logged in"})

Template.shop.events = 
  'submit #new_ingredient': (events) ->
    events.preventDefault()
    if validate_user()
      name = $('#new_ingredient_name').val().trim()
      shop = Shops.find(_id: Session.get('shop_id')).fetch()[0]

      ing = Ingredients.find({name: name, "shop._id": shop._id})
      if name.length is 0
        $('#alert').html('type something!');
        $('#alert').show();
      else if ing.count() is 0
        $('#alert').hide();
        $('#alert').html('');
        $('#new_ingredient_name').val('')
        #Meteor.call 'get_ingredient_image', name, (e,r) ->
        #  Ingredients.insert({name: name, image: r.url, shop: shop})
        Ingredients.insert({name: name, shop: shop})
      else
        $('#alert').html('ingredient already present');
        $('#alert').show();
    else
      $('#alert').html Template.alert({alertText: "you have to be logged in"})
  'click .destroy': ->
    if Meteor.user()
      Ingredients.remove(this)
    else
      $('#alert').html Template.alert({alertText: "you have to be logged in"})








Template.login.events =
  'click #login': (event) ->
    event.preventDefault()
    Meteor.loginWithGoogle()
  'click #logout': (event) ->
    event.preventDefault()
    Meteor.logout()




Template.panino.events =
  'click .order': ->
    if validate_user()
      Paninos.insert(shop: this.shop, user: Meteor.user(), ingredients: this.ingredients, created_at: (new Date()).getTime())
  'click .destroy': ->
    if Meteor.user() and (@user._id is Meteor.user()._id)
      Paninos.remove(this)
    else
      $('#alert').html Template.alert({alertText: "you can destroy just your paninos"})




Template.ingredients.events =
  'submit #new_panino': (events) ->
    shop = Shops.find(_id: Session.get('shop_id')).fetch()[0]
    events.preventDefault()
    res = ($(item).val() for item in $('input[type=checkbox]:checked'))
    ing = Ingredients.find({_id: {$in: res}}).fetch()
    if validate_user()
      if ing.length is 0
        $('#alert').html Template.alert({alertText: "you have to choose at least one ingredient"})
      else
        Paninos.insert (shop: shop, user: Meteor.user(), ingredients: ing, created_at: (new Date()).getTime())
        $('input[type=checkbox]:checked').attr('checked',false)



    


  

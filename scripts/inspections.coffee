class Inspections extends Backbone.Collection
  initialize: (google, ui) ->
    @ui = ui
    @google = google
    @resourceURL = "https://data.cityofchicago.org/resource/4ijn-s7e5.json"

  url: ->
    @urlByName()

  urlByName: ->
    unless _.isNull(@ui.restaurantName)
      return "#{@resourceURL}?dba_name=#{@ui.restaurantName}"
    @resourceURL

  restaurantsViolations: ->
    this.filter((restaurant) -> restaurant.get("violations"))

  restaurantHasViolationsByAddress: (restaurantAddress) ->
    @restaurantsViolations().filter((restaurant) -> restaurant.get("address") == restaurantAddress)

  addressOfRestaurantsViolations: ->
    address = []
    @restaurantsViolations().forEach((restaurant) -> address.push(restaurant.get("address")))
    _.uniq(address);

  restaurantsViolationsOnGoogleMap: ->
    googleMap = new GoogleMap(@google)
    _.each(@addressOfRestaurantsViolations(), (restaurantAddress) =>
      restaurant = @restaurantHasViolationsByAddress(restaurantAddress)
      mark = googleMap.markLocation restaurant[0].get("latitude"), restaurant[0].get("longitude")
      googleMap.openInfoWindow mark, restaurant[0].toJSON(), restaurant.length)

window.Inspections = Inspections

class Inspections extends Backbone.Collection
  initialize: (options) ->
    @ui = options.ui
    @google = options.google
    @resourceURL = "https://data.cityofchicago.org/resource/4ijn-s7e5.json?$where=violations IS NOT NULL"

  url: ->
    @urlByName()

  urlByName: ->
    unless _.isNull(@ui.restaurantName)
      return "#{@resourceURL}&dba_name=#{encodeURIComponent @ui.restaurantName}"
    @resourceURL

  restaurantsFilterBy2014Year: ->
    this.filter((restaurant) -> restaurant.get("inspection_date").match(/2014-*/g))

  restaurantHasViolationsByLicenseID: (restaurantLicenseID) ->
    @restaurantsFilterBy2014Year().filter((restaurant) -> restaurant.get("license_") == restaurantLicenseID)

  licenseIDsOfRestaurantsViolations: ->
    licenseIDs = []
    @restaurantsFilterBy2014Year().forEach((restaurant) -> licenseIDs.push(restaurant.get("license_")))
    _.uniq(licenseIDs);

  restaurantsViolationsOnGoogleMap: ->
    googleMap = new GoogleMap(@google)
    _.each(@licenseIDsOfRestaurantsViolations(), (restaurantLicenseID) =>
      restaurant = @restaurantHasViolationsByLicenseID(restaurantLicenseID)
      mark = googleMap.markLocation restaurant[0].get("latitude"), restaurant[0].get("longitude")
      googleMap.openInfoWindow mark, restaurant[0].toJSON(), restaurant.length)

window.Inspections = Inspections

class Inspections extends Backbone.Collection
  initialize: (options) ->
    @ui = options.ui
    @google = options.google
    @resourceURL = "https://data.cityofchicago.org/resource/4ijn-s7e5.json?$where=violations IS NOT NULL"

  url: ->
    @urlByName()

  urlByName: ->
    if !_.isNull(@ui.restaurantName)
      return "#{@resourceURL}&dba_name=#{encodeURIComponent @ui.restaurantName}"
    else if !_.isNull(@ui.restaurantID)
      return "#{@resourceURL}&license_=#{@ui.restaurantID}"
    @resourceURL

  restaurantsFilterBy2014Year: ->
    this.filter((restaurant) -> restaurant.get("inspection_date").match(/2014-*/g))

  restaurantHasViolationsByLicenseID: (restaurantLicenseID) ->
    @restaurantsFilterBy2014Year().filter((restaurant) -> restaurant.get("license_") == restaurantLicenseID)

  licenseIDsOfRestaurantsViolations: ->
    licenseIDs = []
    @restaurantsFilterBy2014Year().forEach((restaurant) -> licenseIDs.push(restaurant.get("license_")))
    _.uniq(licenseIDs);

  restaurantsViolationsOnGoogleMap: (restaurants) ->
    googleMap = new GoogleMap(@google)
    _.each(restaurants, (restaurantLicenseID) =>
      restaurant = @restaurantHasViolationsByLicenseID(restaurantLicenseID)
      @settingForGoogleMap(restaurant))

  settingForGoogleMap: (data) ->
    mark = googleMap.markLocation data[0].get("latitude"), data[0].get("longitude")
    googleMap.openInfoWindow mark, data[0].toJSON(), data.length

window.Inspections = Inspections

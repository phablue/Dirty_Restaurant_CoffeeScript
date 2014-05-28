class UI
  constructor: (google) ->
    @google = google
    @inspections = new Inspections({google: google, ui: this})
    @restaurantName = null
    @restaurantID = null
    @mark = null

  getInspectionsDataOnGoogleMap: ->
    @inspections.fetch
      success: =>
        @inspections.restaurantsViolationsOnGoogleMap()

  searchWords: ->
    @restaurantName = $(".form-control").val()

  searchResult: ->
    @inspections.fetch
      success: =>
        @showResult(@inspections.licenseIDsOfRestaurantsViolations())

  showResult: (data) ->
    if _.isEmpty(data)
      return @noResultMessage()
    @showDetailOfResult(data)

  showDetailOfResult: (data) ->
    @setMapCSS()
    @setTitle(data)
    @showMarkOnGoogleMap(data)
    @setTableHead()
    _.each(data, (d) => @setTableBody(d))

  searchingRestaurant: ->
    $("form").submit (e) =>
      @searchWords()
      @resetSearchResult()
      @searchResult()
      e.preventDefault()

  resetSearchResult: ->
    $(".form-control").val("")
    $("li, .page-header, small, tr, th, td, .bs-callout-warning, .bg-danger, br").remove()

  showMarkOnGoogleMap: (data) ->
    googleMap = new GoogleMap(@google)
    $("#map-canvas").off "click"
    googleMap.map.setCenter(googleMap.getLocation(data[0].get("latitude"), data[0].get("longitude")))
    googleMap.markLocation data[0].get("latitude"), data[0].get("longitude")

  setMapCSS: ->
    $("#map-canvas").css "height": "37%", "width": "50%"

  noResultMessage: ->
    $("#map-canvas").css "height": "0%", "width": "0%"
    $(".result").before "<br><br><p class='bg-danger'>No results for &nbsp'#{@restaurantName}'</p>"

  setTitle: (data) ->
    $(".title").append """<h1 class = 'page-header'>#{data[0].get("dba_name")}
                         <small>&nbsp&nbsp(#{data[0].get("address")}, Chicago)</small>"""

  setTableHead: ->
    $("thead").append """<tr>
                            <th>Inspection Date</th>
                            <th>Inspection Type</th>
                            <th>Risk</th>
                            <th>Results</th>
                            <th>Violations</th>
                        </tr>"""

  setTableBody: (data) ->
    date = @resetDate(data)
    violations = @replaceViolations(data)
    $("tbody").append """<tr><td>#{date}</td><td>#{data.get("inspection_type")}</td>
                         <td>#{data.get("risk")}</td><td>#{data.get("results")}
                         </td><td>#{violations}</td></tr>"""

  replaceViolations: (data) ->
    data.get("violations").replace(/\s*\|\s*/gi, '<br>')

  resetDate: (data) ->
    data.get("inspection_date").replace('T00:00:00', '')

  goBackHome: ->
    $(".navbar-brand").click =>
      $("#map-canvas").css "height": "70%", "width": "100%"
      @resetSearchResult()
      @restaurantName = null
      @getInspectionsDataOnGoogleMap()

  mainPage: ->
    @goBackHome()
    @getInspectionsDataOnGoogleMap()
    @searchingRestaurant()

window.UI = UI

<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Map.aspx.cs" Inherits="Map" %>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <!-- meta data-->
    <title>Bicycle map</title>
    <meta charset="utf-8" />    
    <meta name='viewport' content='initial-scale=1,maximum-scale=1,user-scalable=no' />
    <!-- link map -->
    <script src='https://api.mapbox.com/mapbox.js/v3.1.1/mapbox.js'></script>
    <link href='https://api.mapbox.com/mapbox.js/v3.1.1/mapbox.css' rel='stylesheet' />
    <!-- stylesheets -->
    <link rel="stylesheet" type="text/css" href="style.css">
    <link rel="stylesheet" href="//code.jquery.com/ui/1.11.4/themes/smoothness/jquery-ui.css">
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.2.0/css/bootstrap.min.css" />
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.2.0/css/bootstrap-theme.min.css" />
    <link rel="stylesheet" href="https://ajax.googleapis.com/ajax/libs/jqueryui/1.11.4/themes/smoothness/jquery-ui.css">
    <!-- scripts -->
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.2.1/jquery.min.js" type="text/javascript"></script>
    <script src="http://code.jquery.com/jquery-latest.min.js"></script>

    <!-- boostrap -->
    <!-- Latest compiled and minified CSS -->
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css" integrity="sha384-BVYiiSIFeK1dGmJRAkycuHAHRg32OmUcww7on3RYdg4Va+PmSTsz/K68vbdEjh4u" crossorigin="anonymous">
    <!-- Optional theme -->
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap-theme.min.css" integrity="sha384-rHyoN1iRsVXV4nD0JutlnGaslCJuC7uwjduW9SVrLvRYooPp2bWYgmgJQIXwl/Sp" crossorigin="anonymous">
    <!-- Latest compiled and minified JavaScript -->
    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js" integrity="sha384-Tc5IQib027qvyjSMfHjOMaLkfuWVxZxUPnCJA7l2mCWNIpG9mGCD8wGNIcPD7Txa" crossorigin="anonymous"></script>
</head>
<body >
    <form id="form1" runat="server">
		<div id="menu" class ="scrollClass">
        <div class="reverse">
			<h3><p>
				<asp:Label ID="checkBoxLabel" runat="server" Text="Bicycle map"></asp:Label>
			</p></h3>
            <table class="table table-hover table-dark">
            <!-- roads -->
            <tr><td>
			    <h4>Road types</h4>
                <p><asp:CheckBox ID="checkboxOther" runat="server"></asp:CheckBox> Roads <br /></p>   
                <p><asp:CheckBox ID="checkboxCycleway" runat="server"></asp:CheckBox> Cycleways <br /></p>
                <p><asp:CheckBox ID="checkboxPedestrian" runat="server"></asp:CheckBox> Pedestrian <br /></p> 
                <p class="form-label">Offset around direct trajectory (km)</p>
			    <p><asp:TextBox ID="boxDistance" runat="server" MaxLength="3">1</asp:TextBox></p>
                <p><button type="button" class="btn btn-primary"onclick="ShowRoutesInDistance()">Show route between markers</button></p>
            </td></tr>
            <!-- buildings -->
            <tr><td>
                <h4>Points of interest (POI)</h4>
                <p><asp:CheckBox ID="checkboxBuildings" runat="server"></asp:CheckBox> Buildings <br /></p>   
                <p><asp:CheckBox ID="checkboxFood" runat="server"></asp:CheckBox> Food <br /></p>
                <p><asp:CheckBox ID="checkboxAccomodation" runat="server"></asp:CheckBox> Accomodation <br /></p>
                <p><asp:CheckBox ID="checkboxBicycleServices" runat="server"></asp:CheckBox> Bicycle services <br /></p>
                <p class="form-label">POI distance from nearest road (m)</p>
			    <p><asp:TextBox ID="boxDstPOI" runat="server" MaxLength="3">250</asp:TextBox></p>
			    <p><button type="button" class="btn btn-primary" onclick="ShowPOIInDistance()">Show POI near roads</button></p>
            </td></tr>
            <!-- nature -->
            <tr><td>
                <h4>Nature</h4>
                <p><asp:CheckBox ID="checkboxForest" runat="server"></asp:CheckBox> Forest <br /></p>   
                <p><asp:CheckBox ID="checkboxPark" runat="server"></asp:CheckBox> Park <br /></p>
                <p><asp:CheckBox ID="checkboxWater" runat="server"></asp:CheckBox> Water <br /></p>
                <p class="form-label">Nature distance from nearest road (m)</p>
			    <p><asp:TextBox ID="boxDstNature" runat="server" MaxLength="3">250</asp:TextBox></p>
			    <p><button type="button" class="btn btn-primary" onclick="ShowNatureInDistance()">Show nature near roads</button></p>
            </td></tr>
            <!-- nearest -->
            <tr><td>
                <h4>Find nearest POI/Nature</h4>
                <p class="form-label">Number of closest objects</p>
			    <p><asp:TextBox ID="boxCount" runat="server" MaxLength="2">1</asp:TextBox></p>
                <p><asp:CheckBox ID="checkboxCount" runat="server"></asp:CheckBox> Number of each type <br /></p>
                <p><button type="button" class="btn btn-primary" onclick="ShowNearest()">Show nearest</button></p>
            </td></tr>
            <!-- other -->
            <tr><td>
                <h4>Other features</h4>
                <p><button type="button" class="btn btn-primary" onclick="ShowAll()">Show POI and Nature</button></p>
                <p><button type="button" class="btn btn-danger" onclick="ShowHeatmap()">Show Heat map</button></p>
                <p><button type="button" class="btn btn-danger" onclick="ClearMap()">Clear map</button></p>
            </td></tr>

            </table>
        </div>
		</div>
		
        <div id="map">			
			<asp:Image ID="Image1" runat="server" ImageUrl="~/Models/Llgbv.gif" CssClass="img" />
            <script type="text/javascript">               

				var emptyGeoJson = jQuery.parseJSON('[]');
				var objectsLayer;

                //--------------constants----------------
				var startingLat = 48.1584888;
				var startingLong = 17.0674546;
				var startingZoom = 13;

				var colorCycleway = "#e1e82e";
				var colorFootway = "#e8a02e";
				var colorWater = "#041c7c";
				var colorForest = "#127c04";


                //--------------initialization-----------
                // distance
				var distanceBox = document.getElementById('distanceBox');
				var checkboxCycleway = document.getElementById('checkboxCycleway');
				var checkboxPedestrian = document.getElementById('checkboxPedestrian');
				var checkboxOther = document.getElementById('checkboxOther');
				checkboxCycleway.checked = true;
				checkboxPedestrian.checked = false;
				checkboxOther.checked = false;
                // buildings
				var checkboxBuildings = document.getElementById('checkboxBuildings');
				var checkboxFood = document.getElementById('checkboxFood');
				var checkboxAccomodation = document.getElementById('checkboxAccomodation');
				var boxDstPOI = document.getElementById('boxDstPOI');
				var checkboxBicycleServices = document.getElementById('checkboxBicycleServices');
				checkboxBuildings.checked = true;
                // nature
				var checkboxForest = document.getElementById('checkboxForest');
				var checkboxPark = document.getElementById('checkboxPark');
				var checkboxWater = document.getElementById('checkboxWater');
				checkboxPark.checked = true;
				checkboxForest.checked = true;
				checkboxWater.checked = true;
                // other
				var boxCount = document.getElementById('boxCount');
				var checkboxCount = document.getElementById('checkboxCount');
				checkboxCount.checked = true;
				var deleteLayer = true;   

                // access token for map
				L.mapbox.accessToken = 'pk.eyJ1IjoicGFzdG8iLCJhIjoiY2pvc3YxOHN1MHV1ZjN3cGIwNWE4aHJjcCJ9.EPBhG_sqvQXtdwGkgXlxvA';
                // create map
				var map = L.mapbox.map('map', 'mapbox.light')
                map.setView([startingLat, startingLong], startingZoom);

                // create marker
                var bikePosition = L.marker(
                    [startingLat, startingLong],
                    {
                        icon: L.mapbox.marker.icon(
                        {
                            'marker-color': '#a30000',
                            'marker-size': 'large',
                            'marker-symbol': 'bicycle'
                        }),
                        draggable: true
                    });
                var destinationPosition = L.marker(
                    [startingLat + 0.01, startingLong + 0.01],
                    {
                        icon: L.mapbox.marker.icon(
                        {
                            'marker-color': '7777FF',
                            'marker-size': 'large',
                            'marker-symbol': 'marker'
                        }),
                        draggable: true
                    });

                bikePosition.addTo(map);
                destinationPosition.addTo(map);

                bikePosition.on('dragend', refreshBikePosition);
                destinationPosition.on('dragend', refreshDestinationPosition);

                refreshBikePosition();
                refreshDestinationPosition();

				ShowRoads();

                // refreshes info in markers based on where they are dragged
				function refreshBikePosition()
				{
					bikePosition.bindPopup('<b> Current position </b><br>' + bikePosition.getLatLng().lat + '<br>' + bikePosition.getLatLng().lng);
				}

				function refreshDestinationPosition()
				{
				    destinationPosition.bindPopup('<b> Destination position </b><br>' + destinationPosition.getLatLng().lat + '<br>' + destinationPosition.getLatLng().lng);
				}

				function ShowRoads()
				{
				    ShowLoadingWheel();
				    $.ajax({
				        type: "POST",
				        async: true,
				        processData: true,
				        cache: false,
				        url: 'Map.aspx/ShowRoads',
				        data: '{"lat":"' + bikePosition.getLatLng().lat + '","lon":"' + bikePosition.getLatLng().lng + '","radius":"' + boxDistance.value  + '","cycleway":"' + checkboxCycleway.checked + '","footway":"' + checkboxPedestrian.checked + '","other":"' + checkboxOther.checked + '"}',
				        contentType: 'application/json; charset=utf-8',
				        dataType: "json",
				        success: function (data) {
				            try {
				                HideLoadingWheel();
				                var geojson = jQuery.parseJSON(data.d);
				                map.featureLayer.setGeoJSON(emptyGeoJson);
				                if (objectsLayer != null && deleteLayer) {
				                    map.removeLayer(objectsLayer);
				                }
				                objectsLayer = L.geoJSON(geojson, {
                                    onEachFeature: onEachFeature,
				                    style: function(feature)
				                    {
				                        switch (feature.properties.popupContent)
				                        {
				                            case 'cycleway': return { color: colorCycleway };
				                            case 'footway': return { color: colorFootway };
				                            case 'pedestrian': return { color: colorFootway };
				                        }
				                    }
				                }).addTo(map);
				            }
				            catch (e) {
				                console.log(e.message);
				                console.log(data.d);
				            }
				        },
				        error: function (e) {
				            HideLoadingWheel();
				            console.log(e.message);
				        }
				    });
                }

				function ShowRoute() {
				    ShowLoadingWheel();
				    $.ajax({
				        type: "POST",
				        async: true,
				        processData: true,
				        cache: false,
				        url: 'Map.aspx/ShowRoute',
				        data: '{"lat":"' + bikePosition.getLatLng().lat + '","lon":"' + bikePosition.getLatLng().lng + '","lat2":"' + destinationPosition.getLatLng().lat + '","lon2":"' + destinationPosition.getLatLng().lng + '","radius":"' + boxDistance.value + '","cycleway":"' + checkboxCycleway.checked + '","footway":"' + checkboxPedestrian.checked + '","other":"' + checkboxOther.checked + '"}',
				        contentType: 'application/json; charset=utf-8',
				        dataType: "json",
				        success: function (data) {
				            try {
				                HideLoadingWheel();
				                var geojson = jQuery.parseJSON(data.d);
				                map.featureLayer.setGeoJSON(emptyGeoJson);
				                if (objectsLayer != null && deleteLayer) {
				                    map.removeLayer(objectsLayer);
				                }
				                objectsLayer = L.geoJSON(geojson, {
				                    onEachFeature: onEachFeature,
				                    style: function (feature) {
				                        switch (feature.properties.popupContent) {
				                            case 'cycleway': return { color: colorCycleway };
				                            case 'footway': return { color: colorFootway };
				                            case 'pedestrian': return { color: colorFootway };
				                        }
				                    }
				                }).addTo(map);
				            }
				            catch (e) {
				                console.log(e.message);
				                console.log(data.d);
				            }
				        },
				        error: function (e) {
				            HideLoadingWheel();
				            console.log(e.message);
				        }
				    });
				}

				function ShowPOI() {
				    ShowLoadingWheel();
				    $.ajax({
				        type: "POST",
				        async: true,
				        processData: true,
				        cache: false,
				        url: 'Map.aspx/ShowPOI',
				        data: '{"lat":"' + bikePosition.getLatLng().lat + '","lon":"' + bikePosition.getLatLng().lng + '","lat2":"' + destinationPosition.getLatLng().lat + '","lon2":"' + destinationPosition.getLatLng().lng + '","radius":"' + boxDistance.value + '","radiusPOI":"' + boxDstPOI.value + '","cycleway":"' + checkboxCycleway.checked + '","footway":"' + checkboxPedestrian.checked + '","other":"' + checkboxOther.checked + '","buildings":"' + checkboxBuildings.checked + '","food":"' + checkboxFood.checked + '","accomodation":"' + checkboxAccomodation.checked + '","services":"' + checkboxBicycleServices.checked + '"}',
				        contentType: 'application/json; charset=utf-8',
				        dataType: "json",
				        success: function (data) {
				            try {
				                HideLoadingWheel();
				                var geojson = jQuery.parseJSON(data.d);
				                map.featureLayer.setGeoJSON(emptyGeoJson);
				                if (objectsLayer != null && deleteLayer) {
				                    map.removeLayer(objectsLayer);
				                }
				                objectsLayer = L.geoJSON(geojson, {
				                    onEachFeature: onEachFeature,
				                    style: function (feature) {
				                        switch (feature.properties.popupContent) {
				                            case 'cycleway': return { color: colorCycleway };
				                            case 'footway': return { color: colorFootway };
				                            case 'pedestrian': return { color: colorFootway };
				                            case 'cycleway': return { color: colorCycleway };
				                            case 'footway': return { color: colorFootway };
				                            case 'pedestrian': return { color: colorFootway }
				                        }
				                    }
				                }).addTo(map);
				            }
				            catch (e) {
				                console.log(e.message);
				                console.log(data.d);
				            }
				        },
				        error: function (e) {
				            HideLoadingWheel();
				            console.log(e.message);
				        }
				    });
				}

				function ShowNature() {
				    ShowLoadingWheel();
				    $.ajax({
				        type: "POST",
				        async: true,
				        processData: true,
				        cache: false,
				        url: 'Map.aspx/ShowNature',
				        data: '{"lat":"' + bikePosition.getLatLng().lat + '","lon":"' + bikePosition.getLatLng().lng + '","lat2":"' + destinationPosition.getLatLng().lat + '","lon2":"' + destinationPosition.getLatLng().lng + '","radius":"' + boxDistance.value + '","radiusPOI":"' + boxDstPOI.value + '","cycleway":"' + checkboxCycleway.checked + '","footway":"' + checkboxPedestrian.checked + '","other":"' + checkboxOther.checked + '","forest":"' + checkboxForest.checked + '","park":"' + checkboxPark.checked + '","water":"' + checkboxWater.checked + '"}',
				        contentType: 'application/json; charset=utf-8',
				        dataType: "json",
				        success: function (data) {
				            try {
				                HideLoadingWheel();
				                var geojson = jQuery.parseJSON(data.d);
				                map.featureLayer.setGeoJSON(emptyGeoJson);
				                if (objectsLayer != null && deleteLayer) {
				                    map.removeLayer(objectsLayer);
				                }
				                objectsLayer = L.geoJSON(geojson, {
				                    onEachFeature: onEachFeature,
				                    style: function (feature) {
				                        switch (feature.properties.popupContent) {
				                            case 'river': return { color: colorWater };
				                            case 'stream': return { color: colorWater };
				                            case 'park': return { color: colorForest };
				                            case 'forest': return { color: colorForest };
				                        }
				                    }
				                }).addTo(map);
				            }
				            catch (e) {
				                console.log(e.message);
				                console.log(data.d);
				            }
				        },
				        error: function (e) {
				            HideLoadingWheel();
				            console.log(e.message);
				        }
				    });
				}

				function ShowNearest() {
				    ShowLoadingWheel();
				    $.ajax({
				        type: "POST",
				        async: true,
				        processData: true,
				        cache: false,
				        url: 'Map.aspx/ShowNearest',
				        data: '{"lat":"' + bikePosition.getLatLng().lat + '","lon":"' + bikePosition.getLatLng().lng + '","buildings":"' + checkboxBuildings.checked + '","food":"' + checkboxFood.checked + '","accomodation":"' + checkboxAccomodation.checked + '","services":"' + checkboxBicycleServices.checked + '","forest":"' + checkboxForest.checked + '","park":"' + checkboxPark.checked + '","water":"' + checkboxWater.checked + '","limit":"' + boxCount.value + '","each":"' + checkboxCount.checked + '"}',
				        contentType: 'application/json; charset=utf-8',
				        dataType: "json",
				        success: function (data) {
				            try {
				                HideLoadingWheel();
				                var geojson = jQuery.parseJSON(data.d);
				                map.featureLayer.setGeoJSON(emptyGeoJson);
				                if (objectsLayer != null && deleteLayer) {
				                    map.removeLayer(objectsLayer);
				                }
				                objectsLayer = L.geoJSON(geojson, {
				                    onEachFeature: onEachFeature,
				                    style: function (feature) {
				                        if (feature.properties.popupContent.startsWith("river")) return { color: colorWater };
				                        if (feature.properties.popupContent.startsWith("riverbank")) return { color: colorWater };
				                        if (feature.properties.popupContent.startsWith("stream")) return { color: colorWater };
				                        if (feature.properties.popupContent.startsWith("park")) return { color: colorForest };
				                        if (feature.properties.popupContent.startsWith("forest")) return { color: colorForest };
				                    },
				                }).addTo(map);
				            }
				            catch (e) {
				                console.log(e.message);
				                console.log(data.d);
				            }
				        },
				        error: function (e) {
				            HideLoadingWheel();
				            console.log(e.message);
				        }
				    });
				}

				function ShowHeatmap() {
				    ShowLoadingWheel();
				    $.ajax({
				        type: "POST",
				        async: true,
				        processData: true,
				        cache: false,
				        url: 'Map.aspx/ShowHeatmap',
				        data: '{}',
				        contentType: 'application/json; charset=utf-8',
				        dataType: "json",
				        success: function (data) {
				            try {
				                HideLoadingWheel();
				                var geojson = jQuery.parseJSON(data.d);
				                map.featureLayer.setGeoJSON(emptyGeoJson);
				                if (objectsLayer != null && deleteLayer) {
				                    map.removeLayer(objectsLayer);
				                }
				                objectsLayer = L.geoJSON(geojson, {
				                    onEachFeature: onEachFeature,
				                    style: function (feature) {
				                        if (feature.properties.popupContent.startsWith("veryFar")) return { color: '#00FF00', stroke: false }
				                        if (feature.properties.popupContent.startsWith("far")) return { color: '#80FF00', stroke: false };
				                        if (feature.properties.popupContent.startsWith("medium")) return { color: '#FFFF00', stroke: false };
				                        if (feature.properties.popupContent.startsWith("close")) return { color: '#FF8000', stroke: false };
				                        if (feature.properties.popupContent.startsWith("veryClose")) return { color: '#FF0000', stroke: false };
				                    },
				                }).addTo(map);
				            }
				            catch (e) {
				                console.log(e.message);
				                console.log(data.d);
				            }
				        },
				        error: function (e) {
				            HideLoadingWheel();
				            console.log(e.message);
				        }
				    });
				}
				
                // display loading wheel
				function ShowLoadingWheel() {

					var img1 = document.getElementById('Image1');
					img1.style.visibility = 'visible';

				}

                // hides loading wheel
				function HideLoadingWheel() {
					var img1 = document.getElementById('Image1');
					img1.style.visibility = 'hidden';
				}

                // bind popup
				function onEachFeature(feature, layer)
				{
				    if (feature.properties && feature.properties.popupContent)
				    {
				        layer.bindPopup(feature.properties.popupContent);
				    }                    
				}

                // listeners
				function ShowRoadsInDistance()
				{
				    deleteLayer = true;
				    ShowRoads();
				}

				function ShowRoutesInDistance()
				{
				    deleteLayer = true;
				    ShowRoute();
				}

				function ShowPOIInDistance()
				{
				    deleteLayer = true;
				    ShowPOI();
				}

				function ShowNatureInDistance()
				{
				    deleteLayer = true;
				    ShowNature();
				}

				function ShowAll()
				{
				    deleteLayer = true;
				    ShowNature();
				    deleteLayer = false;
				    ShowPOI();
				}

				function ClearMap()
				{
				    if (objectsLayer != null) {
				        map.removeLayer(objectsLayer);
				    }
				}

			</script>
        </div>
    </form>
</body>
</html>

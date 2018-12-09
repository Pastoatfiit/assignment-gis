using System;
using System.Web.UI;
using System.Web.UI.WebControls;
using Npgsql;
using System.Text.RegularExpressions;
using System.Collections.Generic;

public partial class Map : Page
{
    private static string connectionString = "Server=127.0.0.1;Password=ndkma2055;Database=PDT_Zadanie;User Id = postgres; Port=5432";

    public static string AddGeometry(string name, string type, string geometry)
    {
        var geoJson = "";

        geoJson += @"{""type"": ""Feature"", ""properties"": {""name"":""" + name + @""", ""popupContent"":""" + type + @"""},";
        geoJson += @"""geometry"": " + geometry + @"}";

        return geoJson;
    }

    [System.Web.Services.WebMethod]
    public static string ShowRoads(string lat, string lon, string radius, string cycleway, string footway, string other)
    {

        var geometries = new List<string>();
        using (var connection = new NpgsqlConnection(connectionString))
        {
            connection.Open();
            var condidtions = new List<string>();
            if(Convert.ToBoolean(other))
            {
                condidtions.Add("type = 'primary'");
                condidtions.Add("type = 'secondary'");
                condidtions.Add("type = 'tertiary'");
                condidtions.Add("type = 'road'");
            }
            if(Convert.ToBoolean(cycleway))
            {
                condidtions.Add("type = 'cycleway'");
            }
            if(Convert.ToBoolean(footway))
            {
                condidtions.Add("type = 'footway'");
                condidtions.Add("type = 'pedestrian'");
            }
            var condition = "(" + string.Join(" or ", condidtions) + ")";


            var query = "select st_asgeojson(geom) as geom, type from roads where " + condition + " and ST_Distance_Sphere(geom, ST_MakePoint('" + lon + "', '" + lat + "')) <= " + Convert.ToInt32(radius) * 1000;

            var command = new NpgsqlCommand(query, connection);

            var reader = command.ExecuteReader();


            while (reader.Read())
            {
                geometries.Add(AddGeometry("road", reader["type"].ToString(), reader["geom"].ToString()));
            }
            reader.Close();
        }

        return "[" + string.Join(", ", geometries) + "]";
    }

    [System.Web.Services.WebMethod]
    public static string ShowRoute(string lat, string lon, string lat2, string lon2, string radius, string cycleway, string footway, string other)
    {

        var geometries = new List<string>();
        using (var connection = new NpgsqlConnection(connectionString))
        {
            connection.Open();
            var condidtions = new List<string>();
            if (Convert.ToBoolean(other))
            {
                condidtions.Add("type = 'primary'");
                condidtions.Add("type = 'secondary'");
                condidtions.Add("type = 'tertiary'");
                condidtions.Add("type = 'road'");
                condidtions.Add("type = 'bridleway'");
            }
            if (Convert.ToBoolean(cycleway))
            {
                condidtions.Add("type = 'cycleway'");
            }
            if (Convert.ToBoolean(footway))
            {
                condidtions.Add("type = 'footway'");
                condidtions.Add("type = 'pedestrian'");
            }
            var condition = "(" + string.Join(" or ", condidtions) + ")";


            var query = "select st_asgeojson(geom) as geom, type from roads where " + condition + " and ST_DWithin(geom, ST_MakeLine(ST_MakePoint('" + lon + "', '" + lat + "'), ST_MakePoint('" + lon2 + "', '" + lat2 + "')), " + Convert.ToInt32(radius) * 1000 + ", true)";

            var command = new NpgsqlCommand(query, connection);

            var reader = command.ExecuteReader();


            while (reader.Read())
            {
                geometries.Add(AddGeometry("road", reader["type"].ToString(), reader["geom"].ToString()));
            }
            reader.Close();
        }

        return "[" + string.Join(", ", geometries) + "]";
    }

    [System.Web.Services.WebMethod]
    public static string ShowPOI(string lat, string lon, string lat2, string lon2, string radius, string radiusPOI, string cycleway, string footway, string other, string buildings, string food, string accomodation, string services)
    {

        var geometries = new List<string>();
        using (var connection = new NpgsqlConnection(connectionString))
        {
            connection.Open();
            var conditions = new List<string>();

            // buildings
            conditions.Add("type = 'ziaden'");
            if (Convert.ToBoolean(buildings))
            {
                conditions.Add("type = 'bunker'");
                conditions.Add("type = 'castle'");
                conditions.Add("type = 'cathedral'");
                conditions.Add("type = 'city gate'");
                conditions.Add("type = 'chapel'");
                conditions.Add("type = 'church'");
            }
            if(Convert.ToBoolean(food))
            {
                conditions.Add("type = 'cafe'");
                conditions.Add("type = 'pub'");
                conditions.Add("type = 'restaurant'");
            }
            if (Convert.ToBoolean(accomodation))
            {
                conditions.Add("type = 'hotel'");
                conditions.Add("type = 'hostel'");
                conditions.Add("type = 'motel'");
            }
            var conditionBuildings = "(" + string.Join(" or ", conditions) + ")";
            conditions.Clear();
            conditions.Add("type = 'ziaden'");
            if (Convert.ToBoolean(other))
            {
                conditions.Add("type = 'primary'");
                conditions.Add("type = 'secondary'");
                conditions.Add("type = 'tertiary'");
                conditions.Add("type = 'road'");
                conditions.Add("type = 'bridleway'");
            }
            if (Convert.ToBoolean(cycleway))
            {
                conditions.Add("type = 'cycleway'");
            }
            if (Convert.ToBoolean(footway))
            {
                conditions.Add("type = 'footway'");
                conditions.Add("type = 'pedestrian'");
            }
            var conditionRoads = "(" + string.Join(" or ", conditions) + ")";

            var query = "select distinct st_asgeojson(ST_Centroid(b.geom)) as bgeom, b.type from (select  type, geom from bicycle_roads where " + conditionRoads;
            query += " and ST_DWithin(geom, ST_MakeLine(ST_MakePoint('" + lon + "', '" + lat + "'), ST_MakePoint('" + lon2 + "', '" + lat2 + "')), " + Convert.ToInt32(radius) * 1000 + ", false)) r ";
            query += " join ((select type, geom, name from buildings where " + conditionBuildings + ")";
            if (Convert.ToBoolean(services)) query += " union (select type, geom, name from points where type = 'bicycle_parking' or type = 'bicycle_rental' or type = 'bicycle_repair_s')";
            query += ") b";
            query += " on ST_DWithin(b.geom, r.geom, " + radiusPOI + ", false)";
            query += " union";
            query += " select st_asgeojson(geom) as bgeom, type from roads where " + conditionRoads + " and ST_DWithin(geom, ST_MakeLine(ST_MakePoint('" + lon + "', '" + lat + "'), ST_MakePoint('" + lon2 + "', '" + lat2 + "')), " + Convert.ToInt32(radius) * 1000 + ", true)";

            var command = new NpgsqlCommand(query, connection);

            var reader = command.ExecuteReader();


            while (reader.Read())
            {
                geometries.Add(AddGeometry(reader["type"].ToString(), reader["type"].ToString(), reader["bgeom"].ToString()));
            }
            reader.Close();

        }

        return "[" + string.Join(", ", geometries) + "]";
    }

    [System.Web.Services.WebMethod]
    public static string ShowNature(string lat, string lon, string lat2, string lon2, string radius, string radiusPOI, string cycleway, string footway, string other, string forest, string park, string water)
    {
        var geometries = new List<string>();
        using (var connection = new NpgsqlConnection(connectionString))
        {
            connection.Open();
            var conditions = new List<string>();

            // nature
            conditions.Add("type = 'ziaden'");
            if (Convert.ToBoolean(forest))
            {
                conditions.Add("type = 'forest'");
            }
            if (Convert.ToBoolean(park))
            {
                conditions.Add("type = 'park'");
            }
            if (Convert.ToBoolean(water))
            {
                conditions.Add("type = 'riverbank'");
            }
            var conditionNature = "(" + string.Join(" or ", conditions) + ")";
            conditions.Clear();
            conditions.Add("type = 'ziaden'");
            if (Convert.ToBoolean(other))
            {
                conditions.Add("type = 'primary'");
                conditions.Add("type = 'secondary'");
                conditions.Add("type = 'tertiary'");
                conditions.Add("type = 'road'");
                conditions.Add("type = 'bridleway'");
            }
            if (Convert.ToBoolean(cycleway))
            {
                conditions.Add("type = 'cycleway'");
            }
            if (Convert.ToBoolean(footway))
            {
                conditions.Add("type = 'footway'");
                conditions.Add("type = 'pedestrian'");
            }
            var conditionRoads = "(" + string.Join(" or ", conditions) + ")";

            var query = "select distinct st_asgeojson(b.geom) as bgeom, b.type from (select  type, geom from bicycle_roads where " + conditionRoads;
            query += " and ST_DWithin(geom, ST_MakeLine(ST_MakePoint('" + lon + "', '" + lat + "'), ST_MakePoint('" + lon2 + "', '" + lat2 + "')), " + Convert.ToInt32(radius) * 1000 + ", false)) r ";
            query += " join ((select type, geom, name from nature where " + conditionNature + ")";
            if (Convert.ToBoolean(water)) query += " union (select type, geom, name from waterways where type = 'stream' or type = 'river')";
            query += ") b";
            query += " on ST_DWithin(b.geom, r.geom, " + radiusPOI + ", false)";
            query += " union";
            query += " select st_asgeojson(geom) as bgeom, type from roads where " + conditionRoads + " and ST_DWithin(geom, ST_MakeLine(ST_MakePoint('" + lon + "', '" + lat + "'), ST_MakePoint('" + lon2 + "', '" + lat2 + "')), " + Convert.ToInt32(radius) * 1000 + ", true)";

            var command = new NpgsqlCommand(query, connection);

            var reader = command.ExecuteReader();


            while (reader.Read())
            {
                geometries.Add(AddGeometry(reader["type"].ToString(), reader["type"].ToString(), reader["bgeom"].ToString()));
            }
            reader.Close();

        }

        return "[" + string.Join(", ", geometries) + "]";
    }

    [System.Web.Services.WebMethod]
    public static string ShowNearest(string lat, string lon, string buildings, string food, string accomodation, string services, string forest, string park, string water, string limit, string each)
    {
        var geometries = new List<string>();
        using (var connection = new NpgsqlConnection(connectionString))
        {
            connection.Open();
            var query = "";
            var subqueries = new List<string>();

            if (Convert.ToBoolean(buildings))
            {
                subqueries.Add("(select st_asgeojson(ST_Centroid(geom)) as geom, type, name from buildings where type = 'castle' order by geom <-> ST_MakePoint('" + lon + "', '" + lat + "') limit " + limit.ToString() + ")");
                subqueries.Add("(select st_asgeojson(ST_Centroid(geom)) as geom, type, name from buildings where type = 'bunker' order by geom <-> ST_MakePoint('" + lon + "', '" + lat + "') limit " + limit.ToString() + ")");
                subqueries.Add("(select st_asgeojson(ST_Centroid(geom)) as geom, type, name from buildings where type = 'cathedral' order by geom <-> ST_MakePoint('" + lon + "', '" + lat + "') limit " + limit.ToString() + ")");
                subqueries.Add("(select st_asgeojson(ST_Centroid(geom)) as geom, type, name from buildings where type = 'chapel' order by geom <-> ST_MakePoint('" + lon + "', '" + lat + "') limit " + limit.ToString() + ")");
                subqueries.Add("(select st_asgeojson(ST_Centroid(geom)) as geom, type, name from buildings where type = 'church' order by geom <-> ST_MakePoint('" + lon + "', '" + lat + "') limit " + limit.ToString() + ")");
                subqueries.Add("(select st_asgeojson(ST_Centroid(geom)) as geom, type, name from buildings where type = 'city gate' order by geom <-> ST_MakePoint('" + lon + "', '" + lat + "') limit " + limit.ToString() + ")");
            }
            if (Convert.ToBoolean(food))
            {
                subqueries.Add("(select st_asgeojson(ST_Centroid(geom)) as geom, type, name from buildings where type = 'cage' order by geom <-> ST_MakePoint('" + lon + "', '" + lat + "') limit " + limit.ToString() + ")");
                subqueries.Add("(select st_asgeojson(ST_Centroid(geom)) as geom, type, name from buildings where type = 'pub' order by geom <-> ST_MakePoint('" + lon + "', '" + lat + "') limit " + limit.ToString() + ")");
                subqueries.Add("(select st_asgeojson(ST_Centroid(geom)) as geom, type, name from buildings where type = 'restaurant' order by geom <-> ST_MakePoint('" + lon + "', '" + lat + "') limit " + limit.ToString() + ")");
            }
            if (Convert.ToBoolean(accomodation))
            {
                subqueries.Add("(select st_asgeojson(ST_Centroid(geom)) as geom, type, name from buildings where type = 'hotel' order by geom <-> ST_MakePoint('" + lon + "', '" + lat + "') limit " + limit.ToString() + ")");
                subqueries.Add("(select st_asgeojson(ST_Centroid(geom)) as geom, type, name from buildings where type = 'hostel' order by geom <-> ST_MakePoint('" + lon + "', '" + lat + "') limit " + limit.ToString() + ")");
                subqueries.Add("(select st_asgeojson(ST_Centroid(geom)) as geom, type, name from buildings where type = 'motel' order by geom <-> ST_MakePoint('" + lon + "', '" + lat + "') limit " + limit.ToString() + ")");
            }
            if (Convert.ToBoolean(services))
            {
                subqueries.Add("(select st_asgeojson(ST_Centroid(geom)) as geom, type, name from points where type = 'bicycle_parking' order by geom <-> ST_MakePoint('" + lon + "', '" + lat + "') limit " + limit.ToString() + ")");
                subqueries.Add("(select st_asgeojson(ST_Centroid(geom)) as geom, type, name from points where type = 'bicycle_rental' order by geom <-> ST_MakePoint('" + lon + "', '" + lat + "') limit " + limit.ToString() + ")");
                subqueries.Add("(select st_asgeojson(ST_Centroid(geom)) as geom, type, name from points where type = 'bicycle_repair_s' order by geom <-> ST_MakePoint('" + lon + "', '" + lat + "') limit " + limit.ToString() + ")");
            }
            if (Convert.ToBoolean(forest))
            {
                subqueries.Add("(select st_asgeojson(geom) as geom, type, name from nature where type = 'forest' order by geom <-> ST_MakePoint('" + lon + "', '" + lat + "') limit " + limit.ToString() + ")");   
            }
            if (Convert.ToBoolean(park))
            {
                subqueries.Add("(select st_asgeojson(geom) as geom, type, name from nature where type = 'park' order by geom <-> ST_MakePoint('" + lon + "', '" + lat + "') limit " + limit.ToString() + ")");

            }
            if (Convert.ToBoolean(water))
            {
                subqueries.Add("(select st_asgeojson(geom) as geom, type, name from nature where type = 'riverbank' order by geom <-> ST_MakePoint('" + lon + "', '" + lat + "') limit " + limit.ToString() + ")");
                subqueries.Add("(select st_asgeojson(geom) as geom, type, name from waterways where type = 'stream' order by geom <-> ST_MakePoint('" + lon + "', '" + lat + "') limit " + limit.ToString() + ")");
                subqueries.Add("(select st_asgeojson(geom) as geom, type, name from waterways where type = 'river' order by geom <-> ST_MakePoint('" + lon + "', '" + lat + "') limit " + limit.ToString() + ")");
            }
            query = string.Join(" UNION ", subqueries);
            if (!Convert.ToBoolean(each)) query = "select * from (" + query + ") as foo order by ST_GeomFromGeoJSON(geom) <-> ST_MakePoint('" + lon + "', '" + lat + "') limit " + limit.ToString();
            var command = new NpgsqlCommand(query, connection);

            

            var reader = command.ExecuteReader();


            while (reader.Read())
            {
                geometries.Add(AddGeometry(reader["type"].ToString(), reader["type"].ToString() + " <br /> " + reader["name"].ToString(), reader["geom"].ToString()));
            }
            reader.Close();
        }
        return "[" + string.Join(", ", geometries) + "]";
    }

    [System.Web.Services.WebMethod]
    public static string ShowHeatmap()
    {
        var geometries = new List<string>();
        using (var connection = new NpgsqlConnection(connectionString))
        {
            connection.Open();
            var query = "";
            query = "select  'veryFar' as distance, veryFar as geom from heatmapAreas union select 'far' as distance, far from heatmapAreas union select 'medium' as distance, medium from heatmapAreas union select 'close' as distance, close from heatmapAreas union select 'veryClose' as distance, veryClose from heatmapAreas";
        
            var command = new NpgsqlCommand(query, connection);



            var reader = command.ExecuteReader();


            while (reader.Read())
            {
                geometries.Add(AddGeometry(reader["distance"].ToString(), reader["distance"].ToString(), reader["geom"].ToString()));
            }
            reader.Close();
        }
        return "[" + string.Join(", ", geometries) + "]";
    }
}
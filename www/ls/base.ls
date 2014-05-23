topo = ig.data.topojson
{vysledky} = ig.data
vysledky_assoc = {}
for vysledek in vysledky
    vysledky_assoc[vysledek.code] = vysledek
features = topojson.feature topo, topo.objects."data" .features
colors =
    "ALDE"       : \#FFD700
    "ECR"        : \#0054A5
    "EFD"        : \#40E0D0
    "GREENS/EFA" : \#009900
    "NA"         : \#999999
    "S&D"        : \#F10000
    "GUE/NGL"    : \#990000
    "EPP"        : \#87CEFA
map = L.map do
    *   ig.containers.base
    *   minZoom: 3,
        maxZoom: 7,
        zoom: 4,
        center: [51.5, 9]
map.addLayer L.tileLayer do
    *   "http://staticmaps.ihned.cz/tiles-world-osm//{z}/{x}/{y}.png"
    *   attribution: 'mapová data &copy; přispěvatelé OpenStreetMap'
        opacity: 0.4


style = (feature) ->
    vysledek = vysledky_assoc[feature.properties.nuts]
    return if not vysledek
    {groups} = vysledek
    [winningPartyVotes, winningParty] = groups.reduce do
        (prev, [name, seats, percentage]:curr, index) ->
            if prev.0 < seats then [seats, name] else prev
        [0, null]

    color = colors[winningParty]
    opacity = 1
    weight = 1
    fillOpacity = 0.7
    {color, opacity, fillOpacity, weight}

# onEachFeature = (feature, layer) ->
#     {useky_cena_zadavaci, useky_skutecna_cena, useky_eu_percent, useky_cerpano} = feature.properties
#     useky_cerpano ?= 0
#     useky_eu_percent ?= 0
#     useky_skutecna_cena ?= 0
#     listItems = []
#     listItems.push "<li>Zadávací cena: #{ig.utils.formatPrice useky_cena_zadavaci} Kč</li>"
#     listItems.push "<li>Konečná cena: #{ig.utils.formatPrice useky_skutecna_cena} Kč</li>" if useky_skutecna_cena
#     listItems.push "<li>Z evropských fondů: #{ig.utils.formatPrice useky_cerpano} Kč (#{useky_eu_percent}%)</li>"
#     layer.bindPopup "<h2>#{feature.properties.usek} #{feature.properties.useky_nazev}</h2>
#     <ul>#{listItems.join ''}</ul>
#     "

silnice = L.geoJson features, {style}
    ..addTo map

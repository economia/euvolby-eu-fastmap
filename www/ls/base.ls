qe = -> document~createElement ...
qs = -> document~querySelector ...
qsa = -> document~querySelectorAll ...

topo = ig.data.topojson
{vysledky} = ig.data
mapContainer = qe \div
ig.containers.base.appendChild mapContainer
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
    "Others"     : \#777

classNames =
    "ALDE"       : \alde
    "ECR"        : \ecr
    "EFD"        : \efd
    "GREENS/EFA" : \greens
    "NA"         : \na
    "S&D"        : \sd
    "GUE/NGL"    : \gue
    "EPP"        : \epp

map = L.map do
    *   mapContainer
    *   minZoom: 3,
        maxZoom: 7,
        zoom: 4,
        center: [51.5, 9]
map.addLayer L.tileLayer do
    *   "http://staticmaps.ihned.cz/tiles-world-osm//{z}/{x}/{y}.png"
    *   attribution: 'mapová data &copy; přispěvatelé <a href="http://www.openstreetmap.org" target="_blank">OpenStreetMap</a>, volební výsledky <a href="http://www.results-elections2014.eu/" target="_blank">Europarlament</a>'
        opacity: 0.4


style = (feature) ->
    vysledek = vysledky_assoc[feature.properties.nuts]
    weight = 0.5
    if vysledek
        {groups} = vysledek
        [winningPartyVotes, winningParty] = groups.reduce do
            (prev, [name, seats, percentage]:curr, index) ->
                if prev.0 < seats then [seats, name] else prev
            [0, null]

        color = \#174F82
        opacity = 0.5
        fillOpacity = 1
        fillColor = colors[winningParty]
    else
        color = \#fff
        opacity = 0.5
        fillOpacity = 0.2
        fillColor = \#fff
    {color, fillColor, opacity, fillOpacity, weight}

poslanciString = (count) ->
    word =
        | count == 1 => "poslanec"
        | 0 < count < 5 => "poslanci"
        | otherwise     => "poslanců"
    "#count #word"
onEachFeature = (feature, layer) ->
    layer.on \click -> displayDetails feature.properties

displayDetails = ({nuts, label}) ->
    vysledek = vysledky_assoc[nuts]
    countryName.innerHTML = label
    partyContainer.innerHTML = ""
    if not vysledek
        poslanciContainer.innerHTML = "Dosud nejsou k dispozici výsledky"
        return
    {groups, parties} = vysledek
    poslanciContainer.innerHTML = ""
    for group in groups
        for [0 til group.1]
            ele = qe \span
                ..setAttribute \class "poslanec #{classNames[group.0]}"
                ..style.backgroundColor = colors[group.0]
                ..setAttribute \title "#{group.0}: #{poslanciString group.1}"
            poslanciContainer.appendChild ele
    console.log groups
    for [party, seats, percent] in parties
        element = qe \li
            ..innerHTML = "<b>#party:</b> #{poslanciString seats}, #{Math.round percent * 100}&nbsp;%"
        partyContainer.appendChild element

infobox = qe \div
    ..setAttribute \class \infobox

ig.containers.base.appendChild infobox

countryName = qe \div
    ..setAttribute \class \countryName
    ..innerHTML = "Předběžné výsledky voleb do EP 2014"

infobox.appendChild countryName

poslanciContainer = qe \div
    ..setAttribute \class \poslanciContainer
    ..innerHTML = "Po kliknutí na zemi v mapě se zde zobrazí její detailní volební výsledky"
infobox.appendChild poslanciContainer


partyContainer = qe \ul
    ..setAttribute \class \partyContainer
legend = qe \div
    ..setAttribute \class "legend winners"
    ..innerHTML = '
    <span title="lidové strany, KDU-ČSL" style="background-color: #87CEFA;">EPP</span>
    <span title="sociální demokraté, ČSSD" style="background-color: #F10000;">SD</span>
    <span title="liberální demokraté, ANO 2011" style="background-color: #FFD700;">ALDE</span>
    <span title="zelení" style="background-color: #009900;">G</span>
    <span title="konzervativci, ODS" style="background-color: #0054A5;">ECR</span>
    <span title="komunisté, KSČM" style="background-color: #990000;">GUE</span>
    <span title="liberálové, Svobodní" style="background-color: #40E0D0;">EAF</span>
    <span title="mimo frakci" style="background-color: #999999;">NI</span>
    '
ig.containers.base.appendChild legend
infobox.appendChild partyContainer

L.geoJson features, {style, onEachFeature}
    ..addTo map

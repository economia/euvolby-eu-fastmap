require! {
    fs
    xml2js
}
download = no
(err, data) <~ fs.readFile "#__dirname/../data/parties.xml"
(err, parties) <~ xml2js.parseString data
parties_assoc = {}
parties.parties.country.forEach (country) ->
    {code} = country.$
    country.key?forEach ->
        {name, value} = it.$
        parties_assoc["#code-#name"] = value
    # country.key.forEach ->
    #     console.log it

doDownload = (cb) ->
    require! request
    (err, res, body) <~ request.get "http://www.results-elections2014.eu/xml/2014/data.xml"
    console.log err if err
    cb null, body
    fs.writeFile "#__dirname/../data/vysledky_e.xml", body
dontDownload = (cb) -> fs.readFile "#__dirname/../data/vysledky_e.xml", cb
downFunction = if download then doDownload else dontDownload
(err, body) <~ downFunction
(err, xml) <~ xml2js.parseString body
groups = xml.root.europeresults.0.europeanresults.0.results.0.resultbygroup
groups .= map ->
    name = it.groupname.0
    seats = parseInt it.seats.0, 10
    percent = 0.01 * parseFloat it.percent
    {name, seats, percent}
groups .= filter (.percent != 1)
fs.writeFile "#__dirname/../data/eu-groups.json", JSON.stringify groups
# return
# console.log groups
countries = xml.root.countryresults.0.country
# console.log countries
# countries.length = 1
countries .= filter -> it.countryparty
# countries.length = 1
countries .= map ->
    code = it.countrycode.0
    # console.log it.countryparty.0.resultbyparty
    # console.log "----AAAA----"
    code_groups = {}
    it.countrypartygroup.0.resultbypartygroup?forEach ->
        name = it.resultbyparty.0.partyname
        groups = it.resultbygroups?map ->
            it.groupname.0
        groups ?= null
        code_groups[name] = groups
    parties = it.countryparty.0.resultbyparty.map ->
        name = it.partyname.0
        seats = parseInt it.seats.0, 10
        percent = 0.01 * parseFloat it.percent.0
        fullname = parties_assoc["#code-#name"]
        groups = code_groups[name]
        [name, seats, percent, fullname, groups]
    groups = it.countrygroup.0.resultbygroup.map ->
        name = it.groupname.0
        seats = parseInt it.seats.0, 10
        [name, seats]
    parties .= filter (.2 != 1)
    groups .= filter (.0 != "TOTAL")
    {code, parties, groups}

fs.writeFile "#__dirname/../data/eu-countries.json", JSON.stringify countries
# console.log countries.0.parties

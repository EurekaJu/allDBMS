/*
Student ID:30391113
Student Name: An JU
Assignment 1 C1
*/

use monUGovDB

// C1.3
db.landmarks.createIndex( { theme: "text" } )
db.properties.createIndex({"address":1, "suburb":1}, {name:"addressWhole"})


//C1.4.i
db.landmarks.find( { $text: { $search: "\"School\"" } }, {"_id":0, "landmarkName":1, "theme":1 } )

//C1.4.ii
db.suburbs.find({},{"_id": 0, "suburb": 1, "propertyCount": 1}).sort( { propertyCount: -1} )

///C1.4.iii
db.suburbs.aggregate([
 { $group: { _id: "$councilArea",
avgPropertyCount: {$avg: "$propertyCount" } } },{$project: {_id:0, CouncilArea: "$_id",avgPropertyCount:{$round:["$avgPropertyCount", 1]}}}, {$sort:{avgPropertyCount:-1}}, {$skip:1}, {$limit:1}
])

//C1.4.iv
db.properties.aggregate([{$group:{_id: {address:"$address",postcode: "$postcode", suburb:"$suburb"}, propertySaleCount:{$sum:1}}}, {$project:{propertySaleCount:"$propertySaleCount"}},{$sort:{propertySaleCount:-1}}]).pretty()


//C1.5
//output before update
db.properties.find({"type":"t"},{_id:0,address:1,postcode:1,suburb:1,type:1}).limit(1)
db.properties.find({"type":"u"},{_id:0,address:1,postcode:1,suburb:1,type:1}).limit(1)
db.properties.find({"type":"h"},{_id:0,address:1,postcode:1,suburb:1,type:1}).limit(1)

/*
//update
db.properties.updateMany({"type":"house"},{$set:{"type": "h"}})
db.properties.updateMany({"type":"unit"},{$set:{"type": "u"}})
db.properties.updateMany({"type":"town house"},{$set:{"type": "t"}})
db.properties.updateMany({"type":{$not:{$in:["house", "unit" , "town house"]}}},{$set:{"type": "other"}})
*/

//update use nested if conditions
db.properties.aggregate([{
    $project: { _id:0, address:"$address", postcode:"$postcode", suburb:"$suburb",
        "type": {
            "$cond": [{"$eq": ["$type", "t"]}, "town house", {
                "$cond": [{"$eq": ["$type", "h"]}, "house", {
                    "$cond": [{"$eq": ["$type", "u"]},
                        "unit", "other"]
                }]
            }]
        }
    }
}, {$out:{db:"monUGovDB",coll:"propertiesNewTypes"}}])

//output after update
db.propertiesNewTypes.find({"type":"town house"},{_id:0,address:1,postcode:1,suburb:1,type:1}).limit(1)
db.propertiesNewTypes.find({"type":"unit"},{_id:0,address:1,postcode:1,suburb:1,type:1}).limit(1)
db.propertiesNewTypes.find({"type":"house"},{_id:0,address:1,postcode:1,suburb:1,type:1}).limit(1)


//C1.6

//output before update
db.landmarks.find({"street":"Monash Road"})

//update and output after update
db.landmarks.updateMany({"street":"Monash Road"}, {$set:{"homeGround": true, "team": 16}})

//output after update
db.landmarks.find({"street":"Monash Road"})


//C1.7 i

//output before join
db.suburbs.find()

//join and saved as a new collection
db.landmarks.updateMany({}, {$rename:{"suburb":"landmark_suburb"}})
db.landmarks.find()
db.suburbs.aggregate([{$lookup:{
    from:"landmarks",
        localField:"suburb",
        foreignField:"landmark_suburb",
        as:"landmarks"
    }},{$out:{db:"monUGovDB",coll:"suburbLandmarks"}}])

//output after join
db.suburbLandmarks.aggregate([{$match:{"landmarks":{$ne:null}}}]).pretty()

//C1.7 ii
db.suburbLandmarks.aggregate([{$group:{_id:"$regionName", regionLandmarksCount:{$sum:1}}},{$project: {_id:0,regionLandmarksCount:"$regionLandmarksCount", regionName:"$_id"}}])


//C1.8 i
db.places.createIndex( { location: "2dsphere" } )
db.landmarks.updateMany({},{$set:{location:{$geometry: {
                    type: "point",
                    coordinates: ["$lat", "$lon"]
                }}}})
db.landmarks.find()
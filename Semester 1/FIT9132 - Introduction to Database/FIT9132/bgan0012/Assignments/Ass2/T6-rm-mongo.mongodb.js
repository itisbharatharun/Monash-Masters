// *****PLEASE ENTER YOUR DETAILS BELOW*****
// T6-rm-mongo.mongodb.js

// Student ID: 35501308
// Student Name: Bharath Arun Gandhimani

// Comments for your marker:

// ===================================================================================
// DO NOT modify or remove any of the comments below (items marked with //)
// ===================================================================================

// Use (connect to) your database - you MUST update xyz001
// with your authcate username

use("bgan0012");

// (b)
// PLEASE PLACE REQUIRED MONGODB COMMAND TO CREATE THE COLLECTION HERE
// YOU MAY PICK ANY COLLECTION NAME
// ENSURE that your query is formatted and has a semicolon
// (;) at the end of this answer

// Drop collection
db.teamsCollection.drop();

// Create collection and insert documents


db.teamsCollection.insertMany(
    [{ "_id": 1, "carn_name": "RM Spring Series Clayton 2024", "carn_date": "22-Sep-2024", "team_name": "Runners High", "team_leader": { "name": "Bharath Arun", "phone": "0466135132", "email": "bharath.arun@monash.com" }, "team_no_of_members": 3, "team_members": [{ "competitor_name": "Bharath Arun", "competitor_phone": "0466135132", "event_type": "5 Km Run", "entry_no": 1, "starttime": "09:30:00", "finishtime": "09:55:00", "elapsedtime": "00:25:00" }, { "competitor_name": "Monica Gellar", "competitor_phone": "0465943512", "event_type": "5 Km Run", "entry_no": 2, "starttime": "09:30:00", "finishtime": "10:00:00", "elapsedtime": "00:30:00" }, { "competitor_name": "Balaji Selvam", "competitor_phone": "0498676534", "event_type": "5 Km Run", "entry_no": 5, "starttime": "09:30:00", "finishtime": "10:05:00", "elapsedtime": "00:35:00" }] }, { "_id": 2, "carn_name": "RM Spring Series Caulfield 2024", "carn_date": "05-Oct-2024", "team_name": "Fast Trackers", "team_leader": { "name": "Senthil Kumar", "phone": "0456387766", "email": "senthil.kumar@email.com" }, "team_no_of_members": 3, "team_members": [{ "competitor_name": "Senthil Kumar", "competitor_phone": "0456387766", "event_type": "5 Km Run", "entry_no": 1, "starttime": "09:00:00", "finishtime": "09:28:00", "elapsedtime": "00:28:00" }, { "competitor_name": "Kaviya Udhayakumar", "competitor_phone": "0413243546", "event_type": "5 Km Run", "entry_no": 2, "starttime": "09:00:00", "finishtime": "09:32:00", "elapsedtime": "00:32:00" }, { "competitor_name": "Gokhul Raj", "competitor_phone": "0431254693", "event_type": "5 Km Run", "entry_no": 5, "starttime": "09:00:00", "finishtime": "09:35:00", "elapsedtime": "00:35:00" }] }, { "_id": 3, "carn_name": "RM Spring Series Clayton 2024", "carn_date": "22-Sep-2024", "team_name": "Speedsters", "team_leader": { "name": "Abishek Cadbury", "phone": "0485673341", "email": "abishek.cadbury@email.com" }, "team_no_of_members": 2, "team_members": [{ "competitor_name": "Abishek Cadbury", "competitor_phone": "0485673341", "event_type": "10 Km Run", "entry_no": 3, "starttime": "08:30:00", "finishtime": "09:15:00", "elapsedtime": "00:45:00" }, { "competitor_name": "Madhimitha Palanivel", "competitor_phone": "0492347143", "event_type": "10 Km Run", "entry_no": 4, "starttime": "08:30:00", "finishtime": "09:18:00", "elapsedtime": "00:48:00" }] }, { "_id": 4, "carn_name": "RM Summer Series Caulfield 2025", "carn_date": "02-Feb-2025", "team_name": "Speedsters", "team_leader": { "name": "Abishek Cadbury", "phone": "0485673341", "email": "abishek.cadbury@email.com" }, "team_no_of_members": 2, "team_members": [{ "competitor_name": "Abishek Cadbury", "competitor_phone": "0485673341", "event_type": "3 Km Community Run/Walk", "entry_no": 1, "starttime": "08:30:00", "finishtime": "08:45:00", "elapsedtime": "00:15:00" }, { "competitor_name": "Madhimitha Palanivel", "competitor_phone": "0492347143", "event_type": "3 Km Community Run/Walk", "entry_no": 2, "starttime": "08:30:00", "finishtime": "08:48:00", "elapsedtime": "00:18:00" }] }, { "_id": 5, "carn_name": "RM Autumn Series Clayton 2025", "carn_date": "15-Mar-2025", "team_name": "Sprint Crew", "team_leader": { "name": "Monica Gellar", "phone": "0465943512", "email": "monica.gellar@monash.com" }, "team_no_of_members": 2, "team_members": [{ "competitor_name": "Monica Gellar", "competitor_phone": "0465943512", "event_type": "3 Km Community Run/Walk", "entry_no": 1, "starttime": "08:00:00", "finishtime": "08:15:00", "elapsedtime": "00:15:00" }, { "competitor_name": "Clark Kent", "competitor_phone": "0463402264", "event_type": "3 Km Community Run/Walk", "entry_no": 2, "starttime": "08:00:00", "finishtime": "08:20:00", "elapsedtime": "00:20:00" }] }]

);




// List all documents you added

db.teamsCollection.find({});

// (c)
// PLEASE PLACE REQUIRED MONGODB COMMAND/S FOR THIS PART HERE
// ENSURE that your query is formatted and has a semicolon
// (;) at the end of this answer


db.teamsCollection.aggregate([
    {
        $unwind: "$team_members"
    },
    {
        $match: {
            "team_members.event_type": { $in: ["5 Km Run", "10 Km Run"] }
        }
    },
    {
        $project: {
            _id: 0, 
            "carnival date": "$carn_date",
            "carnival name": "$carn_name",
            "competitor name": "$team_members.competitor_name",
            "competitor phone": "$team_members.competitor_phone"
        }
    }
 ]);
 



// (d)
// PLEASE PLACE REQUIRED MONGODB COMMAND/S FOR THIS PART HERE
// ENSURE that your query is formatted and has a semicolon
// (;) at the end of this answer


// (i) Add new team

db.teamsCollection.insertOne({
    "_id": 100, 
    "carn_name": "RM WINTER SERIES CAULFIELD 2025",
    "carn_date": "29-Jun-2025",
    "team_name": "The Great Runners",
    "team_leader": {
        "name": "Jackson Bull",
        "phone": "0422412524",
        "email": "jackson@example.com"
    },
    "team_no_of_members": 1,
    "team_members": [
        {
            "competitor_name": "Jackson Bull",
            "competitor_phone": "0422412524",
            "event_type": "5 Km Run",
            "entry_no": 1,
            "starttime": "",
            "finishtime": "",
            "elapsedtime": ""
        }
    ]
 });
 

// Illustrate/confirm changes made
db.teamsCollection.find({ "team_name": "The Great Runners" });


// (ii) Add new team member

db.teamsCollection.updateOne(
    { "team_name": "The Great Runners" },
    {
        $push: {
            "team_members": {
                "competitor_name": "Steve Bull",
                "competitor_phone": "0422251427",
                "event_type": "10 Km Run",
                "entry_no": 2,
                "starttime": "",
                "finishtime": "",
                "elapsedtime": ""
            }
        },
        $inc: { "team_no_of_members": 1 }
    }
 );
 

// Illustrate/confirm changes made

db.teamsCollection.find({ "team_name": "The Great Runners" });

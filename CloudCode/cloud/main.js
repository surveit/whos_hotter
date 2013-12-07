
// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:
function queue(user) {
    user.set("isPaired",false);
    user.save();
}

function pair(user1, user2, options) {
    // Simple syntax to create a new subclass of Parse.Object.
    Parse.Cloud.useMasterKey();
    var Competition = Parse.Object.extend("Competition");
    var newCompetition = new Competition();

    var competitors = new Array();
    competitors[0] = user1.id;
    competitors[1] = user2.id;
    newCompetition.set("userIdentifiers",competitors);
    newCompetition.set("isFinal",false);
    newCompetition.set("startTime",(new Date).getTime());
    newCompetition.set("image0",user1.get("profileImage"));
    newCompetition.set("image1",user2.get("profileImage"));
    newCompetition.save().then(function(competition) {
	console.log("Saved competition");
	user1.set("isPaired",true);
	user2.set("isPaired",true);
	user1.set("activeCompetitionIdentifier",competition.id);
	user2.set("activeCompetitionIdentifier",competition.id);
	user1.add("competitionIdentifiers",competition.id);
	user2.add("competitionIdentifiers",competition.id);
	
	Parse.Object.saveAll([user1, user2], {
	    success: function(list) {
		console.log("Saved users");
		options.success(competition.id);
	    },
	    error: function(error) {
		options.error(error);
	    },
	});
    });
}

Parse.Cloud.define("randomUser", function(request,response) {
    var query = new Parse.Query("User");
    query.find({
	success: function(results) {
	    randomIndex = Math.floor(Math.random()*results.length);
	    response.success(results[randomIndex]);
	},
	error: function(error) {
	    reponse.error(error);
	}
    });
});

Parse.Cloud.define("pairUser", function(request,response) {
    console.log("Start!");
    var userObject = request.user;
    if (userObject.get("isPaired")) {
	
	response.error("User is already paired");
    } else {
	var query = new Parse.Query("User");
	query.equalTo("isPaired",false);
	console.log("username:");
	console.log(userObject.get("username"));
	query.notEqualTo("username",userObject.get("username"));
	query.first().then(function(unpairedUser) {
	    console.log("finished running unpaired user");
	    if (unpairedUser != null) {
		console.log("found user");
		pair(userObject,unpairedUser,{
		    success: function(result) {
			response.success(result);
		    },
		    error: function(error) {
			response.error(error);
		    }});
	    } else {
		console.log("no unpaired user, putting into queue");
		userObject.set("isPaired",false);
		response.success("");
	    }
	});
    }
});

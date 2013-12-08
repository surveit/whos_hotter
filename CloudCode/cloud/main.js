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
    competitors[0] = user1;
    competitors[1] = user2;
    newCompetition.set("users",competitors);
    newCompetition.set("isFinal",false);
    newCompetition.set("startTime",(new Date).getTime());
    newCompetition.set("image0",user1.get("profileImage"));
    newCompetition.set("image1",user2.get("profileImage"));
    newCompetition.set("random",Math.random());
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

Parse.Cloud.job("unpairAllUsers", function(request, status) {
    Parse.Cloud.useMasterKey();
    var query = new Parse.Query("User");
    query.find({
	success: function(results) {
	    for (var i =0;i<results.length;i++) {
		results[i].set("isPaired",false);
	    }
	    Parse.Object.saveAll(results, {
		success: function(list) {
		    status.success("Success");
		},
		error: function(error) {
		    console.log(error);
		    status.error("error");
		}
	    });
	},
	error: function(error) {
	    console.log(error);
	    status.error("error");
	}
    });
});


Parse.Cloud.job("expireCompetitions", function(request, status) {
    Parse.Cloud.useMasterKey();
    var query = new Parse.Query("Competition");
    query.lessThan("startTime",(new Date).getTime() - 300 * 1000);
    query.equalTo("isFinal",false);
    query.include("users");
    query.find({
	success: function(results) {
	    var toSave = new Array();
	    for (var i=0;i<results.length;i++)
	    { 
		var userObjects = results[i].get("users");
		if (userObjects) {
		    var total = results[i].get("votes0") + results[i].get("votes1");
		    var percentage0 = 50;
		    var percentage1 = 50;
		    if (total > 0) {
			percentage0 = results[i].get("votes0") * 100.0 / total;
			percentage1 = results[i].get("votes1") * 100.0 / total;
		    }
		    console.log(userObjects);
		    userObjects[0].set("isPaired",false);
		    userObjects[1].set("isPaired",false);
		    userObjects[0].set("points",userObjects[0].get("points")+percentage0);
		    userObjects[1].set("points",userObjects[1].get("points")+percentage1);
		    results[i].set("isFinal",true);
		    toSave.push(userObjects[0]);
		    toSave.push(userObjects[1]);
		}
	    }
	    Parse.Object.saveAll(toSave, {
		success: function(list) {
		    console.log(toSave);
		    console.log("Saved users");
		    Parse.Object.saveAll(results, {
			success: function(list) {
			    console.log(results);
			    console.log("Saved competitions");
			    status.success("Success!");
			    
			},
			error: function(error) {
			    console.log(error)
			    status.error("ERROR");
			},
		    });
		},
		error: function(error) {
		    console.log(error)
		    status.error("ERROR");
		},
	    });
	},
	error: function(error) {
		status.error(error);
	}
    });
});

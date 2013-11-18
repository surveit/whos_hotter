
// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:
Parse.Cloud.define("hello", function(request, response) {
  response.success("Hello world!");
});

Parse.Cloud.job("createCompetitions", function(request, status) {
    // Set up to modify user data
    Parse.Cloud.useMasterKey();
    
    //first end all competitions

    // Query for all users
    var unpairedUsers = new Array();
    var query = new Parse.Query("User");
    console.log('starting');

    query.find({
	success: function(results) {
	    console.error("success!");
	    console.log("ugh " + results);
	    results.forEach(function(user) {
		console.log('some user');
		if (user.get("isPaired") == false) {
		    unpairedUsers.push(user);
		    console.log('Adding unpaired user');
		}
	    })
	    
	    //randomly permute the list of unpaired users
	    for (var i=0;i<unpairedUsers.length;i++) {
		randomIndex = Math.floor(Math.random()*unpairedUsers.length-i) + i;
		var temp = unpairedUsers[i];
		unpairedUsers[i] = unpairedUsers[randomIndex];
		unpairedUsers[randomIndex] = temp;
	    }

	    //pair off all users
	    for (var i=0;i+1<unpairedUsers.length;i+=2) {
		//create a competition
		var competition = Parse.Object.extend({
		    className: "Competition"
		});
		var user0 = unpairedUsers[i];
		var user1 = unpairedUsers[i+1];
		var users = [user0.get("objectId"),user1.get("objectId")];
		competition.set("userIdentifiers",users);
		competition.set("votes0",0);
		competition.set("votes1",1);
		competition.save();
		user0.isPaired = true;
		user1.isPaired = true;
		user0.save();
		user1.save();
		console.log('creating competition');
	    }
	},
	error: function(error) {
	    console.error("Error: " + error.code + " " + error.message);
	    status.error("Error: " + error.code + " " + error.message);
	}
    });

    status.success("All done");
});

//
//  Surveit.h
//  Surveit-iOS-SDK
//
//  Created by Shuhan Bao on 5/12/13.
//  Copyright (c) 2013 Surveit. All rights reserved.
//

/*!
 @header Surveit SDK
 The Surveit SDK provides functionality to show and manage
 surveys to your users. It can be used to gather feedback
 from your users, or to show revenue generating paid surveys.
 @updated 2013-10-01
 @copyright Surveit Inc.
 */

/*!
 @protocol SurveitDelegate
 @discussion The Surveit delegate serves as the primary
 interface to your application from Surveit.
 It allows Surveit to notify your application about surveys being 
 shown, dismissed, or completed. It also serves as a data source,
 indicating whether a player falls into survey filters.
 */
@protocol SurveitDelegate <NSObject>

@optional

/*!
 @abstract Called when a user successfully completes a survey
 @discussion If you are providing
 rewards, this method MUST be implemented, and it should
 reward the user the proper amount of the currency type
 specified. The one exception is if rewards are handled
 as server-to-server requests, in which case this method
 is optional even when giving rewards.
 @param amount The amount of currency to reward
 @param currency The type of currency to reward
 @indexgroup Managing Surveys
 */
- (void)surveyDidCompleteWithRewardAmount:(NSInteger)amount
                               ofCurrency:(NSString *)currency;

/*!
 @abstract Called whenever Surveit tries to show a survey and that survey
   has a filtering identifier associated with it.
 @discussion The filter is a very general parameter, and it is up to the
 developer to create a convention for what this string should mean (e.g. if
 it should reference an achievement identifier, or represent some kind 
 of predicate string).
 @param filter A string description of the filter.
 @result YES if the identifier is satisfied, allowing the survey to show.
 NO if the identifier is not satisfied, blocking the survey from being shown. 
 @indexgroup Survey Filtering
 */
- (BOOL)shouldShowSurveyWithFilter:(NSString *)filter;

/*!
 @abstract Called when a survey is about to show
 @discussion Use this function to pause your application if necessary. Note that
 you do not need to disable user interaction as Surveit already prevents
 touches from reaching your view while a survey is active.
 @indexgroup Managing Surveys
 */
- (void)surveyWillShow;

/*!
 @abstract Called when a survey has just been dismissed or completed
 @discussion Use this function to resume your application if necessary.
 @indexgroup Managing Surveys
 */
- (void)surveyDidHide;

@end

/*!
 @class Surveit
 @discussion The main Surveit interface. All functions for
 interactive with the Surveit SDK are found here.
 */
@interface Surveit : NSObject

/*!
 @abstract Starts the Surveit session by initializing Surveit
 with application/user specific parameters and then contacting
 Surveit servers.
 @discussion The appIdentifier and secret should be taken from
 https://devs.surveit.com/. Debug mode should be used during
 testing to ensure that you receive surveys and don't save
 test answers.
 @param appIdentifier The identifier for your application
 @param secret The secret token for your appliaction
 @param debugMode If YES, will fetch debug surveys and inactive
 surveys from the server, and prevent any results from being
 saved.
 @indexgroup Initialization
 */
+ (void)startSessionWithAppIdentifier:(NSString *)appIdentifier
                               secret:(NSString *)secret
                            debugMode:(BOOL)debugMode;

/*!
 @abstract Starts the Surveit session by initializing Surveit
 with application/user specific parameters and then contacting
 Surveit servers.
 @discussion The appIdentifier and secret should be taken from
 https://devs.surveit.com/. Debug mode should be used during
 testing to ensure that you receive surveys and don't save
 test answers.
 @param appIdentifier The identifier for your application
 @param secret The secret token for your appliaction
 @param debugMode If YES, will fetch debug surveys and inactive
 surveys from the server, and prevent any results from being
 saved.
 @param playerID Custom player identifier, e.g. a username specific
 to your application
 @indexgroup Initialization
 */
+ (void)startSessionWithAppIdentifier:(NSString *)appIdentifier
                               secret:(NSString *)secret
                            debugMode:(BOOL)debugMode
                             playerID:(NSString *)playerID;

/*!
 @abstract Checks whether there is a developer survey
 @discussion If this return YES, then calling showDeveloperSurvey
 is guaranteed to show a survey. This call may return NO either
 if the user does not qualify for the survey, or assets to show
 the survey are still being downloaded.
 @result YES if a developer survey is available, NO otherwise
 @indexgroup Availability
 */
+ (BOOL)hasDeveloperSurvey;

/*!
 @abstract Checks whether there is a paid survey
 @discussion If this return YES, then calling showPaidSurvey
 is guaranteed to show a survey. This call may return NO either
 if the user does not qualify for the survey, or assets to show
 the survey are still being downloaded.
 @result YES if a paid survey is available, NO otherwise
 @indexgroup Availability
 */
+ (BOOL)hasPaidSurvey;

/*!
 @abstract Shows a paid survey is one is available
 @discussion If no paid survey is available, this call
 will do nothing and return immediately.
 @indexgroup Showing Surveys
 */
+ (void)showPaidSurvey;

/*!
 @abstract Shows a developer survey is one is available
 @discussion If no developer survey is available, this call
 will do nothing and return immediately.
 @indexgroup Showing Surveys
 */
+ (void)showDeveloperSurvey;

/*!
 @abstract Shows a survey if one is avaiable and has an event
 trigger that is a substring of or matches the input event.
 @discussion If no event matches the input event, this function
 returns immediately. Note that when creating the survey, you should
 pick an event trigger that will either match or be a substring
 of the event that is passed as input to this function. For example,
 if you are passing "complete level 4" to this function, the survey
 event trigger should use "complete level 4" or possibly 
 "complete level" or "level 4" in order to trigger off this event.
 @param event Any string description or identifier of an event
 to trigger surveys off of.
 @indexgroup Showing Surveys
 */
+ (void)handleEvent:(NSString *)event;

/*!
 @abstract Sets the Surveit delegate
 @param delegate Any object that conforms to the @link SurveitDelegate @/link
 protocol
 @indexgroup Properties
 */
+ (void)setSurveitDelegate:(id<SurveitDelegate>)delegate;

/*!
 @abstract Cleans up all Surveit related objects.
 @discussion Should be called if the state of
 your application changes such that Surveit's internal state is no longer
 valid. In particular, if the player data is changing, if the delegate
 can no longer handle callbacks (e.g. game is restarting), or if the
 filtering identifier state is changing.
 @indexgroup Cleanup
 */
+ (void)endSession;

/*!
 @abstract Set whether the current player satisfies the filter
 @discussion Can be used to manually set the state of survey filters
 if the delegate method @link shouldShowSurveyWithFilter: @/link
 cannot respond immediately. In general, you should not need to call this
 unless your player objects are stored remotely, and should instead try
 to return the appropriate value in @link shouldShowSurveyWithFilter: @/link.
 @param state YES if the filter is satisfied, NO otherwise
 @param filter The string descriptor for the survey filter in question. The
 filter should match one passed in from @link shouldShowSurveyWithFilter: @/link
 @indexgroup Survey Filtering
 */
+ (void)setState:(BOOL)state forFilter:(NSString *)filter;

@end
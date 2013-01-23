Feature: Signup
Background:
  Given a newly installed build of the mobile app
@utest
Scenario: As a user I can signup to a mobile enabled site
  When I start the application fresh
  And I fill in a url with a valid site
  Then I am presented with a log in screen
  And I log in

@utest
Scenario: As a user I do not remember my site password
  Given that I have signed up to a mobile site
  And I enter an invalid password
  And I request a new password
  And I follow the instructions
  Then I can log in to my site

@utest
Scenario: As a user I need to add a second site to my site list
  Given that I have a second mobile enabled site
  And I tap the Add Site icon
  And I fill in a url with a valid site
  Then I am presented with a log in screen
  And I log in

@utest
Scenario: As a user I can delete my app and still signup to a mobile enabled site
  Given that I have an installed application
  And I have a site that I have a mobile site connected
  And I delete the application
  Then I can reinstall the application
  And I can reconnect to the mobile connected site
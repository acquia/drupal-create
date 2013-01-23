Feature: Sitelist
Background:
  Given that I have a gardens app with multiple sites

@utest
Scenario: As a user I can delete a site from the site list
  When I tap the Edit icon
  And I tap on the Remove icon
  Then I am presented with a confirmation
  And I choose Remove
  Then my site is removed from the site list

@utest
Scenario: As a user I can add a new site from the site list
  When I tap the Add Site icon
  And I fill in a url with a valid site
  Then I am presented with a log in screen
  And I log in

@utest
Scenario: Given that I have signed out of one of my sites in the site list
  And I tap the site name
  Then I am presented with a log in screen
  And I log in

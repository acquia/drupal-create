Feature: Setup
Background:
  Given a drupal site that includes the MASt module enabled

@utest
Scenario: As a user I can configure a content type to access from the mobile app
  And enable MASt for that content type
  And select a short name for that content type
  And select an icon for that content type
  Then I should be able to connect to this site from the mobile app

@utest
Scenario: Given that I have enabled MASt for four content types
  And I attempt to enable MASt for a fifth content type
  Then I get an error

@utest
Scenario: Given that I have a field that is not mobile friendly
  And I attempt to enable MASt for that content type
  Then I get an error

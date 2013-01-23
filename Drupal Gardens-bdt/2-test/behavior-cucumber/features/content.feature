Feature: Content

Background:
  # Can only post or delete cannot edit content
Given that I have an installed gardens mobile app
  And that I have at least one site connected

@utest
Scenario: As a user I can publish new content
# Can be enabled mobile content types
# Users can add tags
# Users can add photos (if enabled)
  Given I am logged into a site via the mobile app
  And I tap the add icon
  And I select a content type
  And I fill out the fields
  Then I have new content on my site
  
@utest
Scenario: As a user I can view a list of published content 
  Given that there is previously created content on the site
  And that content is authored by the user signed into the site
  And that I tap the Sites button
  And I tap a Site name
  Then I should see a list of content 

@utest
Scenario: As a user I can view published content
  Given that I have created content
  And I tap the content preview in the list view
  Then I see my content as it appears on the web

# Delete via swiping the list view
@utest
Scenario: As a user I can delete published content
  Given that I swipe the content preview in the list view
  And I tap the Trash Can icon
  And I tap the Delete confirmation button
  Then my content is deleted

# Delete via the web preview
@utest
Scenario: As a user I can delete published content
  Given that I tap the content preview in the list view
  And I tap the Trash Can icon
  And I tap the Delete confirmation button
  Then my content is deleted

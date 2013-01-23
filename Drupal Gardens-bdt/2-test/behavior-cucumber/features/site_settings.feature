Feature: Site Settings
Background:
  Given that I have an installed gardens mobile app
  And that I have at least one site connected
  And that I tap the Sites button
  And tap a site name in the site list
  And tap the Gear icon
  
@utest
Scenario: As a user I want to change my default Author 
  When I tap on the Author field
  Then I am presented with a list of names that I can filter
  And I can change the default author value

@utest
Scenario: As a user I want to stay logged into my site
  When I switch the Keep Me Logged In setting to on
  Then The next time I access the site from the app I won’t be presented with a login

@utest
Scenario: As a user I want to be logged off of the site when the app closes
  When I switch the Keep Me Logged In setting to off
  Then the next time I access a site from the app I will be presented with a login

@utest
Scenario: As a user I want to set the default image size of 'small|medium|large'
  When I tap on the Image size field
  Then I can select an IOS image size
  And the next content I create uses my saved image size
  And I can verify via a web brwoser the image size posted is correct

@utest
@unimplemented
Scenario: As a user I want to know the "Legal terms" of a site I am connecting to
  When I tap Terms of Service 
  Then I am presented with that content

@utest
@unimplemented
Scenario: As a user I want to know the "Privacy Policy" of a site I am connecting to
  When I tap Privacy Policy 
  Then I am presented with that content

@utest
@unimplemented
Scenario: As a user I want to read the "About Us" content of a site I am connecting to
  When I tap About Us 
  Then I am presented with that content

@utest
Scenario: As a user I want to be able to rate this app
  When I tap Rate It 
  Then I am taken to the app store

@utest
Scenario: As a user I want to log out of a site 
  When I click the Sign out button
  And I click the name of the site
  Then I am presented with a login

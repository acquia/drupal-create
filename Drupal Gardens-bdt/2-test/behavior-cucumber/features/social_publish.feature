Feature: Social Publish
Background:
  Given that I have a gardens app 
  And a Drupal site with MASt enabled for at least one content type
  And the mobile app is connected to the site

@utest
Scenario: As a user I can’t publish my content on social sites 
  Given that I have not set social publishing settings on my Drupal site

@utest
Scenario: As a user I can share my content with my personal Social networks
  Given that my Drupal user is configured with the permission to publish to my own social networks
  And I publish new content

@utest
Scenario: As a user I can share my content with my site’s Social networks
  Given that my Drupal user is configured with the permission to publish to the site’s social networks
  And I publish new content

@utest
Scenario: As a user I can share my content with both my personal and my site’s Social networks
  Given that my Drupal user is configured with the permission to publish to my own social networks as well as the site’s
  And I publish new content

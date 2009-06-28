Feature: Manage signups
  In order to keep track of scores
  As a user
  I want to sign up

  Scenario: Get to the signup page
    Given I am on the homepage
    And I follow "Sign up"
    Then I should see "Basics"
    And I should see "First user"
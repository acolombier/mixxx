Feature: Library

  Background:
    Given a basic profile ready to go
    Given Mixxx is open and ready to operate

  Scenario: Library toggle button is visible
    When I check on the button "LIBRARY" in the main toolbar
    Then the library is shown for less than 75% of the Window's height

  Scenario: Maximize library with toggle
    Given I reset the workspace to default
    When I click the "LIBRARY" button
    Then the library is shown for more than 75% of the Window's height

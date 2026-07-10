Feature: Deck

  Background:
    Given a basic profile ready to go
    Given Mixxx is open and ready to operate

  Scenario: Show all 4 decks
    When I click the "4DECKS" button
    Then the deck "[Channel3]" should be visible
    And the deck "[Channel4]" should be visible

  Scenario: Hide 4 decks
    Given the 4 decks view is enabled
    When I turn off "4 decks" mode
    Then the deck "[Channel3]" should not be visible
    And the deck "[Channel4]" should not be visible

  Scenario: Deck play button toggles playback
    Given the library directory is configured with test tracks
    When I load the track at row 1 into deck 1
    And I click the play button on deck 1
    Then the play button on deck 1 should be pressed
    When I click the play button on deck 1
    Then the play button on deck 1 should be stopped

  Scenario: Deck cue button can be triggered
    Given the library directory is configured with test tracks
    When I load the track at row 1 into deck 1
    And I seek to 0.05 in deck 1
    And I click the cue button on deck 1
    Then the cue point should be set on deck 1

  Scenario: Deck hotcue can be set and cleared
    Given the library directory is configured with test tracks
    When I load the track at row 1 into deck 1
    And I set hotcue 1 on deck 1
    Then hotcue 1 should be set on deck 1
    When I clear hotcue 1 on deck 1
    Then hotcue 1 should not be set on deck 1

  Scenario: Beatjump moves playback position forward
    Given the library directory is configured with test tracks
    When I load the track at row 1 into deck 1
    And I click the play button on deck 1
    And I remember the playback position of deck 1
    When I click the beatjump forward button on deck 1
    Then the playback position of deck 1 should have changed

  Scenario: Loop can be set and enabled
    Given the library directory is configured with test tracks
    When I load the track at row 1 into deck 1
    And I click the play button on deck 1
    And I click the loop in button on deck 1
    And I click the loop out button on deck 1
    Then the loop should be enabled on deck 1

  @test/failing
  Scenario: Loop size can be halved and doubled
    Given the library directory is configured with test tracks
    When I load the track at row 1 into deck 1
    And I remember the beatloop size of deck 1
    When I halve the beatloop size on deck 1
    Then the beatloop size of deck 1 should have changed
    When I double the beatloop size on deck 1
    Then the beatloop size of deck 1 should have changed

  Scenario: Loop can be recalled after exit
    Given the library directory is configured with test tracks
    When I load the track at row 1 into deck 1
    And I click the play button on deck 1
    And I click the loop in button on deck 1
    And I click the loop out button on deck 1
    Then the loop should be enabled on deck 1
    When I click the reloop toggle button on deck 1
    Then the loop should not be enabled on deck 1
    When I click the reloop toggle button on deck 1
    Then the loop should be enabled on deck 1

  Scenario: Sync can be toggled on a deck
    Given the library directory is configured with test tracks
    When I load the track at row 1 into deck 1
    And I click the sync button on deck 1
    Then sync should be enabled on deck 1
    When I click the sync button on deck 1
    Then sync should be disabled on deck 1

  Scenario: Sync leader mode can be toggled with long press
    Given the library directory is configured with test tracks
    When I load the track at row 1 into deck 1
    And I long-press the sync button on deck 1
    Then deck 1 should be the sync leader

  Scenario: Range can be cycled on a deck
    Given the library directory is configured with test tracks
    When I load the track at row 1 into deck 1
    And I remember the rate range of deck 1
    When I click the range button on deck 1
    Then the rate range of deck 1 should have changed

  Scenario: Tempo fader changes playback rate
    Given the library directory is configured with test tracks
    When I load the track at row 1 into deck 1
    And I set the rate of deck 1 to 0.05
    Then the rate of deck 1 should be near 0.05
    And the rate ratio of deck 1 should be near 1.004

  Scenario: Edit mode can be toggled
    When I click the "EDIT" button
    Then edit mode should be enabled
    When I click the "EDIT" button
    Then edit mode should not be enabled

  @test/failing
  Scenario: Edit mode overlays are visible on deck components
    When I click the "EDIT" button
    Then the edit overlay should be visible on the "play" component in deck 1
    When I click the "EDIT" button
    Then the edit overlay should not be visible on the "play" component in deck 1

  @test/failing
  Scenario: Edit mode: single component can be repositioned
    When I click the "EDIT" button
    And I move the "hotcueAndStem" component in deck 1 after the "beatjump" component
    And I click the "EDIT" button
    Then the "hotcueAndStem" component should appear after the "beatjump" component in deck 1

  @test/failing # The selectedGroup overlay sometime appears on the wrong position
  Scenario: Edit mode: component group can be moved
    When I click the "EDIT" button
    And I select the group containing "play" in deck 1 with a "ctrl+click"
    # Select the parent's parent
    And I select the group containing "play" in deck 1 with a "long press"
    # Select the parent's parent's parent
    And I select the group containing "play" in deck 1 with a "ctrl+click"
    And I move the selected group in deck 1 after the "spinny" component
    And I click the "EDIT" button
    Then the "play" component should appear after the "spinny" component in deck 1

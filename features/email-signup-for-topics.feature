Feature: Email signup for policy areas

  Background:
    Given I am a GDS editor
    And govuk delivery exists
    And a policy area called "Wombat management" exists with featured documents

  Scenario: Signing up to policy area alerts
    Given I visit the "Wombat management" policy area
    When I sign up for emails
    Then I should be signed up for the "Wombat management" policy area mailing list

    When I publish a news article "Massive wombat influx in Wimbledon Common" associated with the policy area "Wombat management"
    Then a govuk_delivery notification should have been sent to the mailing list I signed up for

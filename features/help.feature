Feature: Provide usage information for raziel

  Scenario: usage text
    When I run `raziel`
    Then the output should contain "raziel"
    Then the output should contain "Supported commands"
    Then the exit status should be 1

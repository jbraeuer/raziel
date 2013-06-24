@hiera18
Feature: The order of the yaml files in the config.yaml is important

  Background: Encrypt key info
    Given a file named "first.yaml" with:
    """
    ---
    file: first
    """
    And a file named "third.yaml" with:
    """
    ---
    file: third
    """
    And a file named "second.yaml.key" with:
    """
    ---
    password: secret
    recipients:
      - test@example.com
    """
    And I run `raziel key:encrypt second`
    And a file named "fourth.yaml.key" with:
    """
    ---
    password: secret
    recipients:
      - test@example.com
    """
    And I run `raziel key:encrypt fourth`
    And a file named "config.yaml" with:
    """
    ---
    :backends:
      - yamlenc
      - yaml

    :logger: console

    :hierarchy:
      - first
      - second
      - third
      - fourth

    :yaml:
       :datadir: ./

    :yamlenc:
       :datadir: ./
    """

  Scenario: Normal yaml backend order
    When I run `hiera1.8 --config config.yaml file`
    Then the exit status should be 0
    And the output should contain "first"

  Scenario: Order when using also encrypted files
    Given a file named "second.yaml.plain" with:
    """
    ---
    file: PLAIN(second)
    """
    When I run `raziel encrypt second`
    Then the exit status should be 0
    When I remove the file "second.yaml.plain"
    And I run `hiera1.8 --config config.yaml file`
    Then the exit status should be 0
    And the output should contain "second"

  Scenario: Order when using also encrypted files - backends order switched
    Given a file named "config.yaml" with:
    """
    ---
    :backends:
      - yaml
      - yamlenc

    :logger: console

    :hierarchy:
      - first
      - second
      - third
      - fourth

    :yaml:
       :datadir: ./

    :yamlenc:
       :datadir: ./
    """
    Given a file named "second.yaml.plain" with:
    """
    ---
    file: PLAIN(second)
    When I run `raziel encrypt second`
    """
    Then the exit status should be 0
    When I remove the file "second.yaml.plain"
    And I run `hiera1.8 --config config.yaml file`
    Then the exit status should be 0
    And the output should contain "first"

  Scenario: Order when using also encrypted files
    Given a file named "second.yaml.plain" with:
    """
    ---
    file: PLAIN(second)
    """
    And a file named "fourth.yaml.plain" with:
    """
    ---
    file: PLAIN(fourth)
    """
    When I run `raziel encrypt second`
    Then the exit status should be 0
    When I remove the file "second.yaml.plain"
    When I run `raziel encrypt fourth`
    Then the exit status should be 0
    When I remove the file "fourth.yaml.plain"
    And I run `hiera1.8 --config config.yaml file`
    Then the exit status should be 0
    And the output should contain "second"

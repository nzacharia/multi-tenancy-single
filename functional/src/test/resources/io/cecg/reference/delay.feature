Feature: Calling a delay endpoint

  Scenario: Delay returns ok
    Given a rest service
    When I call the delay endpoint with 1 seconds
    Then an ok response is returned
    And the response body is
    """json
{
    "status": "OK"
}
    """

  Scenario: Delay times out
    Given a rest service
    When I call the delay endpoint with 6 seconds
    Then an '500' response is returned
    And the response body is
    """json
{
    "message": "Timeout accessing the server"
}
    """
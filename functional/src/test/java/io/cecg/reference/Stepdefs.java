package io.cecg.reference;


import io.cucumber.core.logging.Logger;
import io.cucumber.core.logging.LoggerFactory;
import io.cucumber.java.en.Given;
import io.cucumber.java.en.Then;
import io.cucumber.java.en.When;
import io.restassured.response.Response;
import io.restassured.specification.RequestSpecification;
import org.apache.commons.lang3.SystemUtils;

import static io.restassured.RestAssured.given;
import static org.apache.http.HttpStatus.SC_OK;
import static org.junit.Assert.assertEquals;

public class Stepdefs {
    private static final Logger LOG = LoggerFactory.getLogger(Stepdefs.class);

    private final String baseUri = SystemUtils.getEnvironmentVariable("SERVICE_ENDPOINT", "http://service:8080");
    private RequestSpecification request;
    private Response response;

    @Given("^a rest service$")
    public void aRestService() {
        request = given().baseUri(baseUri);
    }

    @When("^I call the hello world endpoint$")
    public void i_call_the_hello_world_endpoint() {
        System.out.printf("Hitting endpoint: %s%n", baseUri);
        response = request.when().get("/hello");
    }

    @Then("^an ok response is returned$")
    public void an_ok_response_is_returned() {
        assertEquals("Non 200 status code received", SC_OK, response.statusCode());
    }
}

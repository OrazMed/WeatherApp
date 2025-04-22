@isTest
private class GetWeatherInfoTest {

    /*@TestSetup
    static void setup() {
        WeatherAppConfig__mdt config = new WeatherAppConfig__mdt();
        config.MasterLabel = 'Default_Config';
        config.DeveloperName = 'Default_Config';
        config.Current_Endpoint__c = '/current.json';
        config.Forecast_Endpoint__c = '/forecast.json';
        
        insert config;
    }*/

    @isTest
    static void testGetWeatherInfo(){
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, '{\"location\":{\"name\":\"London\"},\"current\":{\"temp_c\":10}}', '{\"location\":{\"name\":\"London\"},\"forecast\":{\"forecastday\":[{\"date\":\"2025-04-21\",\"day\":{\"maxtemp_c\":15}},{\"date\":\"2025-04-22\",\"day\":{\"maxtemp_c\":12}}]}}'));

        Test.startTest();
        Map<String, Object> result = GetWeatherInfo.getWeatherInfo('London');
        Test.stopTest();

        Assert.areEqual(true, result.containsKey('current'));
        Assert.areEqual(true, result.containsKey('today'));
        Assert.areEqual(true, result.containsKey('tomorrow'));

        Map<String, Object> current = (Map<String, Object>)result.get('current');
        Map<String, Object> today = (Map<String, Object>)result.get('today');
        Map<String, Object> tomorrow = (Map<String, Object>)result.get('tomorrow');

        Assert.areEqual(10, ((Map<String, Object>)current.get('current')).get('temp_c'));
        Assert.areEqual(15, today.get('maxtemp_c'));
        Assert.areEqual(12, tomorrow.get('maxtemp_c'));
        Assert.areEqual('2025-04-21', today.get('date'));
        Assert.areEqual('2025-04-22', tomorrow.get('date'));
    }

    @isTest
    static void testGetWeatherInfoEmptyCity() {
        Boolean coughtException = false;
        try {
            Test.startTest();
            GetWeatherInfo.getWeatherInfo('');
            Test.stopTest();
        } catch (AuraHandledException ex) {
            Assert.areEqual('City name cannot be null or empty.', ex.getMessage());
            coughtException = true;
        }
        Assert.isTrue(coughtException);
    }

    @isTest
    static void testGetWeatherInfoInvalidCity() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(400, '{\"error\":{\"message\":\"Invalid city\"}}', ''));
        Boolean coughtException = false;
        try {
            Test.startTest();
            GetWeatherInfo.getWeatherInfo('Invalid city');
            Test.stopTest();
        } catch (AuraHandledException ex) {
            Assert.isTrue(ex.getMessage().contains('Failed to get weather data = 400'));
            coughtException = true;
        }
        Assert.isTrue(coughtException);
    }

    @isTest
    static void testGetWeatherInfoNullCity() {
        Boolean coughtException = false;
        try {
            Test.startTest();
            GetWeatherInfo.getWeatherInfo(null);
            Test.stopTest();
        } catch (AuraHandledException ex) {
            Assert.areEqual('City name cannot be null or empty.', ex.getMessage());
            coughtException = true;
        }
        Assert.isTrue(coughtException);
    }

    public class MockHttpResponseGenerator implements HttpCalloutMock {
        Integer statusCode;
        String currentBody;
        String forecastBody;

        public MockHttpResponseGenerator(Integer statusCode, String currentBody, String forecastBody) {
            this.statusCode = statusCode;
            this.currentBody = currentBody;
            this.forecastBody = forecastBody;
        }

        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(statusCode);
            if(req.getEndpoint().contains('/current.json')) {
                res.setBody(currentBody);
            }else if(req.getEndpoint().contains('/forecast.json')) {
                res.setBody(forecastBody);
            }
            return res;
        }
    }
}
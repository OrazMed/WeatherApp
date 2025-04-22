@isTest
private class GetWeatherInfoTest {

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
        try {
            Test.startTest();
            GetWeatherInfo.getWeatherInfo('');
            Test.stopTest();
            Assert.fail('An exception should have been thrown');
        } catch (CalloutException ex) {
            Assert.areEqual('City name cannot be null or empty.', ex.getMessage(), 'Exception message = ' + ex.getMessage());
        }
    }

    @isTest
    static void testGetWeatherInfoInvalidCity() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(400, '{\"error\":{\"message\":\"Invalid city\"}}', ''));
        try {
            Test.startTest();
            GetWeatherInfo.getWeatherInfo('Invalid city');
            Test.stopTest();
            Assert.fail('An exception should have been thrown');
        } catch (AuraHandledException ex) {
            Assert.areEqual('Script-thrown exception', ex.getMessage(), 'Exception message = ' + ex.getMessage());
        }
    }

    @isTest
    static void testGetWeatherInfoNullCity() {
        try {
            Test.startTest();
            GetWeatherInfo.getWeatherInfo(null);
            Test.stopTest();
            Assert.fail('An exception should have been thrown');
        } catch (CalloutException ex) {
            Assert.areEqual('City name cannot be null or empty.', ex.getMessage(), 'Exception message = ' + ex.getMessage());
        }
    }

    @isTest
    static void testFormatDate() {
        Date testDate = Date.newInstance(2025, 4, 9);
        String expectedFormattedDate = '2025-04-09';

        Test.startTest();
        String formattedDate = GetWeatherInfo.formatDate(testDate);
        Test.stopTest();

        Assert.areEqual(expectedFormattedDate, formattedDate, 'Exception message = ' + formattedDate);
    }

    @isTest
    static void testGetCityNames() {
        List<String> expectedCityNames = new List<String>();
        for(City__mdt city : [SELECT City_Name__c, Is_Active__c FROM City__mdt WHERE Is_Active__c = true]) {
            expectedCityNames.add(city.City_Name__c);
        }
        
        Test.startTest();
        List<String> cityNames = GetWeatherInfo.getCityNames();
        Test.stopTest();

        Assert.areEqual(expectedCityNames, cityNames, 'Exception message = ' + cityNames);
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
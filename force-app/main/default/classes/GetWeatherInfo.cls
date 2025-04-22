public with sharing class GetWeatherInfo {
    // Named credentials
    private static final String NAMED_CREDENTIAL = 'WeatherApi';

    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getWeatherInfo(String citySelected) {
        if (String.isBlank(citySelected)) {
            throw new CalloutException('City name cannot be null or empty.');
        }
        String city = EncodingUtil.urlEncode(citySelected, 'UTF-8');
        Map<String, Object> result = new Map<String, Object>();

        try {
            WeatherAppConfig__mdt config = WeatherAppConfig__mdt.getInstance('Default_Config');

            // Current weather
            String currentEndpoint = 'callout:' + NAMED_CREDENTIAL + config.Current_Endpoint__c + '?q=' + city;
            Map<String, Object> currentWeather = makeApiCall(currentEndpoint);
            result.put('current', currentWeather);


            //Forecast Check
            String forecasetEndp = 'callout:' + NAMED_CREDENTIAL + config.Forecast_Endpoint__c + '?q=' + city + '&days=2';
            Map<String, Object> forecastData = makeApiCall(forecasetEndp);
            
            // Check forecastData
            if (forecastData != null && forecastData.containsKey('forecast')) {
                Map<String, Object> forecast = (Map<String, Object>) forecastData.get('forecast');
                if (forecast != null && forecast.containsKey('forecastday')) {
                    List<Object> forecastDays = (List<Object>) forecast.get('forecastday');
                    if (forecastDays != null && forecastDays.size() >= 2) {
                        // Today's Forecast
                        Map<String, Object> todayForecast = (Map<String, Object>) forecastDays[0];
                        if (todayForecast != null && todayForecast.containsKey('day')) {
                            Map<String, Object> todayDay = (Map<String, Object>) todayForecast.get('day');
                            todayDay.put('date', todayForecast.get('date'));
                            result.put('today', todayDay);
                        }
                        
                        // Tomorrow's forecast
                        Map<String, Object> tomorrowForecast = (Map<String, Object>) forecastDays[1];
                        if (tomorrowForecast != null && tomorrowForecast.containsKey('day')) {
                            Map<String, Object> tomorrowDay = (Map<String, Object>) tomorrowForecast.get('day');
                            tomorrowDay.put('date', todayForecast.get('date'));
                            result.put('tomorrow', tomorrowDay);
                        }
                    }
                }
            }

            return result;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static Map<String, Object> makeApiCall(String endpoint) {
        
        System.debug('endpoint = ' + endpoint);
        // HTTP request
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('GET');

        HttpResponse res = http.send(req);

        // Check the response
        if(res.getStatusCode() == 200) {
            Map<String, Object> weather = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            System.debug('The weather data = ' + res.getBody());
            return weather;
        }else {
            throw new CalloutException('Failed to get weather data = ' + res.getStatus() + '---' + res.getBody());
        }
    }

    public static String FormatDate(Date dateToBeFormatted) {
        String formattedDate = String.valueOf(dateToBeFormatted.year()) + '-' + String.valueOf(dateToBeFormatted.month()).leftPad(2, '0') + '-' + String.valueOf(dateToBeFormatted.day()).leftPad(2, '0');

        return formattedDate;
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getCityNames() {
        List<String> cities = new List<String>();
        for(City__mdt city : [SELECT City_Name__c, Is_Active__c FROM City__mdt WHERE Is_Active__c = true]) {
            cities.add(city.City_Name__c);
        }
        return cities;
    }
}
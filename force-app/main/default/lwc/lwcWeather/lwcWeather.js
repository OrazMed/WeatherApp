import { LightningElement, wire } from 'lwc';
import getWeatherData from '@salesforce/apex/GetWeatherInfo.getWeatherInfo';
import getCities from '@salesforce/apex/GetWeatherInfo.getCityNames';


export default class LwcWeather extends LightningElement {
    selectedCity;
    weatherData = { current: {}, today: {}, tomorrow: {} };
    error;
    cities = ['London', 'New York', 'Paris', 'Liverpool', 'Glasgow', 'Blackpool'];
    isCitySelected = false;
    gotData = false;
    isCelsius = true;

    // Fetch city names from Custom metadata type "City"
    @wire(getCities)
    wiredCityNames({ data, error }) {
        if(data) {
            this.cities = data;
        }else if(error) {
            this.error = 'Error fetching city names: ' + error.body.message;
        }
    }

    handleCityChange(event) {
        this.selectedCity = event.target.value;
        this.isCitySelected =! !this.selectedCity;
    }

    getWeather() {
        if (this.selectedCity) {
            getWeatherData({ citySelected: this.selectedCity })
                .then(result => {
                    this.gotData = true;
                    this.weatherData = result;
                    this.error = undefined;
                })
                .catch(error => {
                    this.gotData = false;
                    this.error = 'Error fetching weather data: ' + error.body.message;
                    this.weatherData = { current: {}, today: {}, tomorrow: {} };
                });
        }else {
            this.gotData = false;
            this.error = 'Please select a city.';
            this.weatherData = { current: {}, today: {}, tomorrow: {} };
        }
    }

    toggleTemperatureUnit(event) {
        this.isCelsius = event.target.checked;
        console.log('is celcius = ' + this.isCelsius);
    }

    get buttonVariant() {
        return this.isCitySelected ? 'brand' : 'brand-outline';
    }

    get temperatureUnitLabel() {
        return this.isCelsius ? '°C' : '°F';
    }

    get currentTemperature() {
        return this.isCelsius ? 
            this.weatherData.current.current.temp_c + this.temperatureUnitLabel: 
            this.weatherData.current.current.temp_f + this.temperatureUnitLabel;
    }

    get feelsLikeT() {
        return this.isCelsius ? 
            this.weatherData.current.current.feelslike_c + this.temperatureUnitLabel: 
            this.weatherData.current.current.feelslike_f + this.temperatureUnitLabel;
    }

    get todaysMaxT() {
        return this.isCelsius ? 
            this.weatherData.today.maxtemp_c + this.temperatureUnitLabel: 
            this.weatherData.today.maxtemp_f + this.temperatureUnitLabel;
    }

    get todaysMinT() {
        return this.isCelsius ? 
            this.weatherData.today.mintemp_c + this.temperatureUnitLabel: 
            this.weatherData.today.mintemp_f + this.temperatureUnitLabel;
    }

    get todaysAvgT() {
        return this.isCelsius ? 
            this.weatherData.today.avgtemp_c + this.temperatureUnitLabel: 
            this.weatherData.today.avgtemp_f + this.temperatureUnitLabel;
    }

    get tomorrowsMaxT() {
        return this.isCelsius ? 
            this.weatherData.tomorrow.maxtemp_c + this.temperatureUnitLabel: 
            this.weatherData.tomorrow.maxtemp_f + this.temperatureUnitLabel;
    }

    get tomorrowsMinT() {
        return this.isCelsius ? 
            this.weatherData.tomorrow.mintemp_c + this.temperatureUnitLabel: 
            this.weatherData.tomorrow.mintemp_f + this.temperatureUnitLabel;
    }

    get tomorrowsAvgT() {
        return this.isCelsius ? 
            this.weatherData.tomorrow.avgtemp_c + this.temperatureUnitLabel: 
            this.weatherData.tomorrow.avgtemp_c + this.temperatureUnitLabel;
    }
}
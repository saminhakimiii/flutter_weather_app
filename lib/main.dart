import 'dart:async';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'current_city_data_model.dart';
import 'forecast_days_model.dart';



void main() {

  runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      home : MyApp()
  ) );

}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  late Future<CurrentCityDataModel> currentweatherFuture;
  late StreamController<List<ForecastDaysModel>> StreamForcastDays;

  var cityname = "tehran";
  var lat;
  var lon;

  TextEditingController textEditingController = TextEditingController();

  @override
  void initState(){
    super.initState();

    currentweatherFuture = SendRequestCurrentWeather(cityname);
    StreamForcastDays = StreamController<List<ForecastDaysModel>>();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        title: Text("Weather App"),
        elevation: 15,
        actions:<Widget> [
          PopupMenuButton<String>(itemBuilder: (BuildContext context){
            return {'setting','logout'}.map((String Choice){
              return PopupMenuItem(
                value: Choice,
                child: Text(Choice),
              );
            }).toList();
          })
        ],

      ),
      body: FutureBuilder<CurrentCityDataModel>(

        future: currentweatherFuture,
        builder: (context , snapshot){
          if(snapshot.hasData){

            CurrentCityDataModel? cityDateModel = snapshot.data;
            SendRequest7DaysForcast(lat, lon);

            final formatter = DateFormat.jm();
            var sunrise = formatter.format(
                new DateTime.fromMicrosecondsSinceEpoch(
                  cityDateModel!.sunrise * 1000,
                  isUtc:true,
                )
            );
            var sunset = formatter.format(
                new DateTime.fromMicrosecondsSinceEpoch(
                  cityDateModel!.sunset * 1000,
                  isUtc:true,
                )
            );




            return Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                      fit: BoxFit.cover,
                      image: AssetImage('images/nody.jpg')
                  )
              ),
              // color: Colors.black,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10 , sigmaY: 10),
                child: Center(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 15),
                              child: ElevatedButton(onPressed: (){

                                setState(() {
                                  currentweatherFuture = SendRequestCurrentWeather(textEditingController.text);
                                });

                              }, child: Text("find")),
                            ),
                            Expanded(child: TextField(
                              controller: textEditingController,
                              decoration: const InputDecoration(
                                  hintText: "enter a city name",
                                  hintStyle: TextStyle(color: Colors.white),
                                  border: UnderlineInputBorder()
                              ),
                              style: const TextStyle(color: Colors.white),
                            ))
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Text(cityDateModel!.cityname,style: TextStyle(color: Colors.white , fontSize: 35),),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: Text(cityDateModel.description,style: TextStyle(color: Colors.grey , fontSize: 20),),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 25),
                            child: setIconForMain(cityDateModel),),

                          Text(cityDateModel.temp.toString()+"\u00B0",style: TextStyle(color: Colors.white , fontSize: 30),),
                          Padding(
                            padding: const EdgeInsets.only(top : 10),

                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Column(
                                    children:[
                                      Text("max",style: TextStyle(color: Colors.grey,fontSize: 20),),
                                      Padding(
                                        padding: const EdgeInsets.only(top:10),
                                        child: Text(cityDateModel.temp_max.toString()+"\u00B0",style: TextStyle(color: Colors.white,fontSize: 20),),
                                      ),
                                    ]

                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: Container(
                                      width: 1,
                                      height: 50,
                                      color:Colors.white
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left:10),
                                  child: Column(
                                      children:[
                                        Text("min",style: TextStyle(color: Colors.grey,fontSize: 20),),
                                        Padding(
                                          padding: const EdgeInsets.only(top:10),
                                          child: Text(cityDateModel.temp_min.toString()+"\u00B0",style: TextStyle(color: Colors.white,fontSize: 20),),
                                        ),
                                      ]
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.only(top:10),
                            child: Container(
                              width: double.infinity,
                              height: 1,
                              color: Colors.grey,
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            height: 100,
                            child: Padding(
                              padding: const EdgeInsets.only(top :10),
                              child: Center(
                                child: StreamBuilder<List<ForecastDaysModel>>(

                                  stream: StreamForcastDays.stream,
                                  builder: (context, snapshot){
                                    if(snapshot.hasData){

                                      List<ForecastDaysModel>? forecastdays = snapshot.data;
                                      return  ListView.builder(

                                          scrollDirection: Axis.horizontal,
                                          shrinkWrap: true,
                                          itemCount: 6,
                                          itemBuilder: (BuildContext context , int pos){
                                            print('hello');
                                            return listViewItems(forecastdays ![pos + 1]);

                                          });
                                    }else{
                                      return Center(
                                          child: CircularProgressIndicator(
                                            backgroundColor: Colors.grey,
                                          )
                                      );
                                    }
                                  },
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top:0),
                            child: Container(
                              width: double.infinity,
                              height: 1,
                              color: Colors.grey,
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Column(
                                  children: [
                                    Text("wind speed",style: TextStyle(color: Colors.grey , fontSize: 15),),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 10),
                                      child: Text(cityDateModel.windSpeed.toString(),style: TextStyle(color: Colors.white),),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: Container(
                                    width: 1,
                                    height: 40,
                                    color: Colors.grey,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: Column(
                                    children: [
                                      Text("sunrise",style: TextStyle(color: Colors.grey , fontSize: 15),),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 10),
                                        child: Text(sunrise,style: TextStyle(color: Colors.white),),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: Container(
                                    width: 1,
                                    height: 40,
                                    color: Colors.grey,
                                  ),
                                ),

                                Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: Column(
                                    children: [
                                      Text("sunset",style: TextStyle(color: Colors.grey , fontSize: 15),),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 10),
                                        child: Text(sunset,style: TextStyle(color: Colors.white),),
                                      ),
                                    ],
                                  ),
                                ),

                                Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: Container(
                                    width: 1,
                                    height: 40,
                                    color: Colors.grey,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: Column(
                                    children: [
                                      Text("humidity",style: TextStyle(color: Colors.grey , fontSize: 15),),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 10),
                                        child: Text(cityDateModel.humidity.toString()+"%",style: TextStyle(color: Colors.white),),
                                      ),
                                    ],
                                  ),
                                ),

                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
          else{
            return Center(
                child: CircularProgressIndicator(
                  backgroundColor: Colors.grey,
                )
            );
          }
        },
      ),
    );
  }
  Container listViewItems(ForecastDaysModel forecastday){
    return Container(
      height: 50,
      width: 50,
      // color: Colors.white,
      child: Card(
        elevation: 0,
        color: Colors.transparent,
        child: Column(
          children: [
            Text(forecastday.dataTime,style: TextStyle(color: Colors.grey, fontSize: 10),),
            Expanded(child: setIconForMain(forecastday)),
            Text(forecastday.temp.round().toString()+"\u00B0",style: TextStyle(color: Colors.white, fontSize: 10),),
          ],
        ),
      ),
    );
  }
  Image setIconForMain(model) {
    String description = model.description;

    if (description == "clear sky") {
      return Image(image: AssetImage('images/icons8-sun-50.png'));
    }
    else if (description == "few clouds") {
      return Image(image: AssetImage('images/icons8-haze-80.png'));
    }
    else if (description.contains("clouds")) {
      return Image(image: AssetImage('images/icons8-clouds-80 (3).png'));
    }
    else if (description.contains("thunderstorm")) {
      return Image(image: AssetImage('images/icons8-cloud-lightning-80.png'));
    }
    else if (description.contains("drizzle")) {
      return Image(image: AssetImage('images/icons8-rain-cloud-80.png'));
    }
    else if (description.contains("snow")) {
      return Image(image: AssetImage('images/icons8-light-snow-80.png'));
    }
    else {
      return Image(image: AssetImage('images/icons8-light-snow-80.png'));
    }
  }

  Future<CurrentCityDataModel> SendRequestCurrentWeather(
      String cityname) async {
    var apikey = '6abc7aae368c3944b3fbf4945ba10c49';

    var response = await Dio().get(
        "https://api.openweathermap.org/data/2.5/weather",
        queryParameters: {'q': cityname, 'appid': apikey, 'units': 'metric'}

    );
    lat = response.data["coord"]["lat"];
    lon = response.data["coord"]["lon"];

    print(response.data)
    ;
    print(response.statusCode);


    var datamodel = CurrentCityDataModel(
        response.data["name"],
        response.data["coord"]["lon"],
        response.data["coord"]["lat"],
        response.data["weather"][0]["main"],
        response.data["weather"][0]["description"],
        response.data["main"]["temp"],
        response.data["main"]["temp_min"],
        response.data["main"]["temp_max"],
        response.data["main"]["pressure"],
        response.data["main"]["humidity"],
        response.data["wind"]["speed"],
        response.data["dt"],
        response.data["sys"]["country"],
        response.data["sys"]["sunrise"],
        response.data["sys"]["sunset"]);
    return datamodel;
  }

  void SendRequest7DaysForcast(lat,lon) async{

    List<ForecastDaysModel> list = [];
    var apikey = '6abc7aae368c3944b3fbf4945ba10c49';

    try{
      var response = await Dio().get(
          "https://api.openweathermap.org/data/3.0/onecall",
          queryParameters: {
            'lat': lat ,
            'lon': lon ,
            'exclude': 'minutely,hourly' ,
            'appid' : apikey,
            'units' :'metric'
          });
      final formatter = DateFormat.MMMd();
      for(int i = 0 ; i<8 ; i++){
        var model = response.data['daily'][i];
        var dt = formatter.format(new DateTime.fromMicrosecondsSinceEpoch(
            model['dt']*1000,
            isUtc: true
        ));
        ForecastDaysModel forecastDaysModel = ForecastDaysModel(dt, model['temp']['day'],model['weather'][0]['main'], model['weather'][0]['description']);
        list.add(forecastDaysModel);
        print('ssss');
      }
      StreamForcastDays.add(list);
      print('muooo');
    }

    on DioError catch(e){
      print(e);


    };
  }
}
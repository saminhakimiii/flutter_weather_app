class ForecastDaysModel{

  var _dataTime;
  var _temp;
  String _main;
  String _description;

  ForecastDaysModel(this._dataTime, this._temp, this._main, this._description);

  String get description => _description;

  String get main => _main;

  get temp => _temp;

  get dataTime => _dataTime;
}
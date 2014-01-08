$.getScript("http://yui.yahooapis.com/3.13.0/build/yui/yui-min.js", function(){

  YUI().use('charts', function (Y) { 
    var myDataValues = [["5/1/2010", "5/2/2010", "5/3/2010", "5/4/2010", "5/5/2010"],
      [2000, 50, 400, 200, 5000]];
    var mychart = new Y.Chart({dataProvider:myDataValues, render:"#mychart"});
  });

});
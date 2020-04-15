

(function ($) {     
    if (!window.yourNamespace) {
        window.yourNamespace = {};
    }
    if (!window.yourNamespace.yourPageScript) {
        window.yourNamespace.yourPageScript = function () {
            var populateView = function (dropDown) {
                if (dropDown && dropDown.length) {
                    var value = dropdown.val();
                    $.ajax({
                        method: "GET",
                        cache: false,
                        url: "http://" + window.location.host+"/ParkingArea//PopulateType",  
                        dataType: "HTML" ,
                        data: { selectedValue: value }
                })
                .done(function (response) { // jQuery 1.8 deprecates success() callback
                    var div = $('partialViewDiv');
                    div.html('');
                    div.html(response);
                });
            }
        };

        return {
            populateView: populateView
        };
    };
}
}(jQuery));
(function() {
	var app = angular.module('portroach', []);

	app.controller('OverviewController',['$http', '$scope', function($http, $scope) {
		this.onlyOutdated = false;
		var overview = this;
		overview.maintainers = [];
		overview.summary = [];

	        $scope.loading = true;

		$http.get('./json/totals.json').success(function(data) {
		        var i, l = data.results.length;
		        for (i = 0; i < l; i++) {
			    data.results[i].percentage = parseFloat(data.results[i].percentage);
			    data.results[i].total = parseInt(data.results[i].total, 10);
			    data.results[i].withnewdistfile = parseInt(data.results[i].withnewdistfile, 10);
			}

			overview.maintainers = data.results;
			overview.summary = data.summary;
		        $scope.loading = false;
		});

		this.showOutdated = function(maintainer, onlyOutdated) {
			if (!onlyOutdated) {
				return true;
			} else if (maintainer.withnewdistfile > 0) {
				return true;
			} else {
				return false;
			}
		};

		this.stripEmail = function(maintainer) {
			return maintainer.replace(/\<.*?\>/g, '');
		};
	}]);

	app.controller('MaintainerController', ['$http', '$scope', function($http, $scope) {
		this.onlyOutdated = false;
		var maint = this;
		maint.ports = [];

	        $scope.loading = true;

		$scope.$watch("maintainer", function(){
			$http.get('./json/' + $scope.maintainer + '.json').success(function(data) {
				maint.ports = data;
			        $scope.loading = false;
			});
		});

		this.showOutdated = function(port, onlyOutdated) {
			if (!onlyOutdated) {
				return true;
			} else if (port.newver !== null) {
				return true;
			} else {
				return false;
			}
		};

		this.rowClass = function(newver) {
			var row;
			(newver === null) ? row = "resultsrow" : row = "resultsrowupdated";
			return row;
		};
	}]);

	app.controller('RestrictedController', ['$http', function($http) {
		var restricted = this;
		restricted.ports = [];

		$http.get('./json/restricted.json').success(function(data) {
			restricted.ports = data;
		});
	}]);
})();

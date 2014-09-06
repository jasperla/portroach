(function() {
	var app = angular.module('portroach', []);

	app.controller('OverviewController',['$http', function($http) {
		this.onlyOutdated = false;
		var overview = this;
		overview.maintainers = [];

		$http.get('./json/totals.json').success(function(data) {
			overview.maintainers = data;
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
			return maintainer.replace(/ \<.*\>$/, '');
		};
	}]);

	app.controller('MaintainerController', ['$http', '$scope', function($http, $scope) {
		this.onlyOutdated = false;
		var maint = this;
		maint.ports = [];

		$scope.$watch("maintainer", function(){
			$http.get('./json/' + $scope.maintainer + '.json').success(function(data) {
				maint.ports = data;
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

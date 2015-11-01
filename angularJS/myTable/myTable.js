angular.module('myApp', [])
.controller('MyController', ['$scope', function($scope){
  $scope.title = "my table";
  $scope.list = {
    columnsDef: [
      { field: "name", title: "Name", type: "text"    },
      { field: "age",  title: "Age",  type: "number"  },
      { field: "sex",  title: "Sex",  type: "text"    }
    ],
    data: [
      { name: "Robin",  age: 23,       sex: "male"     },
      { name: "Cathon", age: 22,       sex: "male"     },
      { name: "Mei",    age: 24,       sex: "female"   },
      { name: "Robin2", age: 23,       sex: "male"     },
      { name: "Cathon2",age: 22,       sex: "male"     },
      { name: "Mei2",   age: 24,       sex: "female"   },
      { name: "Robin3", age: 23,       sex: "male"     },
      { name: "Cathon3",age: 22,       sex: "male"     },
      { name: "Mei3",   age: 24,       sex: "female"   },
      { name: "Robin4", age: 23,       sex: "male"     },
      { name: "Cathon4",age: 22,       sex: "male"     },
      { name: "Mei4",   age: 24,       sex: "female"   },
    ]
  };
  $scope.tableConfig = {
    itemsPerPage : 4
  };
}])
.directive('myTable', function() {
  return {
    restrict: "EA",
    scope: {
      tableData: "=",
      items: "=ngModel",
      config: "=tableConfig"
    },
    transclude: true,
    template: '\
      <table>\
        <thead>\
          <tr class="">\
            <th></th>\
          </tr>\
        </thead>\
        <tbody ng-transclude></tbody>\
        <div>\
          <span class="page" ng-click="prevPage()"> << </span>\
            <span class="page" ng-repeat="n in range()" ng-class="{active: n == currentPage}" ng-click="setPage(n)"> {{n + 1}} </span>\
          <span class="page" ng-click="nextPage()"> >> </span>\
        </div>\
      </table>\
      ',
    controller: ['$scope', '$element', '$attrs', '$transclude', function($scope, $element, $attrs, $transclude) {
      $transclude(function(clone){});
      $scope.currentPage = 0;
      console.log($scope.tableData);

      $scope.getItems = function () {
        return $scope.tableData.data.slice($scope.currentPage * $scope.config.itemsPerPage, ($scope.currentPage + 1) * $scope.config.itemsPerPage);
      }
      $scope.items = $scope.getItems();
      console.log($scope.items);

      $scope.range = function () {
        var page = [];
        var pageNum = $scope.tableData.data.length / $scope.config.itemsPerPage;
        for(var i = 0; i < pageNum; i++) {
          page[i] = i;
        }
        return page;
      }

      $scope.nextPage = function () {
        if (!($scope.currentPage >= $scope.range().pop())) {
          $scope.setPage($scope.currentPage + 1);
        }
      }
      $scope.prevPage = function () {
        if (!($scope.currentPage <= 0)) {
          $scope.setPage($scope.currentPage - 1);
        }
      }
      $scope.setPage = function (n) {
        $scope.currentPage = n;
        $scope.items = $scope.getItems();
      }

    }],
  }
})

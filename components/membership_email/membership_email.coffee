angular.module('loomioApp').directive 'membershipEmail', (AbilityService) ->
  scope: {membership: '='}
  templateUrl: 'generated/components/membership_email/membership_email.html'
  controller: ($scope) ->
    $scope.canAdministerGroup = ->
      AbilityService.canAdministerGroup($scope.membership.group())

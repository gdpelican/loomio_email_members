angular.module('loomioApp').factory 'EmailMembersModal', ->
  templateUrl: 'generated/components/email_members_modal/email_members_modal.html'
  controller: ($scope, group) ->
    $scope.group = group.clone()

    $scope.$on '$close', $scope.$close

angular.module('loomioApp').directive 'emailMembersButton', (ModalService, EmailMembersModal) ->
  scope: {group: '='}
  templateUrl: 'generated/components/email_members_button/email_members_button.html'
  controller: ($scope) ->
    $scope.emailMembers = ->
      ModalService.open EmailMembersModal, group: -> $scope.group

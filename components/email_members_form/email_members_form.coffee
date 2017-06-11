angular.module('loomioApp').directive 'emailMembersForm', (Records, FormService) ->
  scope: {group: '='}
  templateUrl: 'generated/components/email_members_form/email_members_form.html'
  controller: ($scope) ->
    $scope.group.message = {}

    $scope.send = FormService.submit $scope, $scope.group,
      submitFn: (group) ->
        Records.groups.remote.postMember(group.key, 'email_members', message: group.message)
      successCallback: ->
        $scope.$emit '$close'
      flashSuccess: 'loomio_email_members.emails_sent'
      flashOptions: {count: $scope.group.membershipsCount - 1}

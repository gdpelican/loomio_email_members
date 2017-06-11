require_dependency 'plugins/loomio_email_members/app/serializers/user_with_email_serializer'

class MembershipWithEmailSerializer < MembershipSerializer
  has_one :user, serializer: UserWithEmailSerializer
end

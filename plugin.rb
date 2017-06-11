module Plugins
  module LoomioEmailMembers
    class Plugin < Plugins::Base
      setup! :loomio_email_members do |plugin|
        plugin.enabled = true

        plugin.use_component :membership_email, outlet: :after_membership_name
        plugin.use_component :email_members_button, outlet: :before_memberships_invite
        plugin.use_component :email_members_modal
        plugin.use_component :email_members_form

        plugin.use_class :"app/serializers/membership_with_email_serializer.rb"
        plugin.use_class :"app/serializers/user_with_email_serializer.rb"

        plugin.use_translations 'config/locales', :loomio_email_members

        plugin.use_route :post, "/groups/:id/email_members", "groups#email_members"

        plugin.extend_class API::GroupsController do
          def email_members
            service.email_members(group: load_resource, params: params.require(:message).permit(:subject, :body), actor: current_user)
            respond_with_resource
          end
        end

        plugin.extend_class GroupService do
          def self.email_members(group:, params:, actor:)
            actor.ability.authorize! :email_members, group

            params = params.merge(group_id: group.key)
            group.members.without(actor).each do |member|
              GroupMailer.delay(priority: 10).email_member(member, actor, params)
            end
            EventBus.broadcast 'group_email_members', group, actor
          end
        end

        plugin.extend_class GroupMailer do
          prepend_view_path Rails.root.join('plugins', 'loomio_email_members', 'app', 'views')

          def email_member(recipient, sender, params = {})
            @recipient = recipient
            @sender    = sender
            @group     = Group.find(params[:group_id])
            @body      = params[:body]
            send_single_mail to: recipient.name_and_email,
                             subject_key: "loomio_email_members.email_subject",
                             subject_params: {group: @group.full_name, subject: params[:subject]},
                             locale: locale_for(@recipient)
          end
        end

        plugin.extend_class API::MembershipsController do
          require_dependency 'plugins/loomio_email_members/app/serializers/membership_with_email_serializer'

          private

          def resource_serializer
            if action_name == 'index' && coordinator_of_paid_group?
              MembershipWithEmailSerializer
            else
              MembershipSerializer
            end
          end

          def coordinator_of_paid_group?
            @group.subscription_kind == 'paid' && current_user.is_admin_of?(@group)
          end
        end
      end
    end
  end
end

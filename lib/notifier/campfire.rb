require 'rubygems'
require 'integrity'
require 'tinder'

module Integrity
  class Notifier
    class Campfire < Notifier::Base
      attr_reader :config

      def self.to_haml
        File.read File.dirname(__FILE__) / "config.haml"
      end

      def deliver!
        room.speak "#{short_message}. #{commit_url}"
        room.paste full_message if commit.failed?
      end

    private
      def room
        @room ||= begin
          campfire = Tinder::Campfire.new(config['account'])
          campfire.login(config['user'], config['pass'])
          campfire.find_room_by_name(config['room'])
        end
      end

      def short_message
        "Build #{commit.short_commit_identifier} of #{commit.project.name} #{commit.successful? ? "was successful" : "failed"}"
      end

      def full_message
        <<-EOM
Commit Message: #{commit.commit_message}
Commit Date: #{commit.commited_at}
Commit Author: #{commit.commit_author.name}

#{stripped_build_output}
EOM
      end
    end
  end
end



module Ruboty
  module Handlers
    class Attendance < Base
      on( /(?<name>.+) 出社/, name: "come_to_the_office", description: "<name> just got to work.")

      env :START_OF_OFFICE_HOURS, "The start of office hours. e.g. 9:30", optional: true
      private

      def come_to_the_office(message)
        now = Time.now
        limit = Time.local(
          now.year,
          now.month,
          now.day,
          start_of_office_hours[0],
          start_of_office_hours[1],
          00
        )
        now < limit ? success(message) : faild(message)
      end

      def faild(message)
        name = message[:name]
        message.reply("Login mission failed!\n今度はがんばりましょう")
        message.reply("#{name}--")
      end

      def success(message)
        name = message[:name]
        message.reply("Login mission success!")
        message.reply("#{name}++")
      end

      def start_of_office_hours
        ENV["START_OF_OFFICE_HOURS"].split(":").map(&:to_i)
      end
    end
  end
end

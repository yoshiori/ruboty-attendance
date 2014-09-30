

module Ruboty
  module Handlers
    class Attendance < Base
      NAMESPACE = "attendance"

      on( /(?<name>.+) 出社/, name: "come_to_the_office", description: "<name> just got to work.")

      env :START_OF_OFFICE_HOURS, "The start of office hours. e.g. 9:30", optional: true

      private

      def come_to_the_office(message)
        name = message[:name]
        if check_duplicate(name)
          duplicate(message)
          return
        end
        check_limit ? success(name, message) : failure(name, message)
      end

      def check_duplicate(name)
        last_time = scores[name]
        return false unless last_time
        now = Time.now
        last = Time.at(last_time)
        now.year == last.year &&
        now.month == last.month &&
        now.day == last.day
      end

      def check_limit
        now = Time.now
        limit = Time.local(
          now.year,
          now.month,
          now.day,
          start_of_office_hours[0],
          start_of_office_hours[1],
          00
        )
        now <= limit
      end

      def duplicate(message)
        message.reply("Duplicate login!")
        message.reply("#{robot.name} zoi ごはんにする")
      end

      def failure(name, message)
        scores[name] = Time.now.to_i
        message.reply("Login mission failure!\n今度はがんばりましょう")
        message.reply("#{name}--")
      end

      def success(name, message)
        scores[name] = Time.now.to_i
        message.reply("Login mission success!")
        message.reply("#{name}++")
      end

      def start_of_office_hours
        ENV["START_OF_OFFICE_HOURS"].split(":").map(&:to_i)
      end

      def scores
        robot.brain.data[NAMESPACE] ||= {}
      end
    end
  end
end

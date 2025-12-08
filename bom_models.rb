class Scheduler < Sequel::Model
  one_to_many :schedules
end

class Proposal < Sequel::Model
  one_to_many :interest
  one_to_one :schedule
end

class Interest < Sequel::Model
  many_to_one :proposal
end

class Schedule < Sequel::Model
  one_to_one :proposal
  many_to_one :scheduler
  many_to_one :room
end

class Room < Sequel::Model
  one_to_many :schedules
end

class Mail < Sequel::Model
end

class Text < Sequel::Model
end

class ApiKey < Sequel::Model
  def masked_key
    masked_key = self.key.dup
    masked_key[0..-6] = '*' * (masked_key.length-5)

    masked_key
  end

  def access_level_text
    case self.access_level
      when 0
        "View Only"
      when 5
        "Public Access"
      when 10
        "Scheduler Access"
      else
        "Unknown/Invalid"
    end
  end
end

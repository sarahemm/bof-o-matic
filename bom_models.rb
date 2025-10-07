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

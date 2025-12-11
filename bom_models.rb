class Scheduler < Sequel::Model
  one_to_many :schedules
end

class Proposal < Sequel::Model
  one_to_many :interest
  one_to_one :schedule

  def to_hash(include_scheduler_fields: false)
    out = {}

    out = {
      title: self.title,
      description: self.description,
      submitted_by: self.submitted_by,
      submitted_at: self.submitted_at
    }

    out[:interest] = self.interest.map {|i| [i[:id], i.to_hash.except(:id, :proposal_id)]}.to_h

    # if it's scheduled already, add some info about that
    if(self.schedule) then
      out.merge!({
        scheduled: true,
        start_time: self.schedule.start_time,
        room: self.schedule.room.room_name
      })
    else
      out[:scheduled] = false
    end

    # schedulers get some extra fields too
    if(include_scheduler_fields) then
      out.merge!({
        submitter_email: self.submitter_email,
        submitter_phone: self.submitter_phone,
        scheduler_notes: self.scheduler_notes,
        scheduling_token: self.scheduling_token,
        sent_to_schedulers: self.sent_to_schedulers
      })
      if(self.schedule) then
        out[:scheduled_at] = self.schedule.scheduled_at
        out[:scheduled_by] = self.schedule.scheduled_by
      end
    end

    out
  end
end

class Interest < Sequel::Model
  many_to_one :proposal

  def to_hash(include_scheduler_fields: false)
    out = {}

    out = {
      proposal_id: self.proposal_id,
      name: self.name,
      submitted_at: self.submitted_at
    }

    if(include_scheduler_fields) then
      out.merge!({
        email: self.email,
        phone: self.phone,
      })
    end

    out
  end
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

  def level_is_at_least(required_level)
    required_level = 0 if required_level == :view_only
    required_level = 5 if required_level == :public
    required_level = 10 if required_level == :scheduler

    self.access_level >= required_level
  end
end

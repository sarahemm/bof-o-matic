require 'erb'

def queue_emails_when_scheduled(proposal_id)
  proposal = Proposal
    .association_join(schedule: :room)
    .select(Sequel[:proposals][:id], :title, :description, :submitted_by, :submitter_email, :scheduled_by, :start_time, :room_name, Sequel[:room][:id].as(:room_id))
    .where(Sequel[:proposals][:id] => proposal_id).first

  interests = Interest.where(proposal_id: proposal_id)
  interested = interests.map(:name)

  subject = "Your BoF '#{proposal[:title]}' has been scheduled!"
  proposer_tmpl = ERB.new(File.read('email-templates/scheduled-to_proposer.erb'))
  
  mail = Mail.new(
    to_address: proposal[:submitter_email],
    subject: subject,
    body: proposer_tmpl.result(binding)
  )
  mail.save

  # queue up mail for each interested person, too
  interest_tmpl = ERB.new(File.read('email-templates/scheduled-to_interests.erb'))
  interests.each do |interest|
    next unless interest[:email] and interest[:email] != ''
    subject = "BoF '#{proposal[:title]}' has been scheduled!"

    mail = Mail.new(
      to_address: interest[:email],
      subject: subject,
      body: interest_tmpl.result(binding)
    )
    mail.save
  end
end

def queue_emails_when_unscheduled(proposal_id, unscheduled_by)
  proposal = Proposal[proposal_id]

  interests = Interest.where(proposal_id: proposal_id)
  interested = interests.map(:name)

  subject = "Your BoF '#{proposal[:title]}' has been removed from the schedule"
  proposer_tmpl = ERB.new(File.read('email-templates/unscheduled-to_proposer.erb'))

  mail = Mail.new(
    to_address: proposal[:submitter_email],
    subject: subject,
    body: proposer_tmpl.result(binding)
  )
  mail.save

  # queue up mail for each interested person, too
  interest_tmpl = ERB.new(File.read('email-templates/unscheduled-to_interests.erb'))
  interests.each do |interest|
    next unless interest[:email] and interest[:email] != ''
    subject = "BoF '#{proposal[:title]}' has been removed from the schedule"

    mail = Mail.new(
      to_address: interest[:email],
      subject: subject,
      body: interest_tmpl.result(binding)
    )
    mail.save
  end
end

def queue_interest_emails(proposal_id)
  proposal = Proposal[proposal_id]
  interests = Interest.where(proposal_id: proposal_id)
  interested = interests.map(:name)

  subject = "The BoF '#{proposal[:title]}' has reached enough interest to be scheduled"
  tmpl = ERB.new(File.read('email-templates/interest-to_schedulers.erb'))

  Scheduler.exclude(email: nil).each do |scheduler|
    mail = Mail.new(
      to_address: scheduler.email,
      subject: subject,
      body: tmpl.result(binding)
    )
    mail.save
  end
end

def queue_reminder_emails(proposal_id, reminder_minutes)
  proposal = Proposal
    .association_join(schedule: :room)
    .select(Sequel[:proposals][:id], :title, :description, :submitted_by, :submitter_email, :scheduled_by, :start_time, :room_name, Sequel[:room][:id].as(:room_id))
    .where(Sequel[:proposals][:id] => proposal_id).first

  interests = Interest.where(proposal_id: proposal_id)
  interested = interests.map(:name)

  subject = "Your BoF '#{proposal[:title]}' is starting soon!"
  proposer_tmpl = ERB.new(File.read('email-templates/reminder-to_proposer.erb'))

  mail = Mail.new(
    to_address: proposal[:submitter_email],
    subject: subject,
    body: proposer_tmpl.result(binding)
  )
  mail.save

  # queue up mail for each interested person, too
  interest_tmpl = ERB.new(File.read('email-templates/reminder-to_interests.erb'))
  interests.each do |interest|
    next unless interest[:email] and interest[:email] != ''
    subject = "BoF '#{proposal[:title]}' is starting soon!"

    mail = Mail.new(
      to_address: interest[:email],
      subject: subject,
      body: interest_tmpl.result(binding)
    )
    mail.save
  end
end

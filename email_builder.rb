# TODO: this should be email_and_text_builder or something now, really.
# TODO: there's also a lot of repetitive code, this could use refactoring
#       to DRY it out a bunch

require 'erb'
require 'add_to_calendar'

def queue_emails_when_scheduled(proposal_id)
  proposal = Proposal
    .association_join(schedule: :room)
    .select(Sequel[:proposals][:id], :title, :description, :submitted_by, :submitter_email, :submitter_phone, :scheduled_by, :start_time, :room_name, Sequel[:room][:id].as(:room_id))
    .where(Sequel[:proposals][:id] => proposal_id).first

  interests = Interest.where(proposal_id: proposal_id)
  interested = interests.map(:name)
  
  if(proposal[:submitter_email]) then
    subject = "Your BoF '#{proposal[:title]}' has been scheduled!"
  
    proposer_tmpl = ERB.new(File.read('email-templates/scheduled-to_proposer.erb'))
    proposer_html_tmpl = ERB.new(File.read('email-templates/scheduled-to_proposer.html.erb'))
  
    calendar_links = AddToCalendar::URLs.new(
      # TODO: add end time too
      start_datetime: proposal[:start_time],
      title: proposal[:title],
      location: proposal[:room_name],
      # TODO: this should live in a config file, do as part of timezone work
      timezone: 'America/Los_Angeles'
    )
  
    # add_to_calendar can only generate a data link, not raw ics, so we unescape it
    # and reformat it a bit to get a file-formatted one. kind of a dirty hack but
    # it avoids needing yet another dependency just for this one thing.
    ics_file = CGI.unescape(calendar_links.ical_url.split(',', 2)[1])

    # add the HTML part, reformat links, etc.
    body = format_multipart([
      {type: 'text/plain', body: proposer_tmpl.result(binding)},
      {type: 'text/html', body: proposer_html_tmpl.result(binding)},
      {type: 'text/calendar', filename: "bof-#{proposal_id}.ics", body: ics_file}
    ])
  
    mail = Mail.new(
      to_address: proposal[:submitter_email],
      subject: subject,
      body: body
    )
    mail.save
  end

  if(proposal[:submitter_phone]) then
    text_tmpl = ERB.new(File.read('sms-templates/scheduled-to_proposer.erb'))

    text = Text.new(
      to_phone: proposal[:submitter_phone],
      body: text_tmpl.result(binding)
    )
    text.save
  end

  # queue up mail for each interested person, too
  interest_tmpl = ERB.new(File.read('email-templates/scheduled-to_interests.erb'))
  interest_html_tmpl = ERB.new(File.read('email-templates/scheduled-to_interests.html.erb'))
  
  # add the HTML part, reformat links, etc.
  body = format_multipart([
    {type: 'text/plain', body: interest_tmpl.result(binding)},
    {type: 'text/html', body: interest_html_tmpl.result(binding)},
    {type: 'text/calendar', filename: "bof-#{proposal_id}.ics", body: ics_file}
  ])

  interests.each do |interest|
    if(interest[:email] and interest[:email] != '') then
      subject = "BoF '#{proposal[:title]}' has been scheduled!"
  
      mail = Mail.new(
        to_address: interest[:email],
        subject: subject,
        body: body
      )
      mail.save
    end

    if(interest[:phone] and interest[:phone] != '') then
      text_tmpl = ERB.new(File.read('sms-templates/scheduled-to_interests.erb'))
      text = Text.new(
        to_phone: interest[:phone],
        body: text_tmpl.result(binding)
      )
      text.save
    end
  end
end

def queue_emails_when_unscheduled(proposal_id, unscheduled_by)
  proposal = Proposal[proposal_id]

  interests = Interest.where(proposal_id: proposal_id)
  interested = interests.map(:name)

  
  if(proposal[:submitter_email]) then
    subject = "Your BoF '#{proposal[:title]}' has been removed from the schedule"
    proposer_tmpl = ERB.new(File.read('email-templates/unscheduled-to_proposer.erb'))
    mail = Mail.new(
      to_address: proposal[:submitter_email],
      subject: subject,
      body: proposer_tmpl.result(binding)
    )
    mail.save
  end

  if(proposal[:submitter_phone]) then
    text_tmpl = ERB.new(File.read('sms-templates/unscheduled-to_proposer.erb'))

    text = Text.new(
      to_phone: proposal[:submitter_phone],
      body: text_tmpl.result(binding)
    )
    text.save
  end

  # queue up mail for each interested person, too
  interest_tmpl = ERB.new(File.read('email-templates/unscheduled-to_interests.erb'))
  interests.each do |interest|
    if(interest[:email] and interest[:email] != '') then
      subject = "BoF '#{proposal[:title]}' has been removed from the schedule"

      mail = Mail.new(
        to_address: interest[:email],
        subject: subject,
        body: interest_tmpl.result(binding)
      )
      mail.save
    end
    
    if(interest[:phone] and interest[:phone] != '') then
      text_tmpl = ERB.new(File.read('sms-templates/unscheduled-to_interests.erb'))
      text = Text.new(
        to_phone: interest[:phone],
        body: text_tmpl.result(binding)
      )
      text.save
    end
  end
end

def queue_interest_email_to_proposer(proposal_id, selfschedule_delay)
  proposal = Proposal[proposal_id]

  interests = Interest.where(proposal_id: proposal_id)
  interested = interests.map(:name)

  token = File.readlines("token-words.txt").sample(3).map {|t| t.strip}.join(" ")
  proposal.scheduling_token = token
  proposal.save

  if(proposal[:submitter_email]) then
    subject = "The BoF '#{proposal[:title]}' has reached enough interest to be scheduled"
    tmpl = ERB.new(File.read('email-templates/interest-to_proposer.erb'))

    mail = Mail.new(
      to_address: proposal.submitter_email,
      subject: subject,
      body: tmpl.result(binding)
    )
    mail.save
  end

  if(proposal[:submitter_phone]) then
    text_tmpl = ERB.new(File.read('sms-templates/interest-to_proposer.erb'))

    text = Text.new(
      to_phone: proposal[:submitter_phone],
      body: text_tmpl.result(binding)
    )
    text.save
  end

end

def queue_interest_emails_to_schedulers(proposal_id)
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

  if(proposal[:submitter_email]) then
    subject = "Your BoF '#{proposal[:title]}' is starting soon!"
    proposer_tmpl = ERB.new(File.read('email-templates/reminder-to_proposer.erb'))

    mail = Mail.new(
      to_address: proposal[:submitter_email],
      subject: subject,
      body: proposer_tmpl.result(binding)
    )
    mail.save
  end
  
  if(proposal[:submitter_phone]) then
    text_tmpl = ERB.new(File.read('sms-templates/reminder-to_proposer.erb'))

    text = Text.new(
      to_phone: proposal[:submitter_phone],
      body: text_tmpl.result(binding)
    )
    text.save
  end


  # queue up mail for each interested person, too
  interest_tmpl = ERB.new(File.read('email-templates/reminder-to_interests.erb'))
  interests.each do |interest|
    if(interest[:email] and interest[:email] != '') then
      subject = "BoF '#{proposal[:title]}' is starting soon!"

      mail = Mail.new(
        to_address: interest[:email],
        subject: subject,
        body: interest_tmpl.result(binding)
      )
      mail.save
    end
    
    if(interest[:phone] and interest[:phone] != '') then
      text_tmpl = ERB.new(File.read('sms-templates/reminder-to_interests.erb'))
      text = Text.new(
        to_phone: interest[:phone],
        body: text_tmpl.result(binding)
      )
      text.save
    end
  end
end

def format_multipart(parts)
  mp_body = ""
  parts.each do |part|
    disposition = 'inline'
    name = ''
    if(part[:filename]) then
      disposition = "attachment; filename=\"#{part[:filename]}\""
      name = "; name=\"#{part[:filename]}\""
    end
    mp_body += <<~EOF
      --boundary-string
      Content-Type: #{part[:type]}; charset="utf-8"#{name}
      Content-Transfer-Encoding: 7BIT
      Content-Disposition: #{disposition}
      
      #{part[:body]}
    EOF
  end
  mp_body += "--boundary-string--"

  return mp_body
end


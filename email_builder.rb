require 'prawn'

# gienerate a PDF in the spool directory for a given proposal
def queue_emails_when_scheduled(proposal_id)
  proposal = Proposal
    .association_join(schedule: :room)
    .select(Sequel[:proposals][:id], :title, :description, :submitted_by, :submitter_email, :scheduled_by, :start_time, :room_name, Sequel[:room][:id].as(:room_id))
    .where(Sequel[:proposals][:id] => proposal_id).first

  interests = Interest.where(proposal_id: proposal_id)

  subject = "Your BoF '#{proposal[:title]}' has been scheduled!"
  email_text = <<~EOF
    Your proposed BoF "#{proposal[:title]}" has been scheduled! This session will be taking place on #{proposal[:start_time].strftime("%A at %H:%M")} in #{proposal[:room_name]}.
    
    The following attendees have expressed interest in this session:
     - #{interests.map(:name).join("\n - ")}
    
    If you have any questions or need something changed please reach out to #{proposal[:scheduled_by]}, the scheduler who processed this session.
    
    Thanks!
     - BoF Team
  EOF
  
  mail = Mail.new(
    to_address: proposal[:submitter_email],
    subject: subject,
    body: email_text
  )
  mail.save

  # queue up mail for each interested person, too
  interests.each do |interest|
    next unless interest[:email] and interest[:email] != ''
    subject = "BoF '#{proposal[:title]}' has been scheduled!"
    email_text = <<~EOF
      A BoF you expressed interest in, "#{proposal[:title]}", has been scheduled! This session will be taking place on #{proposal[:start_time].strftime("%A at %H:%M")} in #{proposal[:room_name]}.
      
      If you have any questions please reach out to the one who submitted this session proposal, #{proposal[:submitted_by]}.
      
      Thanks!
      - BoF Team
    EOF

    mail = Mail.new(
      to_address: interest[:email],
      subject: subject,
      body: email_text
    )
    mail.save
  end
end



require 'prawn'

# gienerate a PDF in the spool directory for a given proposal
def queue_emails_when_scheduled(proposal_id)
  proposal = Proposal
    .association_join(schedule: :room)
    .select(Sequel[:proposals][:id], :title, :description, :submitted_by, :submitter_email, :scheduled_by, :start_time, :room_name, Sequel[:room][:id].as(:room_id))
    .where(Sequel[:proposals][:id] => proposal_id).first

  interest = Interest.where(proposal_id: proposal_id)

  subject = "Your BoF '#{proposal[:title]}' has been scheduled!"
  email_text = <<~EOF
    Your proposed BoF "#{proposal[:title]}" has been scheduled! This session will be taking place on #{proposal[:start_time].strftime("%A at %H:%M")} in #{proposal[:room_name]}.
    
    The following attendees have expressed interest in this session:
     - #{interest.map(:name).join("\n - ")}
    
    If you have any questions or need something changed please reach out #{proposal[:scheduled_by]}, who is the scheduler who processed this session.
    
    Thanks!
     - BoF Team
  EOF
  
  mail = Mail.new(
    to_address: proposal[:submitter_email],
    subject: subject,
    body: email_text
  )
  mail.save

  # TODO: queue mails to each interested party, too
end



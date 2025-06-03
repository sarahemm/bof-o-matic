require 'prawn'

# generate a PDF in the spool directory for a given proposal
def generate_pdf(proposal_id)
  proposal = Proposal
    .association_join(schedule: :room)
    .select(Sequel[:proposals][:id], :title, :description, :submitted_by, :start_time, :room_name, Sequel[:room][:id].as(:room_id))
    .where(Sequel[:proposals][:id] => proposal_id).first

  interest = Interest.where(proposal_id: proposal_id)

  # hide warnings about i18n, which using non-breaking spaces triggers
  Prawn::Fonts::AFM.hide_m17n_warning = true

  Prawn::Document.generate("pdf-spool/#{Time.now.to_i.to_s}-proposal#{proposal_id}.pdf", page_layout: :landscape) do
    # title
    font_size 72
    text_box proposal[:title], at: [0, 72*7.5], height: 50, width: 72*10, overflow: :shrink_to_fit, disable_wrap_by_char: true, align: :center

    # when and where
    font_size 28
    text_box "#{proposal[:start_time].strftime("%A at %H:%M")} in #{proposal[:room_name]}", at: [0, 72*6.5], height: 72*1, width: 72*10, overflow: :shrink_to_fit, align: :center

    # description
    font_size 24
    text_box proposal[:description], at: [0, 72*5.5], height: 72*1, width: 72*10, overflow: :shrink_to_fit, align: :center

    # who proposed it, and a list of people who are interested
    font_size 18
    text_box "Proposed by: #{proposal[:submitted_by]}\n\nInterest registered by:\n#{Prawn::Text::NBSP * 4}- #{interest.map(:name).join("\n#{Prawn::Text::NBSP * 4}- ")}", at: [0, 72*4.5], height: 72*4, width: 72*10, overflow: :shrink_to_fit
  end
end


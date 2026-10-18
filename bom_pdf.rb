require 'prawn'

# extend the Proposal class to add generation of PDFs
class Proposal
  # generate a PDF and save it to a file, if no filename passed then generates a standard spool filename
  def to_pdf(filename:, font:)
    # hide warnings about i18n, which using non-breaking spaces triggers
    Prawn::Fonts::AFM.hide_m17n_warning = true

    proposal = self
    Prawn::Document.generate(filename, page_layout: :landscape) do
      # set up external fonts so that we can render non-ASCII characters (if specified)
      if(font) then
        font_families.update(
          'label' => {
            normal: font
          }
        )

        font 'label'
      end

      # title
      font_size 72
      text_box proposal[:title], at: [0, 72*7.5], height: 50, width: 72*10, overflow: :shrink_to_fit, disable_wrap_by_char: true, align: :center

      # when and where
      font_size 28
      when_where = "PROPOSAL"
      when_where = "#{proposal.schedule[:start_time].strftime("%A at %H:%M")} in #{proposal.schedule.room[:room_name]}" if proposal.schedule
      text_box when_where, at: [0, 72*6.5], height: 72*1, width: 72*10, overflow: :shrink_to_fit, align: :center

      # description
      font_size 24
      text_box proposal[:description], at: [0, 72*5.5], height: 72*1, width: 72*10, overflow: :shrink_to_fit, align: :center

      # who proposed it, and a list of people who are interested
      font_size 18
      text_box "Proposed by: #{proposal[:submitted_by]}\n\nInterest registered by:\n#{Prawn::Text::NBSP * 4}- #{proposal.interest.map() {|i| i[:name]}.join("\n#{Prawn::Text::NBSP * 4}- ")}", at: [0, 72*4.5], height: 72*4, width: 72*10, overflow: :shrink_to_fit
    end
  end
end


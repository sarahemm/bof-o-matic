require 'rmagick'

def text_fit?(text, font, pointsize, width)
  tmp_image = Magick::Image.new(width, 500)
  drawing = Magick::Draw.new
  drawing.annotate(tmp_image, 0, 0, 0, 0, text) { |txt|
    txt.gravity = Magick::NorthGravity
    txt.pointsize = pointsize
    txt.font = font
    txt.fill = "#ffffff"
    txt.font_weight = Magick::BoldWeight
  }
  metrics = drawing.get_multiline_type_metrics(tmp_image, text)
  pp metrics.width, width
  (metrics.width < width)
end

# TODO: this could be cleaned up a bunch
def fit_text(text, font, pointsize, width)
  separator = ' '
  line = ''
  
  if not text_fit?(text, font, pointsize, width) and text.include? separator
    i = 0
    text.split(separator).each do |word|
      if i == 0
        tmp_line = line + word
      else
        tmp_line = line + separator + word
      end

      if text_fit?(tmp_line, font, pointsize, width)
        unless i == 0
          line += separator
        end
        line += word
      else
        unless i == 0
          line +=  '\n'
        end
        line += word
      end
      i += 1
    end
    text = line
  end
  text
end

# generate a PNG label in the spool directory for a given proposal
def generate_png(proposal_id, settings)
  proposal = Proposal
    .association_join(schedule: :room)
    .select(Sequel[:proposals][:id], :title, :description, :submitted_by, :start_time, :room_name, Sequel[:room][:id].as(:room_id))
    .where(Sequel[:proposals][:id] => proposal_id).first

  img = Magick::Image.new(settings.png_width, settings.png_height)
  draw = Magick::Draw.new
  draw.interline_spacing = 20
  draw.font = settings.png_font
  draw.pointsize = 1024
  size = 1024
  time = "#{proposal[:start_time].strftime("%a %H:%M")} - #{proposal[:room_name]}"
  title = proposal[:title]
  if(title.length > 25) then
    # split long titles roughly in half on two lines
    # TODO: this is inaccurate when some words are longer than others
    halfway = title.split(' ').length/2
    title = [title.split(' ')[0..halfway-1], "\n", title.split(' ')[halfway..-1]].join(" ")
  end
  desc = fit_text(proposal[:description], settings.png_font, 48, settings.png_width/2)

  # figure out the largest size font that will fit in the space we have
  metrics = draw.get_multiline_type_metrics(title)
  while(metrics.width > settings.png_width-50 or metrics.height > settings.png_height-100) do
    size -= 5
    draw.pointsize = size
    metrics = draw.get_multiline_type_metrics(title)
  end

  # draw the title centered near the top
  img.annotate(draw, settings.png_width-25, settings.png_height, 0, 25, title) do
    draw.gravity = Magick::NorthGravity
    draw.fill = "#000000#"
    draw.font_weight = Magick::BoldWeight
  end

  # draw the description in the lower left
  img.annotate(draw, settings.png_width, settings.png_height-25, 25, 0, desc) do
    draw.gravity = Magick::SouthWestGravity
    draw.pointsize = 48
    draw.fill = "#000000#"
    draw.font_weight = Magick::BoldWeight
  end
  
  # draw the time it should be added to in the lower right
  img.annotate(draw, settings.png_width, settings.png_height-25, 25, 0, time) do
    draw.gravity = Magick::SouthEastGravity
    draw.pointsize = 64
    draw.fill = "#000000#"
    draw.font_weight = Magick::BoldWeight
  end

  # draw the proposal ID in the upper right
  img.annotate(draw, settings.png_width-25, settings.png_height, 0, 25, proposal[:id].to_s) do
    draw.gravity = Magick::NorthEastGravity
    draw.pointsize = 24
    draw.fill = "#000000#"
  end

  #img.format = "png"
  img.write("png-spool/#{Time.now.to_i.to_s}-proposal#{proposal[:id]}.png")
end


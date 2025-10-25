require 'rmagick'

def split_title(title, chunks)
  # we can't split into more chunks than there are spaces, so clamp the chunks to that number
  chunks = title.count(' ') + 1 if title.count(' ') < chunks

  return title if chunks == 0  # we can't split at all if we have no spaces

  ideal_chunk_len = title.length/chunks
  split_positions = []
  (1..chunks-1).each do |chunk_nbr|
      ideal_split_pos = ideal_chunk_len * chunk_nbr
      # search forward from the split for the first space
      forward_space = title[ideal_split_pos..-1].index(' ') + ideal_split_pos if title[ideal_split_pos..-1].index(' ')
      # and search backwards to see if there's a closer one there
      backward_space = title[0..ideal_split_pos].rindex(' ') if title[0..ideal_split_pos].rindex(' ')
      nearest_space = nil
      if(forward_space == nil) then
        nearest_space = backward_space
      elsif(backward_space == nil) then
        nearest_space = forward_space
      else
        nearest_space = (forward_space - ideal_split_pos > ideal_split_pos - backward_space) ? backward_space : forward_space
      end
      split_positions << nearest_space
  end

  split_title = +title
  split_positions.each do |split_pos|
      split_title[split_pos] = "\n"
  end

  return split_title
end

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
  if(title.length > 40) then
    # split extra-long titles roughly in thirds
    title = split_title(title, 3)
  elsif(title.length > 20) then
    # split long titles roughly in half on two lines
    title = split_title(title, 2)
  end
  # figure out the largest size font that will fit in the space we have for the title
  metrics = draw.get_multiline_type_metrics(title)
  while(metrics.width > settings.png_width-50 or metrics.height > settings.png_height-100) do
    size -= 5
    draw.pointsize = size
    metrics = draw.get_multiline_type_metrics(title)
  end

  # draw the title centered near the top
  img.annotate(draw, settings.png_width-25, settings.png_height*0.8, 0, 25, title) do
    draw.gravity = Magick::NorthGravity
    draw.fill = "#000000#"
    draw.font_weight = Magick::BoldWeight
  end

  # draw the description in the lower left
  desc = fit_text(proposal[:description], settings.png_font, settings.png_width*0.02, settings.png_width/2)
  img.annotate(draw, settings.png_width, settings.png_height-25, 25, 0, desc) do
    draw.gravity = Magick::SouthWestGravity
    draw.pointsize = settings.png_width*0.02
    draw.fill = "#000000#"
    draw.font_weight = Magick::BoldWeight
  end
  
  # draw the time it should be added to in the lower right
  # along with the URL
  url = "#{settings.base_url}/#{settings.use_short_urls ? '' : 'proposals/'}#{proposal_id}"
  time = "#{url}\n#{time}"
  img.annotate(draw, settings.png_width, settings.png_height-25, 25, 0, time) do
    draw.gravity = Magick::SouthEastGravity
    draw.pointsize = settings.png_width*0.03
    draw.fill = "#000000#"
    draw.font_weight = Magick::BoldWeight
  end

  img.write("png-spool/#{Time.now.to_i.to_s}-proposal#{proposal[:id]}.png")
end


require 'rmagick'

# extend the Proposal class to generate PNGs for printing labels
class Proposal
  # generate a PNG label in the spool directory for a given proposal
  # TODO: having to pass settings here is awkward, see if there's a better way
  def to_label_png(settings:, filename:)
    img = Magick::Image.new(settings.png_width, settings.png_height)
    draw = Magick::Draw.new
    draw.interline_spacing = 20
    draw.font = settings.png_font
    draw.pointsize = 1024
    size = 1024
    time = "#{self.schedule[:start_time].strftime("%a %H:%M")} - #{self.schedule.room[:room_name]}"

    title = self[:title]
    if(title.length > 40) then
      # split extra-long titles roughly in thirds
      title = BomPngHelpers::split_title(title, 3)
    elsif(title.length > 20) then
      # split long titles roughly in half on two lines
      title = BomPngHelpers::split_title(title, 2)
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
    desc = BomPngHelpers::fit_text(self[:description], settings.png_font, settings.png_width*0.04, settings.png_width/2)
    img.annotate(draw, settings.png_width, settings.png_height-25, 25, 0, desc) do
      draw.gravity = Magick::SouthWestGravity
      draw.pointsize = settings.png_width*0.04
      draw.fill = "#000000#"
      draw.font_weight = Magick::BoldWeight
    end
  
    # draw the time it should be added to in the lower right
    # along with the URL
    url = "#{settings.base_url}/#{settings.use_short_urls ? '' : 'proposals/'}#{self[:id]}"
    time = "#{url}\n#{time}"
    img.annotate(draw, settings.png_width, settings.png_height-25, 25, 0, time) do
      draw.gravity = Magick::SouthEastGravity
      draw.pointsize = settings.png_width*0.03
      draw.fill = "#000000#"
      draw.font_weight = Magick::BoldWeight
    end

    img.write filename
  end

  # generate a PNG label in the spool directory for a given cancellation
  # needs to be called before the cancellation is processed, so that it still has access to room/time!
  def to_cancel_label_png(settings:, filename:)
    img = Magick::Image.new(settings.png_width, settings.png_height)
    draw = Magick::Draw.new
    draw.interline_spacing = 20
    draw.font = settings.png_font
    draw.pointsize = 1024

    # draw the cancelled title in the lower left
    desc = BomPngHelpers::fit_text("Removed from schedule: #{self[:title]}", settings.png_font, settings.png_width*0.04, settings.png_width/2)
    img.annotate(draw, settings.png_width, settings.png_height-25, 25, 0, desc) do
      draw.gravity = Magick::SouthWestGravity
      draw.pointsize = settings.png_width*0.04
      draw.fill = "#000000#"
      draw.font_weight = Magick::BoldWeight
    end

    # draw the time it should be added to in the lower right
    # along with the URL
    time = "#{self.schedule[:start_time].strftime("%a %H:%M")} - #{self.schedule.room[:room_name]}"
    img.annotate(draw, settings.png_width, settings.png_height-25, 25, 0, time) do
      draw.gravity = Magick::SouthEastGravity
      draw.pointsize = settings.png_width*0.03
      draw.fill = "#000000#"
      draw.font_weight = Magick::BoldWeight
    end

    img.write filename
  end
end

class BomPngHelpers
  def self.split_title(title, chunks)
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

  def self.fit_text(text, font, pointsize, width)
    separator = ' '
    text_block = ''

    if not text_fits?(text, font, pointsize, width) and text.include? separator
      word_idx = 0
      text.split(separator).each do |word|
        # build the proposed next line, including a separator if required
        tmp_block = text_block + (word_idx != 0 ? separator : '') + word

        if text_fits?(tmp_block, font, pointsize, width)
          # the proposed text fits, add it
          text_block += separator unless word_idx == 0
          text_block += word
        else
          # this line is full, bump down to the next one then add the next word
          text_block +=  '\n' unless word_idx == 0
          text_block += word
        end
        word_idx += 1
      end
      text = text_block
    end

    text
  end

  private

  def self.text_fits?(text, font, pointsize, width)
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
end

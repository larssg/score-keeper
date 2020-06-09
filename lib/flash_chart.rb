# frozen_string_literal: true

class FlashChart
  def initialize
    @data = []
    @x_labels = []
    @y_min = 0
    @y_max = 20
    @y_steps = 5
    @title = ''
    @title_size = 30
    @x_tick_size = -1
    # Grid styles
    @x_axis_colour = '#808080'
    @x_grid_colour = '#dddddd'
    @y_axis_colour = '#808080'
    @y_grid_colour = '#dddddd'
    @x_axis_steps = 1
    # Axis label styles
    @x_label_style_size = -1
    @x_label_style_colour = '#000000'
    @x_label_style_orientation = 0
    @x_label_style_step = 1
    @y_label_style = ''
    # Axis legend styles
    @x_legend = ''
    @x_legend_size = 20
    @x_legend_colour = '#000000'
    @y_legend = ''
    @y_legend_size = 20
    @y_legend_colour = '#000000'
    @lines = []
    @line_default = "&line=3,#0a8cf4&\n"
    @bg_colour = '#ffffff'
    @bg_image = ''
    @inner_bg_colour = ''
    @inner_bg_colour_2 = ''
    @inner_bg_angle = ''
    # Pie chart
    @pie = ''
    @pie_values = ''
    @pie_colours = ''
    @pie_labels = ''
    @tool_tip = ''
  end

  def set_data(a)
    @data << if @data.empty?
               "&values=#{a.join(',')}&\n"
             else
               "&values_#{(@data.size + 1)}=#{a.join(',')}&\n"
             end
  end

  def set_tool_tip(tip)
    @tool_tip = tip
  end

  def set_x_labels(a)
    @x_labels = a
  end

  def set_x_label_style(size, colour = '', orientation = 0, step = -1)
    @x_label_style_size = size
    @x_label_style_colour = colour unless colour.empty?
    @x_label_style_orientation = orientation if orientation > 0
    @x_label_style_step = step if step > 0
  end

  def set_bg_colour(colour)
    @bg_colour = colour
  end

  def set_bg_image(url, x = 'center', y = 'center')
    @bg_image = url
    @bg_image_x = x
    @bg_image_y = y
  end

  def set_inner_background(col, col2, angle = -1)
    @inner_bg_colour = col
    @inner_bg_colour_2 = col2 unless col2.empty?
    @inner_bg_angle = angle if angle != -1
  end

  def set_y_label_style(size, colour = '')
    @y_label_style = "&y_label_style=#{size}"
    @y_label_style << ",#{colour}" unless colour.empty?
    @y_label_style << "&\n"
  end

  def set_y_max(max)
    @y_max = max.to_i
  end

  def set_y_min(min)
    @y_min = min.to_i
  end

  def y_label_steps(val)
    @y_steps = val.to_i
  end

  def title(title, size = -1, colour = '')
    @title = title
    @title_size = size if size > 0
    @title_colour = colour unless colour.empty?
  end

  def set_x_legend(text, size = -1, colour = '')
    @x_legend = text
    @x_legend_size = size if size > -1
    @x_legend_colour = colour unless colour.empty?
  end

  def set_x_tick_size(size)
    @x_tick_size = size if size > 0
  end

  def set_x_axis_steps(steps)
    @x_axis_steps = steps if steps > 0
  end

  def set_y_legend(text, size = -1, colour = '')
    @y_legend = text
    @y_legend_size = size if size > -1
    @y_legend_colour = colour unless colour.empty?
  end

  def line(width, colour = '', text = '', size = -1, circles = -1)
    tmp = '&line'
    tmp << "_#{(@lines.size + 1)}" unless @lines.empty?
    tmp << "=#{width},#{colour}" if width > 0
    tmp << ",#{text},#{size}" unless text.empty?
    tmp << ",#{circles}" if circles > 0
    tmp << "&\n"
    @lines << tmp
  end

  def line_dot(width, dot_size, colour, text = '', font_size = 0)
    tmp = '&line_dot'
    tmp << "_#{(@lines.size + 1)}" unless @lines.empty?
    tmp << "=#{width},#{colour},#{text}"
    tmp << ",#{font_size},#{dot_size}" if font_size > 0
    tmp << "&\n"
    @lines << tmp
  end

  def line_hollow(width, dot_size, colour, text = '', font_size = 0)
    tmp = '&line_hollow'
    tmp << "_#{(@lines.size + 1)}" unless @lines.empty?
    tmp << "=#{width},#{colour},#{text}"
    tmp << ",#{font_size},#{dot_size}" if font_size > 0
    tmp << "&\n"
    @lines << tmp
  end

  def area_hollow(width, dot_size, colour, alpha, text = '', font_size = 0)
    tmp = '&area_hollow'
    tmp << "=#{(@lines.size + 1)}" unless @lines.empty?
    tmp << "=#{width},#{dot_size},#{colour},#{alpha}"
    tmp << ",#{text},#{font_size}" unless text.empty?
    tmp << "&\n"
    @lines << tmp
  end

  def bar(alpha, colour = '', text = '', size = -1)
    tmp = '&bar'
    tmp << "_#{(@lines.size + 1)}" unless @lines.empty?
    tmp << "=#{alpha},#{colour},#{text},#{size}&\n"
    @lines << tmp
  end

  def bar_filled(alpha, colour, _colour_outline, text = '', size = -1)
    tmp = '&filled_bar'
    tmp << "_#{(@lines.size + 1)}" unless @lines.empty?
    tmp << "=#{alpha},#{colour},#{text},#{size}&\n"
    @lines << tmp
  end

  def x_axis_colour(axis, grid = '')
    @x_axis_colour = axis
    @x_grid_colour = grid
  end

  def y_axis_colour(axis, grid = '')
    @y_axis_colour = axis
    @y_grid_colour = grid
  end

  def pie(alpha, line_colour, label_colour)
    @pie = "#{alpha},#{line_colour},#{label_colour}"
  end

  def pie_values(values, labels)
    @pie_values = values.join(',')
    @pie_labels = labels.join(',')
  end

  def pie_slice_colours(colours)
    @pie_colours = colours.join(',')
  end

  def render
    tmp = ''
    unless @title.empty?
      tmp << "&title=#{@title},#{@title_size},#{@title_colour}&\n"
    end
    unless @x_legend.empty?
      tmp << "&legend=#{@x_legend},#{@x_legend_size},#{@x_legend_colour}&\n"
    end
    if @x_label_style_size > 0
      tmp << "&x_label_style=#{@x_label_style_size},#{@x_label_style_colour},#{@x_label_style_orientation},#{@x_label_style_step}&\n"
    end
    tmp << "&x_ticks=#{@x_tick_size}&\n" if @x_tick_size > 0
    tmp << "&x_axis_steps=#{@x_axis_steps}&\n" if @x_axis_steps > 0
    unless @y_legend.empty?
      tmp << "&y_legend=#{@y_legend},#{@y_legend_size},#{@y_legend_colour}&\n"
    end
    tmp << @y_label_style unless @y_label_style.empty?
    tmp << "&y_ticks=5,10,#{@y_steps}&\n"
    if @lines.empty?
      tmp << @line_default
    else
      @lines.each { |line| tmp << line }
    end
    @data.each { |data| tmp << data }
    tmp << "&x_labels=#{@x_labels.join(',')}&\n" unless @x_labels.empty?
    tmp << "&y_min=#{@y_min}&\n"
    tmp << "&y_max=#{@y_max}&\n"
    tmp << "&bg_colour=#{@bg_colour}&\n" unless @bg_colour.empty?
    unless @bg_image.empty?
      tmp << "&bg_image=#{@bg_image}&\n"
      tmp << "&bg_image_x=#{@bg_image_x}&\n"
      tmp << "&bg_image_y=#{@bg_image_y}&\n"
    end
    unless @x_axis_colour.empty?
      tmp << "&x_axis_colour=#{@x_axis_colour}&\n"
      tmp << "&x_grid_colour=#{@x_grid_colour}&\n"
    end
    unless @y_axis_colour.empty?
      tmp << "&y_axis_colour=#{@y_axis_colour}&\n"
      tmp << "&y_grid_colour=#{@y_grid_colour}&\n"
    end
    unless @inner_bg_colour.empty?
      tmp << "&inner_background=#{@inner_bg_colour}"
      unless @inner_bg_colour_2.empty?
        tmp << ",#{@inner_bg_colour_2},#{@inner_bg_angle}"
      end
      tmp << "&\n"
    end
    unless @pie.empty?
      tmp << "&pie=#{@pie}&\n"
      tmp << "&values=#{@pie_values}&\n"
      tmp << "&pie_labels=#{@pie_labels}&\n"
      tmp << "&colours=#{@pie_colours}&\n"
    end
    tmp << "&tool_tip=#{@tool_tip}&\n" unless @tool_tip.empty?
    tmp
  end
end

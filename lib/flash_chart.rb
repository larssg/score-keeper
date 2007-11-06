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
    if @data.size == 0
      @data << "&values=#{a.join(',')}&\n"
    else
      @data << "&values_#{(@data.size + 1)}=#{a.join(',')}&\n"
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
    @x_label_style_colour = colour if colour.size > 0
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
    @inner_bg_colour_2 = col2 if col2.size > 0
    @inner_bg_angle = angle if angle != -1
  end
  
  def set_y_label_style(size, colour = '')
    @y_label_style = "&y_label_style=#{size}"
    @y_label_style << ",#{colour}" if colour.size > 0
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
    @title_colour = colour if colour.size > 0
  end
  
  def set_x_legend(text, size = -1, colour = '')
    @x_legend = text
    @x_legend_size = size if size > -1
    @x_legend_colour = colour if colour.size > 0
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
    @y_legend_colour = colour if colour.size > 0
  end
  
  def line(width, colour = '', text = '', size = -1, circles = -1)
    tmp = '&line'
    tmp << "_#{(@lines.size + 1)}" if @lines.size > 0
    tmp << "=#{width},#{colour}" if width > 0
    tmp << ",#{text},#{size}" if text.size > 0
    tmp << ",#{circles}" if circles > 0
    tmp << "&\n"
    @lines << tmp
  end
  
  def line_dot(width, dot_size, colour, text = '', font_size = 0)
    tmp = '&line_dot'
    tmp << "_#{(@lines.size + 1)}" if @lines.size > 0
    tmp << "=#{width},#{colour},#{text}"
    tmp << ",#{font_size},#{dot_size}" if font_size > 0
    tmp << "&\n"
    @lines << tmp
  end
  
  def line_hollow(width, dot_size, colour, text = '', font_size = 0)
    tmp = '&line_hollow'
    tmp << "_#{(@lines.size + 1)}" if @lines.size > 0
    tmp << "=#{width},#{colour},#{text}"
    tmp << ",#{font_size},#{dot_size}" if font_size > 0
    tmp << "&\n"
    @lines << tmp
  end
  
  def area_hollow(width, dot_size, colour, alpha, text = '', font_size = 0)
    tmp = '&area_hollow'
    tmp << "=#{(@lines.size + 1)}" if @lines.size > 0
    tmp << "=#{width},#{dot_size},#{colour},#{alpha}"
    tmp << ",#{text},#{font_size}" if text.size > 0
    tmp << "&\n"
    @lines << tmp
  end
  
  def bar(alpha, colour = '', text = '', size = -1)
    tmp = '&bar'
    tmp << "_#{(@lines.size + 1)}" if @lines.size > 0
    tmp << "=#{alpha},#{colour},#{text},#{size}&\n"
    @lines << tmp
  end
  
  def bar_filled(alpha, colour, colour_outline, text = '', size = -1)
    tmp = '&filled_bar'
    tmp << "_#{(@lines.size + 1)}" if @lines.size > 0
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
    tmp << "&title=#{@title},#{@title_size},#{@title_colour}&\n" if @title.size > 0
    tmp << "&legend=#{@x_legend},#{@x_legend_size},#{@x_legend_colour}&\n" if @x_legend.size > 0      
    tmp << "&x_label_style=#{@x_label_style_size},#{@x_label_style_colour},#{@x_label_style_orientation},#{@x_label_style_step}&\n" if @x_label_style_size > 0
    tmp << "&x_ticks=#{@x_tick_size}&\n" if @x_tick_size > 0
    tmp << "&x_axis_steps=#{@x_axis_steps}&\n" if @x_axis_steps > 0
    tmp << "&y_legend=#{@y_legend},#{@y_legend_size},#{@y_legend_colour}&\n" if @y_legend.size > 0
    tmp << @y_label_style if @y_label_style.size > 0
    tmp << "&y_ticks=5,10,#{@y_steps}&\n"
    if @lines.size == 0
      tmp << @line_default
    else
      @lines.each {|line| tmp << line}
    end
    @data.each {|data| tmp << data}
    tmp << "&x_labels=#{@x_labels.join(',')}&\n" if @x_labels.size > 0
    tmp << "&y_min=#{@y_min}&\n"
    tmp << "&y_max=#{@y_max}&\n"
    tmp << "&bg_colour=#{@bg_colour}&\n" if @bg_colour.size > 0
    if @bg_image.size > 0
      tmp << "&bg_image=#{@bg_image}&\n"
      tmp << "&bg_image_x=#{@bg_image_x}&\n"
      tmp << "&bg_image_y=#{@bg_image_y}&\n"
    end
    if @x_axis_colour.size > 0
      tmp << "&x_axis_colour=#{@x_axis_colour}&\n"
      tmp << "&x_grid_colour=#{@x_grid_colour}&\n"
    end
    if @y_axis_colour.size > 0
      tmp << "&y_axis_colour=#{@y_axis_colour}&\n"
      tmp << "&y_grid_colour=#{@y_grid_colour}&\n"
    end
    if @inner_bg_colour.size > 0
      tmp << "&inner_background=#{@inner_bg_colour}"
      tmp << ",#{@inner_bg_colour_2},#{@inner_bg_angle}" if @inner_bg_colour_2.size > 0
      tmp << "&\n"
    end
    if @pie.size > 0
      tmp << "&pie=#{@pie}&\n"
      tmp << "&values=#{@pie_values}&\n"
      tmp << "&pie_labels=#{@pie_labels}&\n"
      tmp << "&colours=#{@pie_colours}&\n"
    end
    tmp << "&tool_tip=#{@tool_tip}&\n" if @tool_tip.size > 0
    tmp
  end
end

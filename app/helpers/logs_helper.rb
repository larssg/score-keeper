module LogsHelper
  def log_link(log)
    icon = icons[log.linked_model]
    unless icon.blank?
      icon_link icon, h(log.message), log_uri(log)
    else
      h(log.message)
    end
  end
  
  def icon_link(icon, name, url)
    link_to image_tag("icons/#{icon}.png") + ' ' + name, url
  end

  def log_uri(log)
    if log.linked_model == 'Match'
      game_match_url(current_game, log.linked_id)
    elsif log.linked_model == 'Comment'
      game_match_url(current_game, Comment.find(log.linked_id).match_id, :anchor => "c#{log.linked_id}")
    end
  end
  
  def log_feed_url(options = {})
    formatted_logs_url(:atom, {:feed_token => current_user.feed_token}.merge(options))
  end
  
  protected
  def icons
    {
      'Match' => :game,
      'Comment' => :comment
    }
  end
end

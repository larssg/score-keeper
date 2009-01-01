module LogsHelper
  def log_link(log)
    icon = icons[log.linked_model]
    unless icon.blank?
      icon_link log.game_id, icon, h(log.message), log_uri(log)
    else
      h(log.message)
    end
  end
  
  def icon_link(game_id, icon, message, url)
    link_to(image_tag("icons/#{icon}.png"), url) + ' ' + format_message(game_id, message)
  end

  def log_uri(log)
    if log.linked_model == 'Match'
      game_match_url(log.game_id, log.linked_id)
    elsif log.linked_model == 'Comment'
      game_match_url(log.game_id, Comment.find(log.linked_id).match_id, :anchor => "c#{log.linked_id}")
    end
  end
  
  def log_feed_url(game, options = {}, user = nil)
    user ||= current_user
    formatted_game_logs_url(game, :atom, {:feed_token => user.feed_token}.merge(options))
  end
  
  def format_message(game_id, message)
    message.split('%').collect do |part|
      if part.to_i > 0
        user = find_user(part)
        link_to user.display_name, game_user_url(game_id, user.id)
      else
        part
      end
    end.join('')
  end

  protected
  def icons
    {
      'Match' => :game,
      'Comment' => :comment
    }
  end
end

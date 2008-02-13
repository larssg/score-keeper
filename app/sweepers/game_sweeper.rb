class GameSweeper < ActionController::Caching::Sweeper
  observe Game

  def after_create(game)
    expire_cache_for(game)
  end

  def after_update(game)
    expire_cache_for(game)
  end

  def after_destroy(game)
    expire_cache_for(game)
  end
  
  def expire_cache_for(game)
    expire_fragment(dashboard_path)
    expire_fragment(dashboard_path + '_games_per_day')
    expire_fragment(dashboard_path + '_sidebar')
    expire_fragment(teams_path)
  end
end
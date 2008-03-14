class MatcheSweeper < ActionController::Caching::Sweeper
  observe Matche

  def after_create(match)
    expire_cache_for(match)
  end

  def after_update(match)
    expire_cache_for(match)
  end

  def after_destroy(match)
    expire_cache_for(match)
  end
  
  def expire_cache_for(match)
    expire_fragment(root_path + '_' + match.account.domain)
    expire_fragment(root_path + '_' + match.account.domain + '_matches_per_day')
    expire_fragment(root_path + '_' + match.account.domain + '_sidebar')
    expire_fragment(teams_path + '_' + match.account.domain)
  end
end
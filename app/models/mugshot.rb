class Mugshot < ActiveRecord::Base
  def public_filename(version = nil)
    if version.nil?
      obj = self
    else
      obj = Mugshot.where(:thumbnail => version).where(:parent_id => id).first
    end
    
    id_as_string = "%08d" % id
    
    "/mugshots/#{id_as_string[0,4]}/#{id_as_string[4,4]}/#{obj.filename}"
  end
end

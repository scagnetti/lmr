module ApplicationHelper
  
  # Checks if a given link is the one currently requested by the client
  def check_place(link, url)
    if link == url
      return "active"
    else
      return "inactive"
    end
  end

end

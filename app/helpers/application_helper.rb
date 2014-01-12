module ApplicationHelper
  
  # Checks if a given link is the one currently requested by the client
  def check_place(link, url)
    #puts "#{link}"
    #puts "#{url}"
    if url.start_with?(link)
      return "active"
    else
      return "inactive"
    end
  end

end

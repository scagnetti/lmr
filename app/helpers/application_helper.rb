module ApplicationHelper
  
  # Checks if a given link is the one currently requested by the client
  def check_place(link, url)
    #puts "#{link}"
    #puts "#{url}"
    if url.start_with?(link)
      return "active"
    else
      return ""
    end
  end

  def format_currency(price, unit)
    return number_to_currency(price, unit: unit, locale: :de, separator: ',', delimiter:' ', format: "%n %u", precision: 0)
  end

  def link_to_ing_diba(isin)
    return "https://wertpapiere.ing-diba.de/DE/Showpage.aspx?pageID=23&ISIN=#{isin}"
  end
end

module SharesHelper
  
  def to_readable_comp_size(i)
    case i
    when CompanySize::LARGE
      return I18n.t(:large_cap)
    when CompanySize::MID
      return  I18n.t(:mid_cap)
    when CompanySize::SMALL
      return I18n.t(:small_cap)
    else
      return "unknown"
    end
  end
  
  def assemble_url(share)
    return "'shares/enable/#{share.isin}/#{!share.active}'"
  end
  
end

require 'engine/util'

class BulkExtractor

  def initialize(url)
    @agent = Util.createAgent()
    @page = @agent.get(url)
  end

  def seach_and_sort_by_loss(share)
    search_form = @page.form_with(:id => 'siteSearch')
    search_form['searchValue'] = share.isin
    @page = search_form.submit
    @page = @page.link_with(:text => 'Technisch').click
    td_set = @page.parser().xpath('//th[text() = "6 Monate"]/following-sibling::td[3]')
    if td_set.nil? || td_set.size == 0
      puts "Extraction faild for share #{share.name}"
      return {:p => 99, :s => share}
    else
      percent = td_set[0].content.sub(",", ".").sub("%", "").to_f
      #puts "Six month performance of share #{share.name} is: #{td_set[0].content}"
      return {:p => percent, :s => share}
    end
  end

  def add_shares_to_system(compare_index, member_index)
    form = @page.form('frmAktienSuche')
    form.field_with(:name => "inLand").option_with(:value => '0').click # value 0 for all, value 1 for Deutschland
    #form.inSonstige = '1' # Marktkapitalisierung
    #form.inSonstigeGrKl = '2' # groesser als
    #form.stSonstigZahl = '5000' # Angabe in Mio.
    unless member_index.nil?
      v = @page.parser().xpath("//option[text()='#{member_index}']")[0].attribute('value').to_s
      #puts "Index value to: #{v}"
      form.field_with(:name => "inIndex").option_with(:value => v).click
    end
    @page = @agent.submit(form)
    #@page.save_as("mytest.html")

    index = StockIndex.where("name like ?", compare_index).first
    puts "Setting compare index to: #{index.name}"

    begin
      add_stocks(index, @page)
      next_link = @page.link_with(:class => 'last image_button_right')
      if next_link
        @page = next_link.click
      end
    end while next_link
  end

  def add_stocks(cmp_index, page)
    links = page.parser().xpath('(//div[@class="content"])[3]/descendant::td/a')
    puts "Number of stock links found: #{links.size}"
    links.each do |link|
      stock_page = @agent.get('http://www.finanzen.net'+link.attribute('href'))
      @agent.page.encoding = 'utf-8'
      isin = stock_page.parser().xpath('//td[text()="ISIN"]/following-sibling::td/text()')
      branch = stock_page.parser().xpath('//td[contains(.,"Branchen")]/following-sibling::td/a/text()')
      b = branch.collect {|e| e.content()}.join()
      #puts "Branch description used for is financial check:\n#{b}"
      c = stock_page.parser().xpath('//tr/td[3][contains(.,"Marktkapitalisierung")]/following-sibling::td')
      #puts "Capitalization: #{c}"
      cs = Util.get_company_size(c[0].content)
      #puts "Company size: #{cs}"

      s = Share.new
      s.active = true
      s.name = link.content
      s.isin = isin[0].content
      s.financial = b.include?("Finanzdienstleister") || b.include?("Banken")
      s.size = cs
      s.currency = Currency::EUR
      s.stock_exchange = StockExchange::TRADEGATE
      s.stock_index_id = cmp_index.id
      #puts s.to_s
      added = s.save
      if added
        puts "Adding #{s.name}"
      end
    end
  end

end
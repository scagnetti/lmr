require 'mechanize'

class FindIsinForShare

  def self.find_all(file)

    puts "Reading file #{file}"
    agent = Mechanize.new
    page = agent.get("http://www.finanzen.net/suchergebnis.asp")
    form = page.form_with(:name => "mmssearch")

    File.open('result.txt', 'w') do |out| 

      File.readlines(file).each do |line|
        puts "Seaching for: #{line}"

        form["frmAktiensucheTextfeld"] = line
        result = form.submit
        
        tr_set = result.parser().xpath("//table/descendant::tr[position() > 1]")
        if tr_set == nil || tr_set.size == 0
          puts "Nothing, sorry!"
        else
          tr_set.each do |tr|
            r = tr.xpath('td[position() > 0][position() < 3]')
            #puts "ISIN: #{r[1].content}, #{r[0].content}"
            out.write("#{r[1].content} #{r[0].content}\n")
          end
        end

        out.puts "\n"
        #break
      end

    end

  end

end
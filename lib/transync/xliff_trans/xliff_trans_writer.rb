require 'builder'

class XliffTransWriter

  def initialize(path, file)
    @path = path
    @file = file
  end

  def write(language, trans_hash)
    translations = trans_hash[:translations]

    xml = Builder::XmlMarkup.new( :indent => 4 )
    xml.instruct! :xml, :encoding => 'UTF-8'
    xml.xliff :version => '1.2', :xmlns => 'urn:oasis:names:tc:xliff:document:1.2' do |xliff|
      xliff.file :'source-language' => language, :datatype => 'plaintext', :original => 'file.ext' do |file|
        file.body do |body|

          translations.keys.each do |trans_key|
            body.tag! 'trans-unit', :id => trans_key do |trans_unit|
              trans_unit.source trans_key
              trans_unit.target translations[trans_key]
            end
          end

        end
      end
    end

    File.open(file_path(language), 'w') { |file| file.write(xml.target!) }
  end

private

  def file_path(language)
    "#{@path}/#{@file}.#{language}.xliff"
  end

end

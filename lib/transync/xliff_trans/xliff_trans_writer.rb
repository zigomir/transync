require 'builder'

class XliffTransWriter
  attr_accessor :data,
                :path,
                :file,
                :language

  def initialize(path, file, data)
    @path = path
    @file = file
    @language = data[:language]
    @data = data
  end

  def save
    translations = data[:translations]

    xml = Builder::XmlMarkup.new( :indent => 4 )
    xml.instruct! :xml, :encoding => 'UTF-8'
    xml.xliff :version => '1.2', :xmlns => 'urn:oasis:names:tc:xliff:document:1.2' do |xliff|
      xliff.file :'source-language' => language, :datatype => 'plaintext', :original => 'file.ext' do |file|
        file.body do |body|

          translations.each do |trans|
            body.tag! 'trans-unit', :id => trans[:key] do |trans_unit|
              trans_unit.source trans[:key]
              trans_unit.target trans[:value]
            end
          end

        end
      end
    end

    File.open(file_path, 'w') { |file| file.write(xml.target!) }
  end

private

  def file_path
    "#{path}/#{file}.#{language}.xliff"
  end

end
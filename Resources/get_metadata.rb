require 'date'
require 'json'
require 'asciidoctor'

def get_metadata docpath
  lines = File.readlines(docpath)
  doc = (Asciidoctor::Document.new lines, parse_header_only: true).parse
  if doc.attributes.has_key? "revdate"
    begin
      revdate = DateTime.parse(doc.attributes["revdate"])
      doc.attributes["revdate"] = revdate.to_s
    rescue
      begin
        revdate = DateTime.strptime(doc.attributes["revdate"], "%Y-%m")
        doc.attributes["revdate"] = revdate.to_s
      rescue
        begin
          revdate = DateTime.strptime(doc.attributes["revdate"], "%Y")
          doc.attributes["revdate"] = revdate.to_s
        rescue
          # Unable to parse as a date field; no sense in passing this on.
          doc.attributes.delete("revdate")
        end
      end
    end
  end
  if doc.attributes.has_key? "created"
    begin
      created = DateTime.parse(doc.attributes["created"])
      doc.attributes["created"] = created.to_s
    rescue
      begin
        created = DateTime.strptime(doc.attributes["created"], "%Y-%m")
        doc.attributes["created"] = created.to_s
      rescue
        begin
          created = DateTime.strptime(doc.attributes["created"], "%Y")
          doc.attributes["created"] = created.to_s
        rescue
          # Unable to parse as a date field; no sense in passing this on.
          doc.attributes.delete("created")
        end
      end
    end
  end
  JSON.generate(doc.attributes)
end

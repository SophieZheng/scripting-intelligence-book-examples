require 'rdf/redland'

PARSER_RDF_TYPE="ntriples"

#STORAGE=Redland::TripleStore.new("hashes", "test", "new='yes',hash-type='bdb',dir='data'")
STORAGE=Redland::TripleStore.new("hashes", "test", "new='yes',hash-type='memory',dir='data'")
raise "Failed to create RDF storage" if !STORAGE

MODEL=Redland::Model.new(STORAGE)
raise "Failed to create RDF model" if !MODEL

def load_rdf_data uri_string
  uri=Redland::Uri.new(uri_string)
  parser=Redland::Parser.new(PARSER_RDF_TYPE, "", nil)
  raise "Failed to create RDF parser" if !parser
  stream=parser.parse_as_stream(uri, uri)
  count=0
  while !stream.end?()
    statement=stream.current()
    MODEL.add_statement(statement)
    #puts "found statement: #{statement}"
    count=count+1
    stream.next()
  end
  puts "Parsing added #{count} statements from file #{uri_string}"
end

def query sparql_query
  puts "\nQuery: #{sparql_query}\n"
  q = Redland::Query.new(sparql_query)
  results=q.execute(MODEL)
  while !results.finished?()
    for k in 0..results.bindings_count()-1
      s = results.binding_value(k).to_s.gsub('[','<').gsub(']','>')
      s = '"' + s + '"' if !s.index('<')
      puts "\t#{s}"
    end
    puts
    results.next()
  end
end

load_rdf_data("file:data/sample_news.nt")
query(" SELECT ?s ?o WHERE { ?s <http://knowledgebooks.com/ontology/#storyType> ?o } ")
query(" SELECT ?s ?o WHERE { ?s <http://knowledgebooks.com/ontology/#summary> ?o } ")
query(" SELECT ?s ?p ?o WHERE { ?s ?p ?o } ")

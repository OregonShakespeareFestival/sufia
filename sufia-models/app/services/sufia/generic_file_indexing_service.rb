module Sufia
  class GenericFileIndexingService < IndexingService
    def generate_solr_document
      super.tap do |solr_doc|
        solr_doc[Solrizer.solr_name('label')] = object.label
        solr_doc[Solrizer.solr_name('file_format')] = object.file_format
        solr_doc[Solrizer.solr_name('file_format', :facetable)] = object.file_format
        solr_doc['all_text_timv'] = object.full_text.content
        solr_doc = object.index_collection_ids(solr_doc)
      end
    end
  end
end

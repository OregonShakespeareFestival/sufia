class FeaturedWorkList
  include ActiveModel::Model

  def featured_works_attributes=(attributes_collection)
    attributes_collection = attributes_collection.sort_by { |i, _| i.to_i }.map { |_, attributes| attributes } if attributes_collection.is_a? Hash
    attributes_collection.each do |attributes|
      attributes = attributes.with_indifferent_access
      raise "Missing id" if attributes['id'].blank?
      existing_record = FeaturedWork.find(attributes['id'])
      existing_record.update(attributes.except('id'))
    end
  end

  delegate :query, :construct_query_for_pids, to: ActiveFedora::SolrService

  def featured_works
    return @works if @works
    @works = FeaturedWork.all
    add_solr_document_to_works
    @works
  end

  private
    def add_solr_document_to_works
      solr_docs.each do |doc|
        work_with_pid(doc['id']).generic_file_solr_document = SolrDocument.new(doc)
      end
    end

    def pids
      @works.pluck(:generic_file_id)
    end

    def solr_docs
      query(construct_query_for_pids(pids))
    end

    def work_with_pid(pid)
      @works.find { |w| w.generic_file_id == pid}
    end
  
end

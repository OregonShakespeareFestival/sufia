module My
  class HighlightsController < MyController

    self.solr_search_params_logic += [
      :show_only_highlighted_files
    ]

    def show_only_highlighted_files(solr_parameters, user_parameters)
      ids = current_user.trophies.pluck(:generic_file_id)
      solr_parameters[:fq] ||= []
      solr_parameters[:fq] += [
        ActiveFedora::SolrService.construct_query_for_ids(ids)
      ]
    end

    def index
      super
      @selected_tab = :highlighted
    end
  
    protected
    
    def search_action_url *args
      sufia.dashboard_highlights_url *args
    end

  end
end

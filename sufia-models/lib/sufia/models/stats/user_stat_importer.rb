module Sufia
  class UserStatImporter

    def initialize(options={})
      @verbose = options[:verbose]
      @logging = options[:logging]
    end

    def import
      log_message('Begin import of User stats.')
      ::User.find_each do |user|
        start_date = date_since_last_cache(user)

        stats = {}
        files_for_user(user).each do |file|
          view_stats = FileViewStat.statistics(file.id, start_date, user.id)
          stats = tally_results(view_stats, :views, stats)

          dl_stats = FileDownloadStat.statistics(file.id, start_date, user.id)
          stats = tally_results(dl_stats, :downloads, stats)
        end

        create_or_update_user_stats(stats, user)
      end
      log_message('User stats import complete.')
    end


private

    def date_since_last_cache(user)
      last_cached_stat = UserStat.where(user_id: user.id).order(date: :asc).last

      if last_cached_stat
        last_cached_stat.date + 1.day
      else
        Sufia.config.analytic_start_date
      end
    end

    def files_for_user(user)
      ::GenericFile.where(Solrizer.solr_name('depositor', :symbol) => user.user_key)
    end

    # For each date, add the view and download counts for this
    # file to the view & download sub-totals for that day.
    # The resulting hash will look something like this:
    # {"2014-11-30 00:00:00 UTC" => {:views=>2, :downloads=>5},
    #  "2014-12-01 00:00:00 UTC" => {:views=>4, :downloads=>4}}
    def tally_results(file_stats, stat_name, total_stats)
      file_stats.each do |stats|
        # Exclude the stats from today since it will only be a partial day's worth of data
        break if stats.date == Date.today

        date_key = stats.date.to_s
        old_count = total_stats[date_key] ? total_stats[date_key].fetch(stat_name) { 0 } : 0
        new_count = old_count + stats.method(stat_name).call

        old_values = total_stats[date_key] || {}
        total_stats.store(date_key, old_values)
        total_stats[date_key].store(stat_name, new_count)
      end
      total_stats
    end

    def create_or_update_user_stats(stats, user)
      stats.each do |date_string, data|
        date = Time.zone.parse(date_string)

        user_stat = UserStat.where(user_id: user.id).where(date: date).first
        user_stat ||= UserStat.new(user_id: user.id, date: date)

        user_stat.file_views = data[:views] || 0
        user_stat.file_downloads = data[:downloads] || 0
        user_stat.save!
      end
    end

    def log_message(message)
      puts message if @verbose
      Rails.logger.info "#{self.class}: #{message}" if @logging
    end

  end
end

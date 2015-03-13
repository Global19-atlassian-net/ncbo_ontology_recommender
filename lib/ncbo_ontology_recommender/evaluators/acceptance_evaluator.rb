require_relative '../../../lib/ncbo_ontology_recommender/config'
require_relative 'acceptance_result'

module OntologyRecommender

  module Evaluators

    BP_VISITS_NUMBER_MONTHS = 12
    ##
    # Ontology acceptance evaluator
    class AcceptanceEvaluator
      # - w_bp: weight assigned to the number of visits (pageviews) received by the ontology in BioPortal
      # - w_umls: weight assigned to the criteria "is the ontology included into UMLS?"
      def initialize(w_bp, w_umls)
        @w_bp = w_bp
        @w_umls = w_umls
        @umls_ontologies = nil
        @avg_visits_hash = nil
      end

      def evaluate(all_acronyms, ont_acronym)
        bp_score = get_bp_score(ont_acronym, BP_VISITS_NUMBER_MONTHS)
        umls_score = get_umls_score(all_acronyms, ont_acronym)
        norm_score = @w_bp * bp_score + @w_umls * umls_score
        return OntologyRecommender::Evaluators::AcceptanceResult.new(norm_score, bp_score, umls_score)
      end

      private
      def get_umls_score(all_acronyms, ont_acronym)
        if @umls_ontologies == nil
          @umls_ontologies = OntologyRecommender::Utils.get_umls_ontologies(all_acronyms)
        end
        if @umls_ontologies.include? ont_acronym
          return 1
        else
          return 0
        end
      end

      private
      # - num_months: number of months used to calculate the score (e.g. months = 6 => last 6 months)
      def get_bp_score(ont_acronym, num_months)
        if @avg_visits_hash == nil
          @avg_visits_hash = get_avg_visits_for_period(num_months)
        end
        # log10 normalization and range change to [0,1]
        norm_max_avg_visits = Math.log10(@avg_visits_hash.values.max)
        ont_avg_visits = @avg_visits_hash[ont_acronym] || 0
        if ont_avg_visits >= 1
          norm_avg_visits = Math.log10(ont_avg_visits)
        else
          norm_avg_visits = 0
        end
        bp_score = OntologyRecommender::Utils.normalize(norm_avg_visits, 0, norm_max_avg_visits, 0, 1)
        return bp_score
      end

      # Return a hash |acronym, avg_visits| for the last num_months. The result is ranked by avg_visits
      private
      def get_avg_visits_for_period(num_months)
        # Visits for all BioPortal ontologies
        bp_all_visits = get_visits([])
        periods = get_last_periods(num_months)
        avg_visits = Hash.new
        bp_all_visits.each do |acronym, visits|
          ont_visits_for_period = 0
          periods.each do |p|
            ont_visits_for_period += visits[p[0]][p[1]]
          end
          avg_visits[acronym] = ont_visits_for_period.to_f / periods.size.to_f
        end
        return avg_visits
      end

      private
      # Obtains an array of [year, month] elements for the last num_months
      def get_last_periods(num_months)
        year = Time.now.year
        month = Time.now.month
        # Array of [year, month] elements
        periods = [ ]
        num_months.times do
          if month > 1
            month -= 1
          else
            month = 12
            year -= 1
          end
          periods << [year, month]
        end
        return periods
      end

      private
      # If acronyms = [], all the analytics are returned
      def get_visits(acronyms)
        redis = Redis.new(host: Annotator.settings.annotator_redis_host, port: Annotator.settings.annotator_redis_port)
        raw_analytics = redis.get('ontology_analytics')
        raise Exception, 'Error loading ontology analytics data' if raw_analytics.nil?
        analytics = Marshal.load(raw_analytics)
        analytics.delete_if { |key, _| !acronyms.include? key } unless acronyms.empty?
        return analytics
      end

    end

  end

end
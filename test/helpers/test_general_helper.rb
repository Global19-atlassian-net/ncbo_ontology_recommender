require_relative '../test_case'
require_relative '../../lib/ncbo_ontology_recommender/helpers/annotator_helpers/custom_annotation'
class TestUtils < TestCase

  def self.before_suite
    @@custom_annotation = OntologyRecommender::Helpers::AnnotatorHelper::CustomAnnotation
    @@helpers = OntologyRecommender::Helpers
    @@pref_score = OntologyRecommender.settings.pref_score
    @@syn_score = OntologyRecommender.settings.syn_score
    @@multiterm_score = OntologyRecommender.settings.multiterm_score
  end

  def self.after_suite
  end

  def test_select_ontologies_for_ranking_sets
    cls1 = LinkedData::Models::Class.new
    cls1.submission = LinkedData::Models::OntologySubmission.new
    cls1.submission.ontology = LinkedData::Models::Ontology.new
    cls1.submission.ontology.acronym = 'ONT1'
    cls2 = LinkedData::Models::Class.new
    cls2.submission = LinkedData::Models::OntologySubmission.new
    cls2.submission.ontology = LinkedData::Models::Ontology.new
    cls2.submission.ontology.acronym = 'ONT2'
    cls3 = LinkedData::Models::Class.new
    cls3.submission = LinkedData::Models::OntologySubmission.new
    cls3.submission.ontology = LinkedData::Models::Ontology.new
    cls3.submission.ontology.acronym = 'ONT3'
    cls4 = LinkedData::Models::Class.new
    cls4.submission = LinkedData::Models::OntologySubmission.new
    cls4.submission.ontology = LinkedData::Models::Ontology.new
    cls4.submission.ontology.acronym = 'ONT4'
    a1 = @@custom_annotation.new(17, 26, 'PREF', 'BLOOD CELL', cls1, 0)
    a2 = @@custom_annotation.new(11, 26, 'PREF', 'WHITE BLOOD CELL', cls2, 0)
    a3 = @@custom_annotation.new(17, 21, 'PREF', 'BLOOD', cls3, 0)
    a4 = @@custom_annotation.new(17, 21, 'SYN', 'BLOOD', cls2, 0)
    a5 = @@custom_annotation.new(17, 21, 'SYN', 'BLOOD', cls4, 0)
    coverage_evaluator = OntologyRecommender::Evaluators::CoverageEvaluator.new(@@pref_score, @@syn_score, @@multiterm_score)
    selected_acronyms = @@helpers.select_ontologies_for_ranking_sets([], coverage_evaluator)
    assert_equal([], selected_acronyms)
    selected_acronyms = @@helpers.select_ontologies_for_ranking_sets([a1], coverage_evaluator)
    assert_equal([cls1.submission.ontology.acronym], selected_acronyms)
    selected_acronyms = @@helpers.select_ontologies_for_ranking_sets([a1, a2, a3], coverage_evaluator)
    assert_equal([cls2.submission.ontology.acronym], selected_acronyms)
    selected_acronyms = @@helpers.select_ontologies_for_ranking_sets([a3, a4, a5], coverage_evaluator)
    assert_equal([cls3.submission.ontology.acronym], selected_acronyms)
    selected_acronyms = @@helpers.select_ontologies_for_ranking_sets([a4, a5], coverage_evaluator)
    assert_equal([cls2.submission.ontology.acronym, cls4.submission.ontology.acronym], selected_acronyms)
  end

  def test_annotations_contained_in
    coverage_evaluator = OntologyRecommender::Evaluators::CoverageEvaluator.new(@@pref_score, @@syn_score, @@multiterm_score)
    a1 = @@custom_annotation.new(1, 5, 'PREF', 'BLOOD', nil, 0)
    a2 = @@custom_annotation.new(1, 5, 'PREF', 'BLOOD', nil, 0)
    a3 = @@custom_annotation.new(1, 5, 'SYN', 'BLOOD', nil, 0)
    a4 = @@custom_annotation.new(1, 10, 'PREF', 'BLOOD CELL', nil, 0)
    a5 = @@custom_annotation.new(10, 13, 'PREF', 'HEAD', nil, 0)
    a6 = @@custom_annotation.new(20, 22, 'PREF', 'ARM', nil, 0)
    a7 = @@custom_annotation.new(20, 22, 'PREF', 'ARM', nil, 0)
    assert_equal(true, @@helpers.annotations_contained_in([a1], [a2], coverage_evaluator))
    assert_equal(true, @@helpers.annotations_contained_in([a2], [a1], coverage_evaluator))
    assert_equal(true, @@helpers.annotations_contained_in([a3], [a1], coverage_evaluator))
    assert_equal(true, @@helpers.annotations_contained_in([a2], [a4], coverage_evaluator))
    assert_equal(true, @@helpers.annotations_contained_in([a1], [a2, a3], coverage_evaluator))
    assert_equal(true, @@helpers.annotations_contained_in([a1], [a2, a5], coverage_evaluator))
    assert_equal(true, @@helpers.annotations_contained_in([a1, a6], [a4, a5, a7], coverage_evaluator))
    assert_equal(true, @@helpers.annotations_contained_in([a2, a3], [a1], coverage_evaluator))
    assert_equal(true, @@helpers.annotations_contained_in([a3, a7], [a6, a2], coverage_evaluator))
    assert_equal(false, @@helpers.annotations_contained_in([a1], [a3], coverage_evaluator))
    assert_equal(false, @@helpers.annotations_contained_in([a4], [a2], coverage_evaluator))
    assert_equal(false, @@helpers.annotations_contained_in([a2, a5], [a1], coverage_evaluator))
    assert_equal(false, @@helpers.annotations_contained_in([a4, a5, a7], [a1, a6], coverage_evaluator))
    assert_equal(false, @@helpers.annotations_contained_in([a6, a2], [a3, a7], coverage_evaluator))
  end
  def test_annotations_contained_in_2
    coverage_evaluator = OntologyRecommender::Evaluators::CoverageEvaluator.new(@@pref_score, @@syn_score, @@multiterm_score)
    a1 = @@custom_annotation.new(1, 5, 'PREF', 'BLOOD', nil, 0)
    a2 = @@custom_annotation.new(1, 5, 'PREF', 'BLOOD', nil, 0)
    a3 = @@custom_annotation.new(1, 5, 'SYN', 'BLOOD', nil, 0)
    a4 = @@custom_annotation.new(1, 10, 'PREF', 'BLOOD CELL', nil, 0)
    a5 = @@custom_annotation.new(10, 13, 'PREF', 'HEAD', nil, 0)
    a6 = @@custom_annotation.new(20, 22, 'PREF', 'ARM', nil, 0)
    a7 = @@custom_annotation.new(20, 22, 'PREF', 'ARM', nil, 0)
    assert_equal(true, @@helpers.annotations_contained_in([a1], [a2], coverage_evaluator))
    assert_equal(true, @@helpers.annotations_contained_in([a2], [a1], coverage_evaluator))
    assert_equal(true, @@helpers.annotations_contained_in([a3], [a1], coverage_evaluator))
    assert_equal(true, @@helpers.annotations_contained_in([a2], [a4], coverage_evaluator))
    assert_equal(true, @@helpers.annotations_contained_in([a1], [a2, a3], coverage_evaluator))
    assert_equal(true, @@helpers.annotations_contained_in([a1], [a2, a5], coverage_evaluator))
    assert_equal(true, @@helpers.annotations_contained_in([a1, a6], [a4, a5, a7], coverage_evaluator))
    assert_equal(true, @@helpers.annotations_contained_in([a2, a3], [a1], coverage_evaluator))
    assert_equal(true, @@helpers.annotations_contained_in([a3, a7], [a6, a2], coverage_evaluator))
    assert_equal(false, @@helpers.annotations_contained_in([a1], [a3], coverage_evaluator))
    assert_equal(false, @@helpers.annotations_contained_in([a4], [a2], coverage_evaluator))
    assert_equal(false, @@helpers.annotations_contained_in([a2, a5], [a1], coverage_evaluator))
    assert_equal(false, @@helpers.annotations_contained_in([a4, a5, a7], [a1, a6], coverage_evaluator))
    assert_equal(false, @@helpers.annotations_contained_in([a6, a2], [a3, a7], coverage_evaluator))
  end

  def test_get_combinations
    elements = [1, 2, 3, 4]
    exp_0 = [ ]
    exp_1 = [[1], [2], [3], [4]]
    exp_2 = [[1], [2], [3], [4], [1, 2], [1, 3], [1, 4], [2, 3], [2, 4], [3, 4]]
    exp_3 = [[1], [2], [3], [4], [1, 2], [1, 3], [1, 4], [2, 3], [2, 4], [3, 4],
           [1, 2, 3], [1, 2, 4], [1, 3, 4], [2, 3, 4]]
    exp_4 = [[1], [2], [3], [4], [1, 2], [1, 3], [1, 4], [2, 3], [2, 4], [3, 4],
             [1, 2, 3], [1, 2, 4], [1, 3, 4], [2, 3, 4], [1, 2, 3, 4]]
    assert_equal(exp_0, @@helpers.get_combinations([], 3))
    combinations = @@helpers.get_combinations(elements, 1)
    assert_equal(exp_1, combinations)
    combinations = @@helpers.get_combinations(elements, 2)
    assert_equal(exp_2, combinations)
    combinations = @@helpers.get_combinations(elements, 3)
    assert_equal(exp_3, combinations)
    combinations = @@helpers.get_combinations(elements, 4)
    assert_equal(exp_4, combinations)
    combinations = @@helpers.get_combinations(elements, 10)
    assert_equal(exp_4, combinations)
  end

  def test_normalize
    assert_equal(0, @@helpers.normalize(0, 0, 1, 0, 1))
    assert_equal(1, @@helpers.normalize(1, 0, 1, 0, 1))
    assert_equal(0, @@helpers.normalize(10, 10, 15, 0, 1))
    assert_equal(1, @@helpers.normalize(15, 10, 15, 0, 1))
    assert_equal(0.5, @@helpers.normalize(5, 0, 10, 0, 1))
    assert_equal(21.to_f/179.to_f, @@helpers.normalize(27, 6, 185, 0, 1))
  end

  def test_normalize_weights
    assert_raises(ArgumentError) {@@helpers.normalize_weights([0, 0, 0, 0])}
    assert_raises(RangeError) {@@helpers.normalize_weights([0, -2, 0, 0])}
    assert_equal([0.2, 0.2, 0.5, 0.1], @@helpers.normalize_weights([0.2, 0.2, 0.5, 0.1]))
    assert_equal([0.2, 0.2, 0.5, 0.1], @@helpers.normalize_weights([0.2, 0.2, 0.5, 0.1]))
    assert_equal([0, 0.5, 0.4, 0.1], @@helpers.normalize_weights([0, 50, 40, 10]))
    assert_equal([0.1, 0.4, 0.4, 0.1], @@helpers.normalize_weights([10, 40, 40, 10]))
  end

  def test_get_ont_acronym_from_uri
    uri = 'http://data.bioontology.org/ontologies/SNOMEDCT'
    acronym = @@helpers.get_ont_acronym_from_uri(uri)
    assert_equal('SNOMEDCT', acronym)
  end

end



module Cucumber
  module FeatureFactory
    class Scenario
      
      TAB = '  '
      
      attr_reader :feature  # reference to the parent feature
      attr_accessor :description
      attr_accessor :tags
      attr_accessor :execution   # when
      attr_accessor :preconditions  # given
      attr_accessor :expectations  # then
      
      def initialize(feature, scenario, execution, prioirty=nil)
        unless feature.is_a?(Feature)
          raise ArgumentError.new("feature should be of type Feature.")
        end
        unless scenario.is_a?(String)
          raise ArgumentError.new("scenario should be string.")
        end
        @description = scenario
        @tags = []
        @preconditions = []
        @expectations = []
        
        @execution = execution
        add_priority(priority) unless priority.nil?
      end
      
      # comparison
      def ==(obj)
        return obj.is_a?(Scenario) && self.feature == obj.feature && self.description == obj.description 
      end
      
      def add_prioirty(priority)
        unless clause.is_a?(String) || clause.is_a?(Integer)
          raise ArgumentError.new("Priority should be string or integer.")
        end
        priority = '@P' + priority
        @tags << priority
      end
      
      def add_tag(tag)
        unless clause.is_a?(String)
          raise ArgumentError.new("Tag should be string.")
        end
        @tags << '@' + tag
      end
      
      def add_when(clause)
        unless clause.is_a?(String)
          raise ArgumentError.new("When clause should be string.")
        end
        @execution = clause
      end
      
      def add_given(clause)
        unless clause.is_a?(String)
          raise ArgumentError.new("Given clause should be string.")
        end
        @preconditions << clause
      end
      
      def add_then(clause)
        unless clause.is_a?(String)
          raise ArgumentError.new("Then clause should be string.")
        end
        @expectations << clause
      end
      
      def content
        prefix_and = '\n' + TAB*2 + 'AND'
<<-GHERKIN

  #{@tags.join(' ')} unless tags.empty?}
  Scenario: #{description}
    Given #{@preconditions.first}#{ prefix_and + @preconditions[1..-1].join(prefix_and) if @preconditions.count > 1 }
    When #{@execution.to_s}
    Then #{@expectations.first}#{prefix_and + @expectations[1..-1].join(prefix_and) if @expectations.count > 1}
    GHERKIN
      end
    end
  end
end
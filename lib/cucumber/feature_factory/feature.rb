module Cucumber
  module FeatureFactory
    class Feature
      
      attr_accessor :title
      attr_accessor :description
      attr_accessor :scenarios
      
      def initialize(title, description)
        @title = title
        @description = description
        @scenarios = []
      end
      
      def create_scenario(scenario, execution, priority)
        if scenarios.include?(scenario)
          raise ArgumentError("The scenario already exists.")
        end
        Scenario.new(self, scenario, execution, priority)
      end 
      
      def file_name
        "#{title.downcase.gsub(' ', '_')}.feature"
      end
      
      def content
<<-GHERKIN
Feature: #{name}
#{scenarios.each {|scenario| scenario.content}}
    GHERKIN
      end
    end
  end
end
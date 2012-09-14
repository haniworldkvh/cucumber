module Cucumber
  module FeatureFactory
    class Feature
      
      attr_accessor :title
      attr_accessor :description
      attr_accessor :scenarios
      
      def initialize(title, description)
        puts "Purring title:  #{title}"
        puts "putting description: #{description}"
        @title = title
        @description = description
        @scenarios = []
      end
      
      def create_scenario(scenario, execution, priority)
        if scenarios.include?(scenario)
          raise ArgumentError.new("The scenario already exists.")
        end
        Scenario.new(self, scenario, execution, priority)
      end 
      
      def add_scenario(scenario)
        unless scenario.is_a?(Scenario)
          raise ArgumentError.new("scenario should be of type Scenario")
        end
        @scenarios << scenario
      end
      
      def filename
        "#{@title.downcase.gsub(' ', '_')}.feature"
      end
      
      def write
<<-GHERKIN
Feature: #{title}
#{self.write_scenarios}
    GHERKIN
      end
      
      def write_scenarios
        gherkin = ''
        @scenarios.each do |scenario| 
          gherkin << scenario.write
        end 
        gherkin
      end
    end
  end
end
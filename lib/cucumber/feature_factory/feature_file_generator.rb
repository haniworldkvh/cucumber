require 'roo'
require 'iconv'

class Excelx
  def worksheet(arg)
    if arg.is_a?(String)

    elsif arg.is_a?(Integer)
    else
      raise ArgumentError()
    end
  end
end

module Cucumber
  module FeatureFactory
    class FeatureFileGenerator
      
      COL = {
        :priority =>  'A',  #"Priority", 
        :feature =>   'B',  #"Feature", 
        :scenario =>  'C',  #"Test Scenario", 
        :when =>      'D',  #"Command", 
        :then =>      'E',  #"Expected", 
        :given =>     'F',  #"Notes (Pre steps)", 
        :result =>    'G',  #"Result", 
        :number =>    'H'   #"Number"
      }

      COMMENT_SYMBOL= "#"
      
  
      attr_accessor :file_path
      attr_accessor :features_dir
      attr_accessor :sheet_index
  
      def initialize(file_path, features_dir, sheet_index = nil)
        @file_path, @features_dir, @sheet_index = file_path, features_dir, sheet_index
        @sheet_index = sheet_index.to_i
      end
  
      def run!
        features = []
        ext = @file_path.split('.').last
        if ext == 'xlsx'
          features = parse_excel
        else
          raise ArgumentError.new("Unsupported file format.")
        end
        write(features)
      end
  
      # Return an array of features
      def parse_excel
        features = []
        
        @book = Excelx.new(@file_path)
        @book.default_sheet = @sheet_index  unless @sheet_index.nil?
        
        feature = nil
        scenario = nil
        ((@book.first_row + 1)..@book.last_row).each do |row|
          puts "\n[INFO] Processing row: #{row}"
          priority_cell = @book.cell(row, COL[:priority]).to_s
          unless priority_cell.nil? || priority_cell.include?(COMMENT_SYMBOL)
            feature_cell = @book.cell(row, COL[:feature])
            unless feature_cell.nil? || feature_cell.empty?
              features << feature unless feature.nil?  # Add the feature when new feature cell is encountered
              title = feature_cell.split(/\n/).first
              description = feature_cell.split(/\n/).last
              feature =  Feature.new(title, description)
            end
        
            scenario_cell = @book.cell(row, COL[:scenario]).to_s
            unless scenario_cell.empty?
              priority = @book.cell(row, COL[:priority]).to_s
              when_clause = @book.cell(row, COL[:when]).to_s
              scenario = feature.create_scenario(scenario_cell, when_clause, priority.empty? ? nil : priority)
          
              given_cell = @book.cell(row, COL[:given]).to_s
              given_clauses = (given_cell.nil? || given_cell.empty?) ? [] : given_cell.split(/\n/)
              given_clauses.each do |clause|
                scenario.add_given(clause)
              end
              then_cell = @book.cell(row, COL[:then]).to_s
              then_clauses = (then_cell.nil? || then_cell.empty?) ? [] : then_cell.split(/\n/)
              then_clauses.each do |clause|
                scenario.add_then(clause)
              end
              feature.add_scenario(scenario)
            end
          end # unless comment row
        end  # end each row
        features << feature unless feature.nil? # add the last feature
        features
    
      end # method parse_excel
  
      def write(features)
        if @feature_dir.nil? || @feature_dir.empty?
          @feature_dir = 'features'
        end
        puts "Writing all feature files under #{@feature_dir}"
        features.each do |feature|
          file = File.join(@feature_dir, feature.filename)
          puts "Writing a feature file: #{feature.title}"
          File.open(file, 'w') {|f| f.write(feature.write) }
        end
      end
      
    end  # end class
  end # end module
end

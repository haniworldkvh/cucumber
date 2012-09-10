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
    
    col = {
      :priority =>  'A',  #"Priority", 
      :feature =>   'B',  #"Feature", 
      :scenario =>  'C',  #"Test Scenario", 
      :when =>      'D',  #"Command", 
      :then =>      'E',  #"Expected", 
      :result =>    'F',  #"Result", 
      :given =>     'G',  #"Notes (Pre steps)", 
      :number =>    'H'   #"Number"
    }

    COMMENT_SYMBOL= "#"

    class FeatureFileGenerator
  
      attr_accessor :file_path
      attr_accessor :features_dir
  
      def initialize(file_path, features_dir, sheet_index = nil)
        @file_path, @features_dir, @sheet_index = file_path, features_dir, sheet_index
        @sheet_index = sheet_index
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
    
        @book.default_sheet = @sheet_index  unless sheet_index.nil?
        @book = Excelx.new(@file_path)
    
        feature = nil
        scenario = nil
        (@book.first_row..@book.last_row).each do |row|
          unless @book.cell(row, col[:priority]).include?(COMMENT_SYMBOL)
            feature_cell = @book.cell(row, col[:feature])
            unless feature_cell.empty?
              features << feature unless feature.nil?
              title = feature_cell.split('\n')
              description = feature_cell.split('\n')
              feature =  Feature.new(title, description)
            end
        
            scenario_cell = @book.cell(row, col[:scenario])
            unless scenario_cell.empty?
              priority = @book.cell(row, col[:priority])
              when_clause = @book.cell(row, col[:when])
              scenario = feature.create_scenario(scenario_cell, when_clause, priority.empty? ? nil : priority)
          
              given_clauses = @book.cell(row, col[:given])
              given_clauses.empty? ? [] : given_clauses.split('\n')
              given_clauses.each do |clause|
                scenario.add_given(clause)
              end
              then_clauses = @book.cell(row, col[:then])
              then_clauses.empty? ? [] : then_clauses.split('\n')
              then_clauses.each do |clause|
                scenario.add_then(clause)
              end
            end
          end # unless comment row
        end  # end each row
        features
    
      end # method parse_excel
  
      def write(features)
        features.each do |feature|
          file = [@feature_dir, feature.filename].join('/')
          File.open(file, 'w') {|f| f.write(feature.content) }
        end
      end
      
    end  # end class
  end # end module
end

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
      features = parse_excel()
    else
      raise ArgumentError.new("Unsupported file format.")
    end
    write(features)
  end
  
  # Return an array of features
  def parse_excel
    features = []
    @ff = FeatureFactory
    
    @book.default_sheet = @sheet_index  unless sheet_index.nil?
    @book = Excelx.new(@file_path)
    
    feature = nil
    scenario = nil
    (@book.first_row..@book.last_row).each do |row|
      unless @book.cell(row, col[:priority]).include?(COMMENT_SYMBOL)
        feature_cell = @book.cell(row, col[:feature])
        unless feature_cell.empty?
          features << feature unless feature.nil?
          feature = @ff.create_feature(feature_cell)
        end
        
        scenario_cell = @book.cell(row, col[:scenario])
        unless scenario_cell.empty?
          priority = @book.cell(row, col[:priority])
          scenario = @ff.create_scenario(scenario_cell, priority.empty? ? nil : priority)
          @ff.add_when(scenario, @book.cell(row, col[:when]))
          
          given_cell = @book.cell(row, col[:given])
          given_cell.empty? ? [] : given_cell.split('\n')
          given_cell.each do |pre_step|
            @ff.add_given(scenario, pre_step)
          end
          then_cell = @book.cell(row, col[:then])
          then_cell.empty? ? [] : then_cell.split('\n')
          then_cell.each do |expected|
            @ff.add_then(scenario, expected)
          end
          feature.add_scenario(scenario)
        end
      end # unless comment row
    end  # end each row
    features
    
  end # method parse_excel
  
  def write(features)
    features.each do |feature|
      feature.write_to_file(@features_dir)
    end
  end
end

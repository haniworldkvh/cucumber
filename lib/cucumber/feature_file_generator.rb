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

#["Feature", "Number", "Scenario", "Given", "When", "Then"]
COL_MAPPING = {
  :feature => '',
  :number => '',
  :scenario => '',
  :given => '',
  :when => '',
  :then => ''
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
      raise ArgumentError.new("Unspported file format.")
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
    (@book.first_row..@book.last_row).each do |row|
      unless @book.cell(row, col[:priority]).include?(COMMENT_SYMBOL)
        feature_cell = @book.cell(row, col[:feature])
        unless feature_cell.empty?
          features << feature unless feature.nil?
          feature = @ff.create_feature(feature_cell)
        end
        scenario = nil
        scenario_cell = @book.cell(row, col[:scenario])
        unless scenario_cell.empty?
          scenario = @ff.create_scenario(feature, scenario_cell)
          
          @ff.add_scenario(scenario)
        end
      end
    end

    # start parsing the feature
    
    # Get the first feature.
  end
end

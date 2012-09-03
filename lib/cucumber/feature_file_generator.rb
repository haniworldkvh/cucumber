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

class FeatureFileGenerator
  def run!
  end
  
  def parse_excel(file_path, features_dir, sheet_index = nil)
    @book.default_sheet =  unless sheet_index.nil?
    @book = Excel.new(file_path)
    col_names = @book.row(@book.first_row)

    # start parsing the feature
    # Get the first feature.
  end
end



class FeatureFactory

  def create_feature(name)
  end

  def create_files
end
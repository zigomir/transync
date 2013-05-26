require 'google_drive'
require_relative 'gdoc_trans'

class GdocTransWriter
  attr_accessor :worksheet

  def initialize(worksheet)
    @worksheet = worksheet
  end

  def write(row, column, data)
    @worksheet[row, GdocTrans::WORKSHEET_COLUMNS[column.to_sym]] = data
  end

  def shift_up(old_row_num, rows_count)
    # shift up that many times we're missing till the end
    (old_row_num..rows_count).to_a.each do |new_row|
      (1..worksheet.num_cols).to_a.each do |col|
        cell = @worksheet[new_row, col]
        @worksheet[new_row, col] = ''
        @worksheet[new_row + 1, col] = cell
      end
    end

    @worksheet
  end

end

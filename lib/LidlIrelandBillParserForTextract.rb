require "LidlIrelandBillParserForTextract/version"
require "json"
require 'StoreData'
module LidlIrelandBillParserForTextract
  class Error < StandardError;
  end

  class JsonParser

    @@products = nil
    @@breakLoop = false

    :private

    def self.getDataLidl(jsonFile)
      data = JSON.parse(jsonFile)
      data
    end

    def self.isTextPriceChange(text)
      (text.downcase == 'Price change'.downcase) || text.downcase.include?('Price '.downcase)
    end

    def self.isPreviousLinePriceChange(data, index)
      index > 0 && isTextPriceChange(data[index - 1]['Text'])
      # code here
    end

    def self.isPreviousLineDiscountedItem(data, index)
      index > 0 && isTextDiscountedItem(data[index - 1]['Text'])
    end

    def self.isLineAPrice(text)
      text.match(/[0-9]+.[0-9]+\s+[a-cA-C]/) ||
          text.match(/[0-9]+,[0-9]+\s+[a-cA-C]/)
    end

    def self.isTextDiscountedItem(text)
      text.match(/[a-zA-z]+\s[a-zA-z]+\s([0-9]*[.])?[0-9]+%/)
    end

    def self.isATransId(text)
      text.include?('TRN-ID') || text.include?('TRN ') ||
          text.match(/\S+:\sIE[0-9]+/) || text.match(/.+IE[0-9]{10,}/)
    end

    def self.isAKeyWord(text)
      isAKeyWord = false
      if text.size == 1 && text.match(/[a-cA-C]/)
        isAKeyWord = true
      elsif text.match(/[0-9]+%\sVAT/)
        isAKeyWord = true
      elsif text.downcase == 'Total'.downcase || isTextDiscountedItem(text) || isTextPriceChange(text) || isATransId(text)
        isAKeyWord = true
      elsif text.include?('CARD') || text.include?('Debit') || text.include?('Payment')
        isAKeyWord = true
      elsif text.downcase.include?('Total'.downcase) &&
          text.downcase.include?('Discount'.downcase)
        isAKeyWord = true
      end
      isAKeyWord
    end

    def self.isPreviousLineTotal(data, index)
      index > 0 && data[index - 1]['Text'].downcase == 'Total'.downcase
    end

    def self.isPreviousLineMultibuyDiscount(data, index)
      data[index - 1]["Text"].match(/[0-9]+\sfor\sEUR\s([0-9]*[.])?[0-9]+/)
    end

    def self.isProbablyANumber(text)
      (text.match(/[0-9]+.[0-9]+/) || text.match(/[0-9]+,[0-9]+/) || text.match(/[0-9]+/))
    end

    def self.getUseFullData(text, data, index)
      if !isPreviousLineMultibuyDiscount(data, index)
        if !@@products.empty? && isPreviousLinePriceChange(data, index)
          @@products.last.UnitPrice =
              @@products.last.UnitPrice + (text.to_f /
                  @@products.last.ProductQuantity)
          @@products.last.TotalPrice = @@products.last.UnitPrice * @@products.last.ProductQuantity
        elsif !@@products.empty? && isPreviousLineDiscountedItem(data, index)
          @@products.last.UnitPrice =
              @@products.last.UnitPrice + (text.to_f /
                  @@products.last.ProductQuantity)
          @@products.last.TotalPrice = @@products.last.UnitPrice * @@products.last.ProductQuantity
        elsif text.match(/[0-9]+\s[xX]\s+[+-]?([0-9]*[.])?[0-9]+/) || text.match(/[0-9]+\s+[+-]?([0-9]*[.])?[0-9]+/)
          if (text.downcase.include?("X".downcase))
            @@products.last.UnitPrice = text.downcase[text.downcase.index('X'.downcase) + 1, text.size].to_f
            @@products.last.ProductQuantity = text.downcase[0].to_i
          else
            @@products.last.UnitPrice = text.downcase[text.downcase.index(" ".downcase) + 1, text.size].to_f
            @@products.last.ProductQuantity = text.downcase[0].to_i
          end
          @@products.last.TotalPrice = @@products.last.UnitPrice * @@products.last.ProductQuantity

          #CODE HERE
        elsif text.match(/[0-9]+\sfor\sEUR\s([0-9]*[.])?[0-9]+/)
          @@products.last.ProductQuantity = text[text.index('EUR') + 4, text.size].to_i
          @@products.last.UnitPrice = text[0, text.index('for') - 1].to_f / @@products.last.ProductQuantity
          @@products.last.TotalPrice = @@products.last.UnitPrice * @@products.last.ProductQuantity

          #CODE HERE
        else
          unless isAKeyWord(text)
            if isLineAPrice(text)
              @@products.last.UnitPrice = text[0, text.index(' ')].strip.to_f
              @@products.last.TotalPrice = @@products.last.UnitPrice * @@products.last.ProductQuantity
            elsif isProbablyANumber(text) && isPreviousLineTotal(data, index)
              @@breakLoop = true
            else
              item = StoreData.new
              item.ProductQuantity = 1
              item.ProductName = text.strip
              item.Discount = 0.0
              item.UnitPrice = 0.0
              item.TotalPrice = 0.0
              @@products.push(item)
            end
          end
        end
      end
    end

    def self.isProductPriceZero(product)
      product.UnitPrice.to_f == 0.0 || product.TotalPrice.to_f == 0.0
    end

    def self.cleanAndKeepRelaventData
      @@products.each do |product|
        if isProbablyANumber(product.ProductName) || isProductPriceZero(product)
          @@products.delete_at(@@products.index(product))
        end
      end
      @@products
    end

    def self.parseLineData(result, blocks_map)

      @@products = []
      index = 0
      startProcessing = false
      @@breakLoop = false
      result.each do |line|
        if !line['Text'].empty? && !@@breakLoop
          if line['Confidence'].to_i > 50
            if !startProcessing && line['Text'] == 'EUR'
              startProcessing = true
              index += 1
              next
            end
            if startProcessing
              text = line['Text']
              next if text.include?('----')
              getUseFullData(text, result, index)

            end
          end
        end
        index += 1
      end
      cleanAndKeepRelaventData()
    end

    :public

    def self.parseReceiptData(jsonFile)
      data = getDataLidl(jsonFile)
      blocks_map = {}
      line_blocks = []
      data['Blocks'].each do |block|
        blocks_map[block['Id']] = block
        next unless block['BlockType'] == 'LINE'
        line_blocks.append(block)
      end
      parseLineData(line_blocks, blocks_map)
    end
  end

  def self.parseData(jsonFile)
    JsonParser.parseReceiptData(jsonFile)
  end
end

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'product swatches', :js, type: :feature do
  let(:product) { Spree::Product.find_by!(name: 'Solidus T-Shirt') }
  before do
    visit spree.product_path(product)
  end

  it 'will show the product options in the show page' do
    expect(page).to have_css('.optionTypeSize')
    within('.optionTypeSize') do
      selectors = find_all('.selection-items', visible: true).count
      expect(selectors).to eq(4)
    end

    expect(page).to have_css('.optionTypeColor')
    within('.optionTypeColor') do
      selectors = find_all('.selection-items', visible: true).count
      expect(selectors).to eq(3)
    end
  end

  describe 'when I select another option' do
    it 'updates the selected option type text' do
      selectors = all('.selection-items')
      expect(find('#selected-tshirt-size').text).to eq('S')
      expect(find('#selected-tshirt-color').text).to eq('Blue')

      selectors[1].click
      expect(find('#selected-tshirt-size').text).to eq('M')

      selectors[2].click
      selectors[5].click
      expect(find('#selected-tshirt-size').text).to eq('L')
      expect(find('#selected-tshirt-color').text).to eq('White')
    end

    it 'will hide option types that do not have a match' do
      within('.optionTypeSize') do
        @option_type_size = find_all('.selection-items', visible: true)
      end

      within('.optionTypeColor') do
        @option_type_size[1].click
        color_selectors = find_all('.selection-items', visible: true).count
        expect(color_selectors).to eq(1)

        @option_type_size[2].click
        color_selectors = find_all('.selection-items', visible: true).count
        expect(color_selectors).to eq(2)

        @option_type_size[3].click
        color_selectors = find_all('.selection-items', visible: true).count
        expect(color_selectors).to eq(1)

        @option_type_size[0].click
        color_selectors = find_all('.selection-items', visible: true).count
        expect(color_selectors).to eq(3)
      end
    end

    it 'will update the price if variant price is different than original' do
      Spree::Price.create variant: product.variants.last, amount: 10, currency: 'USD'
      visit spree.product_path(product)
      expect(find('#product-price').text).to eq('$19.99')

      all('.selection-items')[3].click
      expect(find('#product-price').text).to eq('$10.00')
    end
  end

  describe 'when I add an item to my cart' do
    it 'adds the correct swatch selected variant to my cart' do
      selectors = all('.selection-items')
      selectors[2].click
      selectors[5].click

      find('#add-to-cart-button').click
      expect(find('.item-info__options').text).to have_content('Size: L, Color: White')
    end
  end
end

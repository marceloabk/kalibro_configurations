require 'rails_helper'

RSpec.describe ReadingsController, :type => :controller do

  let(:reading) { FactoryGirl.build(:reading) }

  describe "GET show" do
    context 'when the Reading exists' do
      before :each do
        Reading.expects(:find).with(reading.id).returns(reading)

        get :show, id: reading.id, format: :json
      end

      it { is_expected.to respond_with(:success) }

      it 'is expected to return the list of readings converted to JSON' do
        expect(JSON.parse(response.body)).to eq(JSON.parse({reading: reading}.to_json))
      end
    end

    context 'when the Reading does not exist' do
      before :each do
        Reading.expects(:find).with(reading.id).raises(ActiveRecord::RecordNotFound)

        get :show, id: reading.id, format: :json
      end

      it { is_expected.to respond_with(:unprocessable_entity) }

      it 'should return the error description' do
        expect(JSON.parse(response.body)).to eq(JSON.parse({error: 'RecordNotFound'}.to_json))
      end
    end
  end

  describe "POST create" do
    let!(:reading_params) { Hash[FactoryGirl.attributes_for(:reading, reading_group_id: reading.reading_group.id).map { |k,v| [k.to_s, v.to_s] }] } #FIXME: Mocha is creating the expectations with strings, but FactoryGirl returns everything with sybols and integers

    context 'with valid attributes' do
      before :each do
        Reading.any_instance.expects(:save).returns(true)

        post :create, reading: reading_params, format: :json
      end

      it { is_expected.to respond_with(:created) }

      it 'is expected to return the reading' do
        reading.id = nil
        expect(JSON.parse(response.body)).to eq(JSON.parse({reading: reading}.to_json))
      end
    end

    context 'with invalid attributes' do
      before :each do
        Reading.any_instance.expects(:save).returns(false)

        post :create, reading: reading_params, format: :json
      end

      it { is_expected.to respond_with(:unprocessable_entity) }

      it 'should return the error description with the reading' do
        reading.id = nil
        expect(JSON.parse(response.body)).to eq(JSON.parse({reading: reading}.to_json))
      end
    end
  end

  describe "PUT update" do
    let!(:reading_params) { Hash[FactoryGirl.attributes_for(:reading, reading_group_id: reading.reading_group.id).map { |k,v| [k.to_s, v.to_s] }] } #FIXME: Mocha is creating the expectations with strings, but FactoryGirl returns everything with sybols and integers

    before :each do
      Reading.expects(:find).with(reading.id).returns(reading)
    end

    context 'with valid attributes' do
      before :each do
        reading_params.delete('id')
        Reading.any_instance.expects(:update).with(reading_params).returns(true)

        put :update, reading: reading_params, id: reading.id, format: :json
      end

      it { is_expected.to respond_with(:created) }

      it 'is expected to return the reading' do
        expect(JSON.parse(response.body)).to eq(JSON.parse({reading: reading}.to_json))
      end
    end

    context 'with invalid attributes' do
      before :each do
        reading_params.delete('id')
        Reading.any_instance.expects(:update).with(reading_params).returns(false)

        put :update, reading: reading_params, id: reading.id, format: :json
      end

      it { is_expected.to respond_with(:unprocessable_entity) }

      it 'should return the error description with the reading' do
        expect(JSON.parse(response.body)).to eq(JSON.parse({reading: reading}.to_json))
      end
    end
  end

  describe "DELETE destroy" do
    before :each do
      reading.expects(:destroy).returns(true)
      Reading.expects(:find).with(reading.id).returns(reading)

      delete :destroy, id: reading.id, format: :json
    end

    it { is_expected.to respond_with(:success) }
  end

end
